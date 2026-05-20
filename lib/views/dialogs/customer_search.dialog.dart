import 'package:flutter/material.dart';
import 'package:pos_terminal/data/server/fetch_customer_by_card.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';

class CustomerSearchDialog extends StatefulWidget {
  const CustomerSearchDialog({super.key});

  @override
  State<CustomerSearchDialog> createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends State<CustomerSearchDialog> {
  final _controller = TextEditingController();

  bool _isLoading = false;
  CustomerInfo? _foundCustomer;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final cardId = _controller.text.trim();
    if (cardId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _foundCustomer = null;
      _errorMessage = null;
    });

    final result = await fetchCustomerByCard(cardId);

    if (!mounted) return;

    result.fold(
      (customer) => setState(() {
        _foundCustomer = customer;
        _isLoading = false;
      }),
      (error) => setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      }),
    );
  }

  void _confirm(BuildContext context) {
    if (_foundCustomer == null) return;

    final cartState = makeTransactionRef(context);
    cartState.customerId.value = _foundCustomer!.id;
    cartState.customerName.value = _foundCustomer!.fullName;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Customer linked: ${_foundCustomer!.fullName}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _remove(BuildContext context) {
    final cartState = makeTransactionRef(context);
    cartState.customerId.value = null;
    cartState.customerName.value = null;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.person_search, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Search Customer'),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Search field ---
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Card ID',
                hintText: 'Scan or enter card ID',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.credit_card),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _search,
                        tooltip: 'Search',
                      ),
              ),
              onSubmitted: (_) => _search(),
            ),

            const SizedBox(height: 16),

            // --- Error message ---
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.onErrorContainer,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),

            // --- Customer card result ---
            if (_foundCustomer != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.primary, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            _foundCustomer!.firstName[0].toUpperCase(),
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _foundCustomer!.fullName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                'ID: ${_foundCustomer!.id.substring(0, 8)}...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.credit_card,
                      label: 'Card',
                      value: _foundCustomer!.card.cardId,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.stars_rounded,
                      label: 'Points',
                      value: _foundCustomer!.currentPoints.toStringAsFixed(2),
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: _foundCustomer!.card.status == 'ACTIVE'
                          ? Icons.check_circle
                          : Icons.cancel,
                      label: 'Card Status',
                      value: _foundCustomer!.card.status,
                      colorScheme: colorScheme,
                      valueColor: _foundCustomer!.card.status == 'ACTIVE'
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        // Remove customer button (if one is already linked)
        TextButton.icon(
          onPressed: () => _remove(context),
          icon: const Icon(Icons.person_remove),
          label: const Text('Remove Customer'),
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: (_foundCustomer != null &&
                  _foundCustomer!.card.status == 'ACTIVE')
              ? () => _confirm(context)
              : null,
          icon: const Icon(Icons.person_add),
          label: const Text('Link Customer'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor ?? colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}
