import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:aybay_flutter/models/transaction_model.dart';
import 'package:aybay_flutter/models/cloud_event_model.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class ExportService {
  
  static Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      bool storage = await Permission.storage.request().isGranted;
      bool manage = await Permission.manageExternalStorage.request().isGranted;
      return storage || manage;
    }
    return true; // Web or iOS can be handled differently
  }

  static Future<String?> _getDownloadPath() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download';
    }
    // Fallback for other platforms not explicitly handled here
    return null; 
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.black87));
  }

  static Future<void> exportToExcel({
    required List<TransactionModel> transactions,
    required BuildContext context,
    required String currencySymbol,
    required String reportPeriod,
  }) async {
    if (!await _requestPermission()) {
      _showSnackbar(context, 'Storage permission denied');
      return;
    }

    final path = await _getDownloadPath();
    if (path == null) {
      _showSnackbar(context, 'Downloads folder not found');
      return;
    }

    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Analytics'];
      excel.delete('Sheet1');
      
      // Header
      sheet.appendRow([
        TextCellValue('Report Period: $reportPeriod'),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
      ]);
      sheet.appendRow([
        TextCellValue('Date'),
        TextCellValue('Title'),
        TextCellValue('Category'),
        TextCellValue('Type'),
        TextCellValue('Amount (${currencySymbol == '৳' ? 'BDT' : currencySymbol})'),
      ]);

      // Data
      for (var tx in transactions) {
        sheet.appendRow([
          TextCellValue(tx.date),
          TextCellValue(tx.title),
          TextCellValue(tx.category),
          TextCellValue(tx.type.toUpperCase()),
          TextCellValue(tx.amount.toStringAsFixed(2)),
        ]);
      }

      String fileName = 'AyBay_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      String fullPath = '$path/$fileName';
      File(fullPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      _showSnackbar(context, 'Excel saved to Downloads: $fileName');
    } catch (e) {
      _showSnackbar(context, 'Error exporting Excel: $e');
    }
  }

  static Future<void> exportToPdf({
    required List<TransactionModel> transactions,
    required BuildContext context,
    required String currencySymbol,
    required String reportPeriod,
  }) async {
    if (!await _requestPermission()) {
      _showSnackbar(context, 'Storage permission denied');
      return;
    }

    final path = await _getDownloadPath();
    if (path == null) {
      _showSnackbar(context, 'Downloads folder not found');
      return;
    }

    try {
      final pdf = pw.Document();
      
      // Load logo
      pw.MemoryImage? logoImage;
      try {
        final ByteData data = await rootBundle.load('assets/images/aybay-logo.png');
        logoImage = pw.MemoryImage(data.buffer.asUint8List());
      } catch (e) {
        debugPrint('Could not load logo for PDF: $e');
      }
      
      // Fix Taka symbol rendering for PDF standard fonts
      String safeCurrencySymbol = currencySymbol;
      if (safeCurrencySymbol == '৳') {
        safeCurrencySymbol = 'BDT';
      }

      // Simple Table layout
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('AyBay Analytics Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    if (logoImage != null)
                      pw.Container(
                        height: 40,
                        child: pw.Image(logoImage),
                      )
                  ]
                ),
              ),
              pw.Paragraph(text: 'Generated on: ${DateFormat.yMMMd().format(DateTime.now())}'),
              pw.Paragraph(text: 'Period: $reportPeriod', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Date', 'Title', 'Category', 'Type', 'Amount (${safeCurrencySymbol})'],
                data: transactions.map((tx) => [
                  tx.date,
                  tx.title,
                  tx.category,
                  tx.type.toUpperCase(),
                  tx.amount.toStringAsFixed(2)
                ]).toList(),
              ),
            ];
          },
        ),
      );

      String fileName = 'AyBay_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      String fullPath = '$path/$fileName';
      final file = File(fullPath);
      await file.writeAsBytes(await pdf.save());

      _showSnackbar(context, 'PDF saved to Downloads: $fileName');
    } catch (e) {
      _showSnackbar(context, 'Error exporting PDF: $e');
    }
  }

  static Future<void> exportEventToExcel({
    required List<CloudEventExpenseModel> expenses,
    required BuildContext context,
    required String currencySymbol,
    required String eventName,
  }) async {
    if (!await _requestPermission()) {
      _showSnackbar(context, 'Storage permission denied');
      return;
    }

    final path = await _getDownloadPath();
    if (path == null) {
      _showSnackbar(context, 'Downloads folder not found');
      return;
    }

    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Analytics'];
      excel.delete('Sheet1');
      
      sheet.appendRow([
        TextCellValue('Event: $eventName'),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
      ]);
      sheet.appendRow([
        TextCellValue('Date'),
        TextCellValue('Added By'),
        TextCellValue('Title'),
        TextCellValue('Amount (${currencySymbol == '৳' ? 'BDT' : currencySymbol})'),
      ]);

      for (var exp in expenses) {
        sheet.appendRow([
          TextCellValue('${exp.timestamp.day}/${exp.timestamp.month}/${exp.timestamp.year}'),
          TextCellValue(exp.addedByName),
          TextCellValue(exp.description),
          TextCellValue(exp.amount.toStringAsFixed(2)),
        ]);
      }

      String fileName = 'AyBay_Event_${eventName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      String fullPath = '$path/$fileName';
      File(fullPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      _showSnackbar(context, 'Excel saved to Downloads: $fileName');
    } catch (e) {
      _showSnackbar(context, 'Error exporting Excel: $e');
    }
  }

  static Future<void> exportEventToPdf({
    required List<CloudEventExpenseModel> expenses,
    required BuildContext context,
    required String currencySymbol,
    required String eventName,
  }) async {
    if (!await _requestPermission()) {
      _showSnackbar(context, 'Storage permission denied');
      return;
    }

    final path = await _getDownloadPath();
    if (path == null) {
      _showSnackbar(context, 'Downloads folder not found');
      return;
    }

    try {
      final pdf = pw.Document();
      
      pw.MemoryImage? logoImage;
      try {
        final ByteData data = await rootBundle.load('assets/images/aybay-logo.png');
        logoImage = pw.MemoryImage(data.buffer.asUint8List());
      } catch (e) {}
      
      String safeCurrencySymbol = currencySymbol;
      if (safeCurrencySymbol == '৳') {
        safeCurrencySymbol = 'BDT';
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Event Ledger: $eventName', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    if (logoImage != null)
                      pw.Container(
                        height: 40,
                        child: pw.Image(logoImage),
                      )
                  ]
                ),
              ),
              pw.Paragraph(text: 'Generated on: ${DateFormat.yMMMd().format(DateTime.now())}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Date', 'Added By', 'Title', 'Amount (${safeCurrencySymbol})'],
                data: expenses.map((exp) => [
                  '${exp.timestamp.day}/${exp.timestamp.month}/${exp.timestamp.year}',
                  exp.addedByName,
                  exp.description,
                  exp.amount.toStringAsFixed(2)
                ]).toList(),
              ),
            ];
          },
        ),
      );

      String fileName = 'AyBay_Event_${eventName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      String fullPath = '$path/$fileName';
      final file = File(fullPath);
      await file.writeAsBytes(await pdf.save());

      _showSnackbar(context, 'PDF saved to Downloads: $fileName');
    } catch (e) {
      _showSnackbar(context, 'Error exporting PDF: $e');
    }
  }
}
