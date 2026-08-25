import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../models/gym_member_model.dart';
import '../../models/gym_payment_model.dart';

class GymReportPdf {
  static Future<void> generateAndShareReport(
      List<GymMemberModel> members,
      List<GymPaymentModel> payments,
      String gymName,
      String currencySymbol) async {
    final pdf = pw.Document();

    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    final activeMembers = members.where((m) => m.status == 'Active').toList();
    final expiredMembers = members.where((m) => m.status == 'Expired').toList();

    double totalRevenue = 0;
    for (var p in payments) {
      totalRevenue += p.amount;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(gymName.toUpperCase(),
                        style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue)),
                    pw.SizedBox(height: 4),
                    pw.Text('Gym Global Report',
                        style: const pw.TextStyle(
                            fontSize: 14, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Generated: $dateStr',
                        style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Summary
            pw.Text('Summary',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Active Members:',
                    style: const pw.TextStyle(fontSize: 14)),
                pw.Text(activeMembers.length.toString(),
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Expired Members:',
                    style: const pw.TextStyle(fontSize: 14)),
                pw.Text(expiredMembers.length.toString(),
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Lifetime Revenue:',
                    style: const pw.TextStyle(fontSize: 16)),
                pw.Text('$currencySymbol${totalRevenue.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue)),
              ],
            ),
            pw.SizedBox(height: 30),

            // Member Table
            pw.Text('Active Members Directory',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.SizedBox(height: 10),

            if (activeMembers.isNotEmpty)
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
                data: <List<String>>[
                  ['Name', 'Phone', 'Plan', 'Expires', 'Trainer'],
                  ...activeMembers.map((m) => [
                        m.name,
                        m.phone,
                        m.planType,
                        DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(m.expiryDate)),
                        m.assignedTrainer ?? 'None'
                      ]),
                ],
              )
            else
              pw.Text('No active members found.',
                  style: const pw.TextStyle(color: PdfColors.grey)),
          ];
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'gym_report_$dateStr.pdf');
  }
}
