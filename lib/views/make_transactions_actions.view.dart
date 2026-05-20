import 'package:flutter/material.dart';
import 'package:pos_terminal/states/held_transaction.state.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/views/dialogs/customer_search.dialog.dart';
import 'package:pos_terminal/views/dialogs/pick_price_modifiers.dialog.dart';
import 'package:pos_terminal/views/dialogs/resume_transaction.dialog.dart';
import 'package:signals/signals_flutter.dart';

class MakeTransactionsActionsView extends StatelessWidget {
  const MakeTransactionsActionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => Flex(
        direction: Axis.horizontal,
        spacing: 8,
        children: [
          /// Hold Transaction Button ---------------
          FilledButton.icon(
            onPressed: makeTransactionRef.of(context).cart.isEmpty
                ? null
                : () {
                    heldTransactionRef.of(context).holdCurrentCart(context);
                  },
            icon: const Icon(Icons.pause),
            label: const Text("Hold Transaction"),
          ),

          /// Resume Transaction Button ----------------
          Stack(
            children: [
              Badge.count(
                count: heldTransactionRef.of(context).heldCarts.length,
                child: FilledButton.icon(
                  onPressed: heldTransactionRef.of(context).heldCarts.isEmpty
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const ResumeTransactionDialog(),
                          );
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Resume Transaction"),
                ),
              ),
            ],
          ),

          /// Price Modifiers Button ----------------
          Stack(
            children: [
              Badge.count(
                count: makeTransactionRef.of(context).modifiers.length,
                isLabelVisible: makeTransactionRef
                    .of(context)
                    .modifiers
                    .isNotEmpty,
                child: FilledButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const PickPriceModifiersDialog(),
                    );
                  },
                  icon: const Icon(Icons.price_change),
                  label: const Text("Price Modifiers"),
                ),
              ),
            ],
          ),

          /// Customer Button ----------------
          Stack(
            children: [
              Badge(
                isLabelVisible:
                    makeTransactionRef.of(context).customerId.value != null,
                label: const Icon(Icons.check, size: 10),
                child: FilledButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CustomerSearchDialog(),
                    );
                  },
                  icon: const Icon(Icons.person_search),
                  label: const Text("Customer"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
