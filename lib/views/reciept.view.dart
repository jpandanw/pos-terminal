import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/states/auth.state.dart';
import 'package:pos_terminal/states/printer.state.dart';
import 'package:signals/signals_flutter.dart';

class RecieptView extends StatelessWidget {
  const RecieptView({super.key});

  Future<pw.Document> generateReciept(BuildContext context) async {
    final cartState = makeTransactionRef(context);
    final authState = authStateRef(context);
    final cashierName = authState.cashier.value?.name ?? "____________________";

    final font = await PdfGoogleFonts.robotoMonoRegular();
    final boldFont = await PdfGoogleFonts.robotoMonoBold();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
      ).copyWith(defaultTextStyle: pw.TextStyle(font: font, fontSize: 8)),
    );

    final sortedCart = cartState.cart.toList()
      ..sort((a, b) => a.product.name.compareTo(b.product.name));

    final String transactionId =
        "TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
    final String formattedDate = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(DateTime.now());

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "XM GROCERY",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.Text("Purok 1, Sayre Highway, Kisolon, Sumilao, Bukidnon"),
              pw.SizedBox(height: 10),
              pw.Text("Date: $formattedDate"),
              pw.Text("Receipt No: $transactionId"),
              pw.Text("Cashier: $cashierName"),
              if (cartState.customerName.value != null)
                pw.Text("Customer: ${cartState.customerName.value}"),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 5),
              ...sortedCart.map((item) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text("${item.product.name} x${item.quantity}"),
                    ),
                    pw.Text(
                      "P${(item.product.price * item.quantity).toStringAsFixed(2)}",
                    ),
                  ],
                );
              }),
              pw.SizedBox(height: 5),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              if (cartState.modifiers.value.isNotEmpty) ...[
                ...cartState.modifiers.value.map((m) {
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(m.name),
                      pw.Text(
                        m.type.name == 'percentage'
                            ? "${m.amount}%"
                            : "P${m.amount.toStringAsFixed(2)}",
                      ),
                    ],
                  );
                }),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
              ],
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Subtotal:"),
                  pw.Text("P${cartState.cartTotal.value.toStringAsFixed(2)}"),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Total Amount:",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    "P${cartState.overallTotal.value.toStringAsFixed(2)}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Cash:"),
                  pw.Text(
                    "P${cartState.customerMoney.value?.toStringAsFixed(2) ?? '0.00'}",
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Change:"),
                  pw.Text(
                    "P${cartState.change.value?.toStringAsFixed(2) ?? '0.00'}",
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Center(child: pw.Text("Thank you, come again!")),
            ],
          );
        },
      ),
    );

    return doc;
  }

  void _showPrinterSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Watch((context) {
          final printerState = printerStateRef(context);
          final printer = printerState.selectedPrinter.value;
          final direct = printerState.useDirectPrint.value;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Printer Settings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Card(
                    elevation: 0,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: printer != null
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.print,
                            color: printer != null
                                ? Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        title: Text(
                          printer != null
                              ? printer.name
                              : 'No printer selected',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          printer != null
                              ? '${printer.model ?? "Unknown Model"}\nURL: ${printer.url}'
                              : 'Prints via system dialog',
                        ),
                        isThreeLine: printer != null,
                        trailing: printer != null
                            ? IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await printerState.clearSavedPrinter();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await printerState.pickAndSavePrinter();
                    },
                    icon: const Icon(Icons.search),
                    label: Text(
                      printer == null
                          ? 'Select / Pick Printer'
                          : 'Change Printer',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (printer != null) ...[
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Direct Printing',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Bypass system dialog and print directly',
                      ),
                      value: direct,
                      onChanged: (val) async {
                        await printerState.setUseDirectPrint(val);
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Proactively initialize printer state
    printerStateRef(context).init();

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        if (event.logicalKey == LogicalKeyboardKey.enter) {
          if (HardwareKeyboard.instance.isShiftPressed) {
            // SHIFT + ENTER to make new transaction (no printing)
            makeTransactionRef(context).startNewTransaction();
            if (context.mounted) Navigator.pop(context);
            return KeyEventResult.handled;
          } else {
            // ENTER to print and new
            generateReciept(context).then((doc) async {
              await printerStateRef(
                context,
              ).printDocument(doc, name: 'Receipt');
              makeTransactionRef(context).startNewTransaction();
              if (context.mounted) Navigator.pop(context);
            });
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Reciept"),
          actions: [
            Watch((context) {
              final printer = printerStateRef(context).selectedPrinter.value;
              final direct = printerStateRef(context).useDirectPrint.value;
              return IconButton(
                icon: Icon(
                  printer == null
                      ? Icons.print_disabled_outlined
                      : (direct ? Icons.print : Icons.print_outlined),
                  color: printer == null
                      ? Theme.of(context).colorScheme.outline
                      : Theme.of(context).colorScheme.primary,
                ),
                tooltip: printer == null
                    ? "Select printer"
                    : "Printer: ${printer.name} (${direct ? 'Direct' : 'Dialog'})",
                onPressed: () => _showPrinterSettings(context),
              );
            }),
          ],
        ),
        body: PdfPreview(
          initialPageFormat: PdfPageFormat.roll80,
          maxPageWidth: 400,
          useActions: false,
          build: (format) async {
            final doc = await generateReciept(context);
            return doc.save();
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: "print",
              onPressed: () async {
                final doc = await generateReciept(context);
                await printerStateRef(
                  context,
                ).printDocument(doc, name: 'Receipt');
              },
              icon: const Icon(Icons.print),
              label: const Text("Print Receipt"),
            ),
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              heroTag: "print_new",
              onPressed: () async {
                final doc = await generateReciept(context);
                await printerStateRef(
                  context,
                ).printDocument(doc, name: 'Receipt');
                makeTransactionRef(context).startNewTransaction();
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "ENTER",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  const Text("Print & New Transaction"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              heroTag: "new_transaction",
              onPressed: () {
                makeTransactionRef(context).startNewTransaction();
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "SHIFT + ENTER",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  const Text("Make New Transaction"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
