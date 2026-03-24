import 'package:flutter/material.dart';
import '../cart_store.dart';
import '../widgets/cart_item_widget.dart';
import 'package:signals/signals_flutter.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartStore = cartStoreRef.of(context);
    return Column(
      children: [
        const Text(
          "Cart:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Flexible(
          flex: 9,
          child: Watch(
            (_) => ListView.builder(
              itemCount: cartStore.count.value,
              itemBuilder: (context, index) => Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CartItemWidget(cartStore: cartStore, index: index),
                ),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total:",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  Watch(
                    (_) => Text(
                      "P${cartStore.subtotal.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              label: Padding(
                padding: const EdgeInsets.all(12.0),
                child: const Column(
                  children: [Icon(Icons.price_change), Text("Discounts")],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: 999999,
          child: FilledButton(
            onPressed: () {},
            child: const Text("COMPLETE TRANSACTION"),
          ),
        ),
      ],
    );
  }
}
