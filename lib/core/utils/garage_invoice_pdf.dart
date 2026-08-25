import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../models/garage_vehicle_model.dart';

class GarageInvoicePdf {
  static Future<void> generateAndShareInvoice(GarageVehicleModel vehicle,
      String garageName, String currencySymbol) async {
    final pdf = pw.Document();

    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(garageName.toUpperCase(),
                          style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.brown)),
                      pw.SizedBox(height: 4),
                      pw.Text('Auto Repair & Service Invoice',
                          style: const pw.TextStyle(
                              fontSize: 14, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: $dateStr',
                          style: const pw.TextStyle(fontSize: 12)),
                      pw.Text(
                          'Invoice #: ${vehicle.id?.substring(0, 8) ?? 'N/A'}',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Customer Info
              pw.Text('Customer Details',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Text('Name: ${vehicle.clientName}',
                  style: const pw.TextStyle(fontSize: 14)),
              pw.Text('Vehicle: ${vehicle.makeModel}',
                  style: const pw.TextStyle(fontSize: 14)),
              pw.Text('License Plate: ${vehicle.licensePlate}',
                  style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 30),

              // Breakdown
              pw.Text('Service Breakdown',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Parts Table
              if (vehicle.usedParts.isNotEmpty) ...[
                pw.Text('Parts Used:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.TableHelper.fromTextArray(
                  context: context,
                  headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.brown),
                  data: <List<String>>[
                    ['Part Name', 'Qty', 'Unit Price', 'Total'],
                    ...vehicle.usedParts.map((p) => [
                          p['name'].toString(),
                          p['qty'].toString(),
                          '$currencySymbol${p['cost']}',
                          '$currencySymbol${(p['cost'] * p['qty']).toStringAsFixed(2)}',
                        ]),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],

              // Labor
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Labor Cost:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      '$currencySymbol${vehicle.laborCost.toStringAsFixed(2)}'),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total Due: ',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      '$currencySymbol${vehicle.estimatedCost.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.brown)),
                ],
              ),
              pw.SizedBox(height: 40),

              // Footer
              pw.Center(
                child: pw.Text('Thank you for your business!',
                    style: const pw.TextStyle(
                        fontSize: 16, color: PdfColors.grey700)),
              ),
              if (vehicle.mechanicName != null) ...[
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text('Serviced by: ${vehicle.mechanicName}',
                      style: const pw.TextStyle(
                          fontSize: 12, color: PdfColors.grey500)),
                ),
              ]
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'invoice_${vehicle.licensePlate}.pdf');
  }
}
