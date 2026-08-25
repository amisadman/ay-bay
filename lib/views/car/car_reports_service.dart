import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import '../../models/car_model.dart';
import 'package:share_plus/share_plus.dart';

class CarReportsService {
  static Future<void> generatePdfReport(CarModel car) async {
    final pdf = pw.Document();

    List<dynamic> logs = [];
    try {
      logs = jsonDecode(car.expenses);
    } catch (e) {
      // ignore
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Car Report: ${car.carName}',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text('License Plate: ${car.licensePlate}',
              style: const pw.TextStyle(fontSize: 16)),
          pw.Text(
              'Report Generated: ${DateTime.now().toIso8601String().split('T')[0]}',
              style:
                  const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Type', 'Date', 'Amount', 'Note / Details'],
            data: logs.map((log) {
              final type = log['type']?.toString().toUpperCase() ?? 'LOG';
              final date = log['date']?.toString() ?? '-';
              final amount =
                  log['amount'] != null ? 'BDT ${log['amount']}' : '-';

              String details = log['note'] ?? '';
              if (type == 'FUEL') {
                details = 'Vol: ${log['volume']}L, Odo: ${log['odometer']}km';
              } else if (type == 'MAINTENANCE' && log['reminderDate'] != null) {
                details += ' (Next: ${log['reminderDate']})';
              } else if (type == 'INSURANCE' && log['expiryDate'] != null) {
                details += ' (Exp: ${log['expiryDate']})';
              }

              return [type, date, amount, details];
            }).toList(),
          ),
        ],
      ),
    );

    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } else {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/car_report_${car.carName}.pdf');
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)],
          text: 'Car Report for ${car.carName}');
    }
  }

  static Future<void> generateExcelReport(CarModel car) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow([
      TextCellValue('Type'),
      TextCellValue('Date'),
      TextCellValue('Amount'),
      TextCellValue('Note / Details')
    ]);

    List<dynamic> logs = [];
    try {
      logs = jsonDecode(car.expenses);
    } catch (e) {
      // ignore
    }

    for (var log in logs) {
      final type = log['type']?.toString().toUpperCase() ?? 'LOG';
      final date = log['date']?.toString() ?? '-';
      final amount = log['amount']?.toString() ?? '-';

      String details = log['note'] ?? '';
      if (type == 'FUEL') {
        details = 'Vol: ${log['volume']}L, Odo: ${log['odometer']}km';
      } else if (type == 'MAINTENANCE' && log['reminderDate'] != null) {
        details += ' (Next: ${log['reminderDate']})';
      } else if (type == 'INSURANCE' && log['expiryDate'] != null) {
        details += ' (Exp: ${log['expiryDate']})';
      }

      sheetObject.appendRow([
        TextCellValue(type),
        TextCellValue(date),
        TextCellValue(amount),
        TextCellValue(details),
      ]);
    }

    if (kIsWeb) {
      // Excel package web save workaround if needed, or just let excel.save() handle it
      excel.save(fileName: "car_report_${car.carName}.xlsx");
    } else {
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final output = await getTemporaryDirectory();
        final file = File('${output.path}/car_report_${car.carName}.xlsx');
        await file.writeAsBytes(fileBytes);
        await Share.shareXFiles([XFile(file.path)],
            text: 'Car Excel Report for ${car.carName}');
      }
    }
  }
}
