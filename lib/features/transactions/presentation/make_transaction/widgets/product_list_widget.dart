import 'package:flutter/material.dart';

import '../../../../cart/domain/models/cart.domain.dart';
import '../../../../products/domain/models/products.domain.dart';
import '../cart_store.dart';

class ProductListWidget extends StatelessWidget {
  const ProductListWidget({super.key, required this.products, this.onSelected});
  final List<Product> products;
  final Function(CartItem item)? onSelected;

  @override
  Widget build(BuildContext context) {
    final cartStore = cartStoreRef.of(context);
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card.outlined(
          child: ListTile(
            onTap: () {
              cartStore.addToCart(product, 1);
            },
            title: Text(product.name),
            trailing: Text(
              "P${product.basePrice.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        );
      },
    );
  }
}
