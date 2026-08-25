import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_owner_provider.dart';
import '../../models/apartment_model.dart';
import '../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'edit_apartment_dialog.dart';

class ApartmentProfileScreen extends StatefulWidget {
  final ApartmentModel apartment;
  final String currentMonthKey;

  const ApartmentProfileScreen({
    super.key,
    required this.apartment,
    required this.currentMonthKey,
  });

  @override
  State<ApartmentProfileScreen> createState() => _ApartmentProfileScreenState();
}

class _ApartmentProfileScreenState extends State<ApartmentProfileScreen> {
  late ApartmentModel _apartment;

  @override
  void initState() {
    super.initState();
    _apartment = widget.apartment;
  }

  void _markPaid() async {
    final prov = Provider.of<HomeOwnerProvider>(context, listen: false);
    await prov.markRentPaid(_apartment.id!, widget.currentMonthKey);
    // Reload state
    setState(() {
      _apartment = prov.apartments.firstWhere((a) => a.id == _apartment.id);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rent marked as paid!')),
      );
    }
  }

  Future<void> _deleteApartment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Apartment?'),
        content: const Text(
            'Are you sure you want to delete this apartment? All records will be lost.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) {
        Provider.of<HomeOwnerProvider>(context, listen: false)
            .deleteApartment(_apartment.id!);
        Navigator.pop(context);
      }
    }
  }

  Future<void> _editApartment() async {
    final updated = await showDialog<ApartmentModel>(
      context: context,
      builder: (ctx) => EditApartmentDialog(apartment: _apartment),
    );
    if (updated != null) {
      setState(() {
        _apartment = updated;
      });
    }
  }

  Future<void> _generateReceipt(bool share, String monthKey) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('dd MMM yyyy HH:mm').format(now);

    // Parse monthKey (e.g. "2024-08") to Month Name
    final parts = monthKey.split('-');
    final monthName = DateFormat('MMMM yyyy')
        .format(DateTime(int.parse(parts[0]), int.parse(parts[1])));

    pw.MemoryImage? logoImage;
    try {
      final ByteData bytes =
          await rootBundle.load('assets/images/aybay-logo.png');
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (e) {
      // Handle missing logo gracefully
    }

    // Roll paper format (e.g. 80mm width)
    final format = PdfPageFormat.roll80;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logoImage != null) pw.Image(logoImage, width: 80),
              pw.SizedBox(height: 12),
              pw.Text('RENT RECEIPT',
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline)),
              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 5),

              // Key-Value rows
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Receipt No:',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        'REC-${now.millisecondsSinceEpoch.toString().substring(8)}',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ]),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Date:', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(dateStr, style: const pw.TextStyle(fontSize: 10)),
                  ]),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Rent Period:',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(monthName,
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ]),

              pw.SizedBox(height: 5),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 5),

              pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text('Received From:',
                      style: const pw.TextStyle(fontSize: 10))),
              pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(_apartment.boarderName,
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold))),
              pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text('Ph: ${_apartment.boarderPhone}',
                      style: const pw.TextStyle(fontSize: 10))),

              pw.SizedBox(height: 10),
              pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text('For Property:',
                      style: const pw.TextStyle(fontSize: 10))),
              pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(_apartment.name,
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold))),

              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 5),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL PAID:',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Tk. ${_apartment.rentAmount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),

              pw.SizedBox(height: 5),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 15),
              pw.Text('Thank you!',
                  style: pw.TextStyle(
                      fontSize: 12, fontStyle: pw.FontStyle.italic)),
              pw.Text('Powered by AyBay',
                  style: const pw.TextStyle(fontSize: 8)),
            ],
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    if (share) {
      await Printing.sharePdf(
          bytes: bytes, filename: 'Receipt_${_apartment.name}_$monthName.pdf');
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat f) async => bytes,
        name: 'Receipt_${_apartment.name}_$monthName',
        format: format,
      );
    }
  }

  void _showReceiptOptions(String monthKey) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Receipt Options'),
        content: const Text(
            'Would you like to Print this receipt or Share/Download it as a PDF?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _generateReceipt(false, monthKey); // Print
            },
            child: const Text('Print'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepTeal,
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _generateReceipt(true, monthKey); // Share/Download
            },
            child: const Text('Share/Download'),
          ),
        ],
      ),
    );
  }

  void _callBoarder() async {
    final uri = Uri.parse('tel:${_apartment.boarderPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch dialer')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = _apartment.paidMonths.contains(widget.currentMonthKey);
    final monthName = DateFormat('MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_apartment.name),
        backgroundColor: AppColors.deepTeal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editApartment),
          IconButton(
              icon: const Icon(Icons.delete), onPressed: _deleteApartment),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.person, size: 60, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      _apartment.boarderName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _apartment.boarderPhone,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        IconButton(
                          icon: const Icon(Icons.call, color: AppColors.green),
                          onPressed: _callBoarder,
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Monthly Rent',
                            style: TextStyle(fontSize: 16)),
                        Text(
                          '৳${_apartment.rentAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Rent Status Section
            const Text(
              'Rent Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPaid
                    ? AppColors.green.withValues(alpha: 0.1)
                    : AppColors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPaid ? AppColors.green : AppColors.red,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPaid ? Icons.check_circle : Icons.warning_rounded,
                    color: isPaid ? AppColors.green : AppColors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isPaid ? 'Rent Paid' : 'Rent Due',
                          style: TextStyle(
                            color: isPaid ? AppColors.green : AppColors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isPaid)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _markPaid,
                      child: const Text('Mark Paid'),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            if (_apartment.paidMonths.isNotEmpty) ...[
              const Text('Past Receipts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._apartment.paidMonths.map((monthKey) {
                final parts = monthKey.split('-');
                final monthNameStr = DateFormat('MMMM yyyy')
                    .format(DateTime(int.parse(parts[0]), int.parse(parts[1])));
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long,
                        color: AppColors.deepTeal),
                    title: Text(monthNameStr,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _showReceiptOptions(monthKey),
                      child: const Text('Generate'),
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
