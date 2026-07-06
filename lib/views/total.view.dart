import 'package:flutter/material.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/types/transactions.type.dart';
import 'package:signals/signals_flutter.dart';

class TotalView extends StatelessWidget {
  const TotalView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartState = makeTransactionRef(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Subtotal:"),
            Watch(
              (_) => Text(
                "P${cartState.cartTotal.value.toStringAsFixed(2)}",
                style: const TextStyle(fontFamily: "monospace", fontSize: 18),
              ),
            ),
          ],
        ),
        Watch((_) {
          if (cartState.modifiers.isEmpty) return const SizedBox.shrink();
          return Column(
            children: cartState.modifiers
                .map(
                  (m) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Modifier (${m.name}):"),
                      Text(
                        m.type == TransactionModifierType.percentage
                            ? "${m.amount}%"
                            : "P${m.amount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontFamily: "monospace",
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          );
        }),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total:"),
            Card(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Watch(
                  (_) => Text(
                    "P${cartState.overallTotal.value.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
