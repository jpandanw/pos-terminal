import 'package:flutter/material.dart';
import 'package:pos_terminal/features/transactions/presentation/make_transaction/cart_store.dart';
import 'package:signals/signals_flutter.dart';

class CartItemWidget extends StatelessWidget {
  final int index;

  final CartStore cartStore;
  const CartItemWidget({
    super.key,
    required this.cartStore,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cartStore.cartItems[index].product.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              "[P${cartStore.cartItems[index].product.basePrice.toStringAsFixed(2)}]",
            ),
          ],
        ),
        Watch(
          (_) => Text(
            "[P${cartStore.cartItems[index].subTotal.toStringAsFixed(2)}]",
          ),
        ),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                final qty = cartStore.cartItems[index].quantity;
                if (qty - 1 <= 0) {
                  cartStore.cartItems.removeAt(index);
                }
                cartStore.cartItems[index] = cartStore.cartItems[index]
                    .copyWith(quantity: qty - 1);
              },
              onLongPress: () {
                cartStore.cartItems.removeAt(index);
              },
              label: const Icon(Icons.remove),
            ),
            Watch(
              (_) => Text(
                cartStore.cartItems[index].quantity.toString(),
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                final qty = cartStore.cartItems[index].quantity;
                cartStore.cartItems[index] = cartStore.cartItems[index]
                    .copyWith(quantity: qty + 1);
              },
              label: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
