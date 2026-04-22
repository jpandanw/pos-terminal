import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing_ffi/printing_ffi.dart' as p;

class RecieptView extends StatelessWidget {
  const RecieptView({super.key});

  void printReciept() async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text("asdf", style: pw.TextStyle(fontSize: 32)),
        ),
      ),
    );

    await p.Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reciept")),
      body: Column(
        children: [
          FilledButton(
            onPressed: () {
              printReciept();
            },
            child: const Text("HHH"),
          ),
        ],
      ),
    );
  }
}
