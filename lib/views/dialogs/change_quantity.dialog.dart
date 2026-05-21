import 'package:flutter/material.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/states/restriction.state.dart';
import 'package:pos_terminal/types/product.type.dart';
import 'package:pos_terminal/views/dialogs/supervisor_validation.dialog.dart';

class ChangeQuantityDialog extends StatefulWidget {
  final Product product;
  final int currentQuantity;

  const ChangeQuantityDialog({
    super.key,
    required this.product,
    required this.currentQuantity,
  });

  @override
  State<ChangeQuantityDialog> createState() => _ChangeQuantityDialogState();
}

class _ChangeQuantityDialogState extends State<ChangeQuantityDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentQuantity.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Change Quantity - ${widget.product.name}"),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        decoration: const InputDecoration(
          labelText: "Quantity",
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        onSubmitted: (_) => _submit(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () => _submit(context),
          child: const Text("Update"),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    final qty = int.tryParse(_controller.text);
    if (qty == null) {
      Navigator.pop(context);
      return;
    }

    final cartState = makeTransactionRef(context);
    final restriction = restrictionStateRef(context);

    void executeAction() {
      cartState.setQuantity(product: widget.product, quantity: qty);
    }

    if (qty < widget.currentQuantity) {
      if (restriction.isAuthorized) {
        executeAction();
        restriction.useAuthorization();
        Navigator.pop(context);
      } else {
        // Pop the current ChangeQuantityDialog first to avoid overlapping dialogs
        Navigator.pop(context);
        
        // Show Supervisor validation dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SupervisorValidationDialog(
            actionDescription: qty <= 0 
                ? "remove '${widget.product.name}'" 
                : "reduce quantity of '${widget.product.name}' to $qty",
            onSuccess: executeAction,
          ),
        );
      }
    } else {
      executeAction();
      Navigator.pop(context);
    }
  }
}
