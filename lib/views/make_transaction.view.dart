import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:pos_terminal/states/auth.state.dart';
import 'package:pos_terminal/states/load_data.state.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/states/products_loaded.state.dart';
import 'package:pos_terminal/states/restriction.state.dart';
import 'package:pos_terminal/views/cart.view.dart';
import 'package:pos_terminal/views/dialogs/supervisor_validation.dialog.dart';
import 'package:pos_terminal/views/product_list.view.dart';
import 'package:flutter/services.dart';
import 'package:pos_terminal/states/held_transaction.state.dart';
import 'package:pos_terminal/views/dialogs/change_quantity.dialog.dart';
import 'package:pos_terminal/views/dialogs/customer_money.dialog.dart';
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
                  const _RestrictionStatusIndicator(),
                  const SizedBox(width: 16),
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
              final restriction = restrictionStateRef(context);

              void executeAction() {
                cartState.removeFromCart(product: item.product);
              }

              if (restriction.isAuthorized) {
                executeAction();
                restriction.useAuthorization();
              } else {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => SupervisorValidationDialog(
                    actionDescription: "remove '${item.product.name}'",
                    onSuccess: executeAction,
                  ),
                );
              }
            }
            return KeyEventResult.handled;
          }

          // F6 or ENTER to set quantity
          if (event.logicalKey == LogicalKeyboardKey.f6 ||
              (event.logicalKey == LogicalKeyboardKey.enter && !HardwareKeyboard.instance.isControlPressed)) {
            // Wait, if searchFocusNode is focused, enter is handled by SearchBar onSubmitted.
            // We shouldn't capture ENTER if search is focused.
            if (searchFocusNode.hasFocus && event.logicalKey == LogicalKeyboardKey.enter) {
              return KeyEventResult.ignored; // Let SearchBar handle it
            }

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

class _RestrictionStatusIndicator extends StatelessWidget {
  const _RestrictionStatusIndicator();

  @override
  Widget build(BuildContext context) {
    final restriction = restrictionStateRef(context);
    final theme = Theme.of(context);

    return Watch((_) {
      final isBypassed = restriction.bypassType.value != BypassType.none;
      final text = restriction.statusText;
      final colorScheme = theme.colorScheme;

      return Tooltip(
        message: isBypassed 
            ? "Supervisor authorization is active. Tap 'X' to lock." 
            : "Click to pre-authorize with supervisor credentials.",
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isBypassed 
                ? Colors.green.withOpacity(0.15) 
                : colorScheme.outlineVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isBypassed 
                  ? Colors.green.withOpacity(0.4) 
                  : colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (!isBypassed) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => SupervisorValidationDialog(
                    actionDescription: "pre-authorize remove/reduce operations",
                    onSuccess: () {},
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isBypassed ? Icons.lock_open_outlined : Icons.lock_outline,
                    color: isBypassed ? Colors.green[700] : colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isBypassed ? Colors.green[800] : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (isBypassed) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => restriction.clearBypass(),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.green[700]?.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 12,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
