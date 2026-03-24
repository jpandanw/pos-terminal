import 'package:flutter/material.dart';
import 'package:pos_terminal/features/transactions/presentation/make_transaction/sections/cart_view.dart';
import 'package:pos_terminal/features/transactions/presentation/make_transaction/widgets/barcode_listener_widget.dart';

import 'sections/product_listing_view.dart';

@immutable
class MakeTransactionPage extends StatelessWidget {
  const MakeTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Make Transaction")),
      body: BarcodeListenerWidget(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(flex: 8, child: ProductListingView()),
            const VerticalDivider(),
            Flexible(flex: 4, child: const CartView()),
          ],
        ),
      ),
    );
  }
}
