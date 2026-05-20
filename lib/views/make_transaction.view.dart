import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:pos_terminal/states/auth.state.dart';
import 'package:pos_terminal/states/load_data.state.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/states/products_loaded.state.dart';
import 'package:pos_terminal/views/cart.view.dart';
import 'package:pos_terminal/views/product_list.view.dart';
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
      body: BarcodeKeyboardListener(
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
