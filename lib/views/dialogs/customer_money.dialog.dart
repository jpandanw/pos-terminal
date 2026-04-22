import 'package:flutter/material.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/views/reciept.view.dart';
import 'package:signals/signals_flutter.dart';

class CustomerMoneyDialog extends StatefulWidget {
  const CustomerMoneyDialog({super.key});

  @override
  State<CustomerMoneyDialog> createState() => _CustomerMoneyDialogState();
}

class _CustomerMoneyDialogState extends State<CustomerMoneyDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = makeTransactionRef(context);

    // Initial sync if customer money is already set
    if (cartState.customerMoney.value != null && _controller.text.isEmpty) {
      _controller.text = cartState.customerMoney.value.toString();
    }

    return AlertDialog(
      title: const Text("Enter Customer Money"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Amount (PHP)",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onChanged: (val) {
              cartState.customerMoney.value = double.tryParse(val);
            },
            onSubmitted: (val) {
              _submit(context, cartState);
            },
          ),
          const SizedBox(height: 16),
          Watch((_) {
            final change = cartState.change.value;
            if (change == null) {
              return const Text("Change: -");
            }
            return Text(
              "Change: PHP ${change.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: change < 0 ? Colors.red : Colors.green,
              ),
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        Watch((_) {
          final change = cartState.change.value;
          return FilledButton(
            onPressed: (change != null && change >= 0)
                ? () => _submit(context, cartState)
                : null,
            child: const Text("Complete Transaction"),
          );
        }),
      ],
    );
  }

  void _submit(BuildContext context, MakeTransactionState cartState) {
    final change = cartState.change.value;
    if (change == null || change < 0) return;
    Navigator.pop(context); // Close dialog
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecieptView()),
    );
  }
}
