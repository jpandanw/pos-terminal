import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_terminal/states/load_data.state.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/types/transactions.type.dart';
import 'package:signals/signals_flutter.dart';

class PickPriceModifiersDialog extends StatefulWidget {
  const PickPriceModifiersDialog({super.key});

  @override
  State<PickPriceModifiersDialog> createState() => _PickPriceModifiersDialogState();
}

class _PickPriceModifiersDialogState extends State<PickPriceModifiersDialog> {
  int _cursorIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final availableModifiers = fetchDataRef.of(context).saleModifiers.value;
      final activeModifiers = makeTransactionRef.of(context).modifiers.value;

      return Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;

          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            if (_cursorIndex > 0) {
              setState(() => _cursorIndex--);
            }
            return KeyEventResult.handled;
          }

          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            if (_cursorIndex < availableModifiers.length - 1) {
              setState(() => _cursorIndex++);
            }
            return KeyEventResult.handled;
          }

          if (event.logicalKey == LogicalKeyboardKey.enter) {
            if (availableModifiers.isNotEmpty && _cursorIndex < availableModifiers.length) {
              final modifier = availableModifiers[_cursorIndex];
              final isSelected = activeModifiers.any((m) => m.id == modifier.id);
              if (isSelected) {
                makeTransactionRef.of(context).modifiers.removeWhere((m) => m.id == modifier.id);
              } else {
                makeTransactionRef.of(context).modifiers.add(modifier);
              }
            }
            return KeyEventResult.handled;
          }

          return KeyEventResult.ignored;
        },
        child: AlertDialog(
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

                    return Container(
                      color: index == _cursorIndex
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : null,
                      child: CheckboxListTile(
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
                      ),
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
        ),
      );
    });
  }
}
