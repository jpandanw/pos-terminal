import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/states/products_loaded.state.dart';
import 'package:pos_terminal/views/cart.view.dart';
import 'package:pos_terminal/views/product_list.view.dart';

class MakeTransactionView extends StatelessWidget {
  const MakeTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SUKI - POINT OF SALE")),
      body: BarcodeKeyboardListener(
        bufferDuration: Duration(milliseconds: 299),

        onBarcodeScanned: (String p1) {
          debugPrint("Debug: Barcode: $p1");
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
}
