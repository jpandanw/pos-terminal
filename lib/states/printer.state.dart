import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

enum PaperType {
  mm58,
  mm80,
  xmPaper;

  String get displayName {
    switch (this) {
      case PaperType.mm58:
        return '58mm';
      case PaperType.mm80:
        return '80mm';
      case PaperType.xmPaper:
        return 'XM Paper';
    }
  }

  double get width {
    switch (this) {
      case PaperType.mm58:
        return 58.0;
      case PaperType.mm80:
      case PaperType.xmPaper:
        return 80.0;
    }
  }
}

class PrinterState extends Disposable {
  final BuildContext context;
  PrinterState(this.context);

  final selectedPrinter = signal<Printer?>(null);
  final useDirectPrint = signal<bool>(true);
  final isInitialized = signal<bool>(false);
  final paperType = signal<PaperType>(PaperType.xmPaper);

  static const String _printerKey = 'saved_printer';
  static const String _directPrintKey = 'use_direct_print';
  static const String _paperTypeKey = 'paper_type';

  /// Initialize and load saved printer from local storage.
  Future<void> init() async {
    if (isInitialized.value) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load direct print preference
      useDirectPrint.value = prefs.getBool(_directPrintKey) ?? true;

      // Load paper type preference
      final savedPaperType = prefs.getString(_paperTypeKey);
      if (savedPaperType != null) {
        paperType.value = PaperType.values.firstWhere(
          (e) => e.name == savedPaperType,
          orElse: () => PaperType.xmPaper,
        );
      } else {
        // Fallback for older version which used double paper_size
        final oldDouble = prefs.getDouble('paper_size');
        if (oldDouble == 58.0) {
          paperType.value = PaperType.mm58;
        } else {
          paperType.value = PaperType.xmPaper;
        }
      }

      // Load printer
      final printerJson = prefs.getString(_printerKey);
      if (printerJson != null) {
        final Map<String, dynamic> map = jsonDecode(printerJson);
        selectedPrinter.value = Printer.fromMap(map);
      }
    } catch (e) {
      debugPrint('Error initializing PrinterState: $e');
    } finally {
      isInitialized.value = true;
    }
  }

  /// Let the user pick a printer using the system dialog and save it locally.
  Future<Printer?> pickAndSavePrinter() async {
    try {
      final printer = await Printing.pickPrinter(context: context);
      if (printer != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_printerKey, jsonEncode(printer.toMap()));
        selectedPrinter.value = printer;
        return printer;
      }
    } catch (e) {
      debugPrint('Error picking printer: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick printer: $e')),
        );
      }
    }
    return null;
  }

  /// Clear the saved printer from local storage.
  Future<void> clearSavedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_printerKey);
      selectedPrinter.value = null;
    } catch (e) {
      debugPrint('Error clearing saved printer: $e');
    }
  }

  /// Toggle direct printing preference.
  Future<void> setUseDirectPrint(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_directPrintKey, value);
      useDirectPrint.value = value;
    } catch (e) {
      debugPrint('Error saving direct print preference: $e');
    }
  }

  /// Set paper type preference.
  Future<void> setPaperType(PaperType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_paperTypeKey, type.name);
      paperType.value = type;
    } catch (e) {
      debugPrint('Error saving paper type preference: $e');
    }
  }

  /// Print a PDF document. If direct print is enabled and a printer is saved,
  /// it will print directly to the saved printer. Otherwise, it will fallback
  /// to the system print preview dialog.
  Future<bool> printDocument(
    dynamic docBytesOrDocument, {
    String name = 'Receipt',
  }) async {
    // Ensure state is initialized
    await init();

    final printer = selectedPrinter.value;
    final direct = useDirectPrint.value;

    // Helper to get PDF bytes
    Future<Uint8List> getBytes() async {
      if (docBytesOrDocument is Uint8List) {
        return docBytesOrDocument;
      }
      if (docBytesOrDocument is List<int>) {
        return Uint8List.fromList(docBytesOrDocument);
      }
      // Assuming it's pw.Document
      return await docBytesOrDocument.save();
    }

    if (direct && printer != null) {
      try {
        debugPrint('Attempting direct print to: ${printer.name} (${printer.url})');
        
        // Find matching printer from active list if possible to avoid stale references
        Printer targetPrinter = printer;
        final info = await Printing.info();
        if (info.canListPrinters) {
          final activePrinters = await Printing.listPrinters();
          final match = activePrinters.firstWhere(
            (p) => p.url == printer.url,
            orElse: () => printer,
          );
          targetPrinter = match;
        }

        final success = await Printing.directPrintPdf(
          printer: targetPrinter,
          onLayout: (format) async => await getBytes(),
          name: name,
        );

        if (success) {
          return true;
        } else {
          debugPrint('Direct print failed, falling back to layoutPdf');
        }
      } catch (e) {
        debugPrint('Direct print error: $e. Falling back to layoutPdf');
      }
    }

    // Fallback to layoutPdf
    try {
      final success = await Printing.layoutPdf(
        onLayout: (format) async => await getBytes(),
        name: name,
      );
      return success;
    } catch (e) {
      debugPrint('Layout print error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to print: $e')),
        );
      }
      return false;
    }
  }

  @override
  void dispose() {
    selectedPrinter.dispose();
    useDirectPrint.dispose();
    isInitialized.dispose();
  }
}

final printerStateRef = Ref.scoped((context) => PrinterState(context));
