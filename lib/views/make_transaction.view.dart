import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:pos_terminal/states/auth.state.dart';
import 'package:pos_terminal/states/load_data.state.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/states/products_loaded.state.dart';
import 'package:pos_terminal/states/theme.state.dart';
import 'package:pos_terminal/views/cart.view.dart';
import 'package:pos_terminal/views/product_list.view.dart';
import 'package:flutter/services.dart';
import 'package:pos_terminal/states/held_transaction.state.dart';
import 'package:pos_terminal/views/dialogs/change_quantity.dialog.dart';
import 'package:pos_terminal/views/dialogs/customer_money.dialog.dart';
import 'package:pos_terminal/views/dialogs/pick_price_modifiers.dialog.dart';
import 'package:pos_terminal/views/dialogs/resume_transaction.dialog.dart';
import 'package:signals/signals_flutter.dart';

class MakeTransactionView extends StatelessWidget {
  const MakeTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SUKI - POINT OF SALE"),
        actions: [
          Watch((_) {
            final cashier = authStateRef(context).cashier.value;
            if (cashier == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        cashier.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(cashier.email, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Watch((_) {
                    final themeState = themeStateRef(context);
                    final isDark = themeState.isDarkMode.value;
                    return IconButton(
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      tooltip: 'Toggle Theme',
                      onPressed: () {
                        themeState.toggleDarkMode();
                      },
                    );
                  }),
                  const SizedBox(width: 16),
                  PopupMenuButton<Color>(
                    icon: const Icon(Icons.color_lens),
                    tooltip: 'Change Color Scheme',
                    onSelected: (color) {
                      themeStateRef(context).setSeedColor(color);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: Colors.deepPurple,
                        child: Row(
                          children: [
                            Container(width: 16, height: 16, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            const Text("Deep Purple"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: Colors.blue,
                        child: Row(
                          children: [
                            Container(width: 16, height: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text("Blue"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: Colors.teal,
                        child: Row(
                          children: [
                            Container(width: 16, height: 16, color: Colors.teal),
                            const SizedBox(width: 8),
                            const Text("Teal"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: Colors.green,
                        child: Row(
                          children: [
                            Container(width: 16, height: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text("Green"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: Colors.orange,
                        child: Row(
                          children: [
                            Container(width: 16, height: 16, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Text("Orange"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: Colors.red,
                        child: Row(
                          children: [
                            Container(width: 16, height: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            const Text("Red"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Data',
                    onPressed: () async {
                      await fetchDataRef(context).load();
                      productsLoadedRef(context).load(fetchDataRef(context).products.value);
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;

          final cartState = makeTransactionRef(context);

          // "/" to focus search
          if (event.logicalKey == LogicalKeyboardKey.slash) {
            if (!searchFocusNode.hasFocus) {
              searchFocusNode.requestFocus();
              return KeyEventResult.handled;
            }
          }

          // Ctrl+Enter or End to complete transaction
          if (event.logicalKey == LogicalKeyboardKey.end ||
              (event.logicalKey == LogicalKeyboardKey.enter && HardwareKeyboard.instance.isControlPressed)) {
            if (cartState.cart.isNotEmpty) {
              cartState.customerMoney.value = null;
              showDialog(
                context: context,
                builder: (context) => const CustomerMoneyDialog(),
              );
            }
            return KeyEventResult.handled;
          }

          // F1 to hold transaction
          if (event.logicalKey == LogicalKeyboardKey.f1) {
            if (cartState.cart.isNotEmpty) {
              heldTransactionRef.of(context).holdCurrentCart(context);
            }
            return KeyEventResult.handled;
          }

          // F2 to resume transaction
          if (event.logicalKey == LogicalKeyboardKey.f2) {
            if (heldTransactionRef.of(context).heldCarts.isNotEmpty) {
              showDialog(
                context: context,
                builder: (context) => const ResumeTransactionDialog(),
              );
            }
            return KeyEventResult.handled;
          }

          // F3 to pick price modifiers
          if (event.logicalKey == LogicalKeyboardKey.f3) {
            showDialog(
              context: context,
              builder: (context) => const PickPriceModifiersDialog(),
            );
            return KeyEventResult.handled;
          }

          // Up/Down arrows for cart cursor
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            cartState.moveCursorUp();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            cartState.moveCursorDown();
            return KeyEventResult.handled;
          }

          // DEL to remove item
          if (event.logicalKey == LogicalKeyboardKey.delete) {
            if (cartState.cart.isNotEmpty && cartState.cartCursorIndex.value < cartState.cart.length) {
              final item = cartState.cart[cartState.cartCursorIndex.value];
              cartState.removeFromCart(product: item.product);
            }
            return KeyEventResult.handled;
          }

          // F6 to set quantity
          if (event.logicalKey == LogicalKeyboardKey.f6) {

            if (cartState.cart.isNotEmpty && cartState.cartCursorIndex.value < cartState.cart.length) {
              final item = cartState.cart[cartState.cartCursorIndex.value];
              showDialog(
                context: context,
                builder: (context) => ChangeQuantityDialog(
                  product: item.product,
                  currentQuantity: item.quantity,
                ),
              );
            }
            return KeyEventResult.handled;
          }

          return KeyEventResult.ignored;
        },
        child: BarcodeKeyboardListener(
          bufferDuration: Duration(milliseconds: 299),

          onBarcodeScanned: (String p1) {
            final product = productsLoadedRef(context).getProductByBarcode(p1);
            if (product == null) {
              debugPrint("Product not found");
              return;
            }
            makeTransactionRef(context).addToCart(product: product, quantity: 1);
          },
          child: const Row(
            children: [
              Flexible(flex: 4, child: ProductListView()),
              VerticalDivider(),
              Flexible(
                flex: 4,
                child: Column(
                  children: [
                    Text("Cart:"),
                    Flexible(flex: 10, child: CartView()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              authStateRef(context).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

