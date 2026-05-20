import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pos_terminal/config.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';

class CustomerCardDialog extends StatefulWidget {
  const CustomerCardDialog({super.key});

  @override
  State<CustomerCardDialog> createState() => _CustomerCardDialogState();
}

class _CustomerCardDialogState extends State<CustomerCardDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  final dio = Dio();

  Future<void> _searchCard() async {
    final cardNumber = _controller.text.trim();
    if (cardNumber.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Assuming the API endpoint is /customers/card/{cardNumber} or similar
      // The user mentioned "/api/" but it was cut off. We'll use /customers here.
      final response = await dio.get("$API_URL/customers/$cardNumber");

      final data = response.data;
      if (data == null) {
        throw Exception("Customer not found");
      }

      String customerId;
      String customerName;

      if (data is List) {
        if (data.isEmpty) throw Exception("Customer not found");
        customerId = data.first['id'].toString();
        customerName = data.first['name'].toString();
      } else {
        customerId = data['id'].toString();
        customerName = data['name'].toString();
      }

      final state = makeTransactionRef(context);
      state.customerId.value = customerId;
      state.customerName.value = customerName;

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        if (e is DioException) {
          _error = e.response?.data?.toString() ?? "Customer not found";
        } else {
          _error = "Customer not found";
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Input Customer Card"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Card Number",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.credit_card),
            ),
            onSubmitted: (_) => _searchCard(),
            autofocus: true,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("CANCEL"),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _searchCard,
          child: const Text("SEARCH"),
        ),
      ],
    );
  }
}
