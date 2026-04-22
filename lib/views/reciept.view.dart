import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pos_terminal/states/make_transaction.state.dart';
import 'package:pos_terminal/states/auth.state.dart';

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
                  "<POINT OF SALE>",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Date: $formattedDate"),
              pw.Text("Receipt No: $transactionId"),
              pw.Text("Cashier: $cashierName"),
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
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  pw.Text(
                    "P${cartState.overallTotal.value.toStringAsFixed(2)}",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reciept")),
      body: PdfPreview(
        initialPageFormat: PdfPageFormat.roll57,
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
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => doc.save(),
                name: 'Receipt',
              );
            },
            icon: const Icon(Icons.print),
            label: const Text("Print Receipt"),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: "print_new",
            onPressed: () async {
              final doc = await generateReciept(context);
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => doc.save(),
                name: 'Receipt',
              );
              makeTransactionRef(context).startNewTransaction();
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
            label: const Text("Print & New Transaction"),
          ),
        ],
      ),
    );
  }
}
