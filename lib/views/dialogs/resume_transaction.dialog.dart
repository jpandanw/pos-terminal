import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_terminal/states/held_transaction.state.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';

class ResumeTransactionDialog extends StatefulWidget {
  const ResumeTransactionDialog({super.key});

  @override
  State<ResumeTransactionDialog> createState() => _ResumeTransactionDialogState();
}

class _ResumeTransactionDialogState extends State<ResumeTransactionDialog> {
  int _cursorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final heldState = heldTransactionRef.of(context);
    final carts = heldState.heldCarts.toList();

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
          if (_cursorIndex < carts.length - 1) {
            setState(() => _cursorIndex++);
          }
          return KeyEventResult.handled;
        }

        if (event.logicalKey == LogicalKeyboardKey.enter) {
          if (carts.isNotEmpty && _cursorIndex < carts.length) {
            _handleResume(context, _cursorIndex);
          }
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: AlertDialog(
      title: const Text("Paused Transactions"),
      content: SizedBox(
        width: double.maxFinite,
        child: carts.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No paused transactions found."),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: carts.length,
                itemBuilder: (context, index) {
                  final heldCart = carts[index];
                  final total = heldCart.cart.fold<double>(
                    0.0,
                    (acc, item) => acc + (item.product.price * item.quantity),
                  );

                  return ListTile(
                    tileColor: index == _cursorIndex
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : null,
                    title: Text(
                      "Transaction #${index + 1}  -  ${heldCart.cart.length} items",
                    ),
                    subtitle: Text(
                      "Paused at: ${TimeOfDay.fromDateTime(heldCart.heldAt).format(context)}\nTotal: \$${total.toStringAsFixed(2)}",
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _handleResume(context, index),
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
  }

  Future<void> _handleResume(BuildContext context, int index) async {
    final makeState = makeTransactionRef.of(context);
    final heldState = heldTransactionRef.of(context);

    bool shouldResume = true;

    if (makeState.cart.isNotEmpty) {
      final action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Current Cart Not Empty"),
          content: const Text(
            "You have items in your current transaction. What would you like to do?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('replace'),
              child: const Text("Replace Current"),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop('hold'),
              child: const Text("Hold Current Transaction"),
            ),
          ],
        ),
      );

      if (!context.mounted) return;

      if (action == null || action == 'cancel') {
        shouldResume = false;
      } else if (action == 'hold') {
        heldState.holdCurrentCart(context);
      } else if (action == 'replace') {
        makeState.cart.clear();
      }
    } else {
      if (!context.mounted) return;
    }

    if (shouldResume) {
      heldState.resumeCart(context, index);
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}
