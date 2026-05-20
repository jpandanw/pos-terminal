import 'package:flutter/material.dart';
import 'package:pos_terminal/data/server/post_sale.dart';
import 'package:pos_terminal/states/auth.state.dart';
import 'package:pos_terminal/states/hardware.state.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/types/transactions.type.dart';
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

  void _submit(BuildContext context, MakeTransactionState cartState) async {
    final change = cartState.change.value;
    if (change == null || change < 0) return;

    final hardwareState = startupStateRef(context);
    final authState = authStateRef(context);

    final terminalId = hardwareState.hardwareId.value;

    final cashierId = authState.cashier.value?.id;

    if (terminalId == null || cashierId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Missing hardware or cashier ID")),
        );
      }
      return;
    }

    final itemsPayload = cartState.cart
        .map(
          (item) => {
            "productId": item.product.id,
            "productName": item.product.name,
            "sellingPrice": item.product.price,
            "quantity": item.quantity,
            "subtotal": item.product.price * item.quantity,
          },
        )
        .toList();

    final modifiersPayload = cartState.modifiers
        .map(
          (mod) => {
            "modifierId": mod.id,
            "name": mod.name,
            "amount": mod.amount,
            "type": mod.type == TransactionModifierType.percentage
                ? "PERCENTAGE"
                : "FLAT",
          },
        )
        .toList();

    final result = await postSale(
      terminalId: terminalId,
      cashierId: cashierId,
      items: itemsPayload,
      modifiers: modifiersPayload,
      total: cartState.overallTotal.value,
      customerCash: cartState.customerMoney.value ?? 0.0,
      customerChange: change,
    );

    if (!context.mounted) return;

    if (result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit sale: ${result.exceptionOrNull()}"),
        ),
      );
      return;
    }

    Navigator.pop(context); // Close dialog
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecieptView()),
    );
  }
}
