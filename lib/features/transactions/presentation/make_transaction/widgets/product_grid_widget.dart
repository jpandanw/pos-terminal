import 'package:flutter/material.dart';
import 'package:pos_terminal/features/transactions/presentation/make_transaction/cart_store.dart';

import '../../../../cart/domain/models/cart.domain.dart';
import '../../../../products/domain/models/products.domain.dart';

class ProductGridWidget extends StatelessWidget {
  const ProductGridWidget({super.key, required this.products, this.onSelected});
  final List<Product> products;
  final Function(CartItem item)? onSelected;

  @override
  Widget build(BuildContext context) {
    final cartStore = cartStoreRef.of(context);
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
      ),
      itemCount: products.length,
      itemBuilder: (BuildContext context, int index) {
        final product = products[index];
        return Card.outlined(
          elevation: 5,
          child: InkWell(
            onTap: () {
              cartStore.addToCart(product, 1);
            },
            child: Column(
              children: [
                Expanded(child: Placeholder()),
                Text("P${product.basePrice.toStringAsFixed(2)}"),
                Text(product.name),
              ],
            ),
          ),
        );
      },
    );
  }
}
