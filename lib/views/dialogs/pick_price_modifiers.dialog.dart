import 'package:flutter/material.dart';
import 'package:pos_terminal/states/load_data.state.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/types/transactions.type.dart';
import 'package:signals/signals_flutter.dart';

class PickPriceModifiersDialog extends StatelessWidget {
  const PickPriceModifiersDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final availableModifiers = fetchDataRef.of(context).saleModifiers.value;
      final activeModifiers = makeTransactionRef.of(context).modifiers.value;

      return AlertDialog(
        title: const Text("Select Sale Modifier"),
        content: SizedBox(
          width: 400,
          child: availableModifiers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No sale modifiers available."),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableModifiers.length,
                  itemBuilder: (context, index) {
                    final modifier = availableModifiers[index];
                    final isSelected = activeModifiers.any(
                      (m) => m.id == modifier.id,
                    );

                    final displayAmount =
                        modifier.type == TransactionModifierType.percentage
                        ? '${modifier.amount}%'
                        : '\$${modifier.amount.toStringAsFixed(2)}';

                    return CheckboxListTile(
                      title: Text(modifier.name),
                      subtitle: Text(displayAmount),
                      value: isSelected,
                      onChanged: (bool? checked) {
                        if (checked == true) {
                          makeTransactionRef
                              .of(context)
                              .modifiers
                              .add(modifier);
                        } else {
                          makeTransactionRef
                              .of(context)
                              .modifiers
                              .removeWhere((m) => m.id == modifier.id);
                        }
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      );
    });
  }
}
