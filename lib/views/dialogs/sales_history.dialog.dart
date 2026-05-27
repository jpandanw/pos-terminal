import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_terminal/services/local_sales_storage.dart';

class SalesHistoryDialog extends StatefulWidget {
  const SalesHistoryDialog({super.key});

  @override
  State<SalesHistoryDialog> createState() => _SalesHistoryDialogState();
}

class _SalesHistoryDialogState extends State<SalesHistoryDialog> {
  List<Map<String, dynamic>> _allSales = [];
  List<Map<String, dynamic>> _filteredSales = [];
  bool _isLoading = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    final sales = await LocalSalesStorage.getSales();
    setState(() {
      _allSales = sales;
      _filteredSales = sales;
      _isLoading = false;
    });
  }

  void _filterSalesByDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _filteredSales = _allSales.where((sale) {
        if (sale['timestamp'] == null) return false;
        final saleDate = DateTime.parse(sale['timestamp']).toLocal();
        return saleDate.year == date.year &&
            saleDate.month == date.month &&
            saleDate.day == date.day;
      }).toList();
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedDate = null;
      _filteredSales = _allSales;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Sales History",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (_selectedDate != null)
                      TextButton.icon(
                        onPressed: _clearFilter,
                        icon: const Icon(Icons.clear),
                        label: Text(
                          "Clear Filter: ${DateFormat.yMd().format(_selectedDate!)}",
                        ),
                      ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _filterSalesByDate(picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text("Filter by Date"),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSales.isEmpty
                      ? const Center(child: Text("No sales found."))
                      : ListView.builder(
                          itemCount: _filteredSales.length,
                          itemBuilder: (context, index) {
                            final sale = _filteredSales[index];
                            final timestamp = sale['timestamp'] != null
                                ? DateTime.parse(sale['timestamp']).toLocal()
                                : null;
                            final dateStr = timestamp != null
                                ? DateFormat.yMd().add_jm().format(timestamp)
                                : 'Unknown Date';
                            
                            return Card(
                              child: ExpansionTile(
                                title: Text("Sale: ${sale['saleId']}"),
                                subtitle: Text(
                                  "Total: PHP ${sale['total'].toStringAsFixed(2)} | $dateStr",
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Items",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...(sale['items'] as List).map(
                                          (item) => Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${item['quantity']}x ${item['productName']}",
                                              ),
                                              Text(
                                                "PHP ${(item['sellingPrice'] * item['quantity']).toStringAsFixed(2)}",
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Cash:"),
                                            Text(
                                                "PHP ${sale['customerCash'].toStringAsFixed(2)}"),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Change:"),
                                            Text(
                                                "PHP ${sale['customerChange'].toStringAsFixed(2)}"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
