import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shop_owner_provider.dart';
import '../../models/shop_owner_model.dart';
import '../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final Map<String, int> _cart = {}; // productId -> quantity
  double _discount = 0.0;
  String? _selectedCustomerId;

  double _calculateTotal(List<ProductModel> products) {
    double total = 0;
    _cart.forEach((id, qty) {
      final p = products.firstWhere((p) => p.id == id);
      total += (p.price * qty);
    });
    return total;
  }



  Future<void> _generateInvoice(List<SaleItem> items, double total, bool share, String shopName, double discount) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd MMM yyyy HH:mm').format(DateTime.now());

    pw.MemoryImage? logoImage;
    try {
      final ByteData bytes = await rootBundle.load('assets/images/aybay-logo.png');
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (e) {
      // Handle missing logo gracefully
    }

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
              pw.SizedBox(height: 8),
              pw.Text(shopName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('POS Receipt', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 12),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 5),

              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Receipt No:', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Date:', style: const pw.TextStyle(fontSize: 10)),
                pw.Text(dateStr, style: const pw.TextStyle(fontSize: 10)),
              ]),
              
              pw.SizedBox(height: 5),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 5),

              // Items Header
              pw.Row(
                children: [
                  pw.Expanded(flex: 3, child: pw.Text('Item', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 1, child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 2, child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                ]
              ),
              pw.SizedBox(height: 5),

              // Items
              ...items.map((i) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 3, child: pw.Text(i.productName, style: const pw.TextStyle(fontSize: 10))),
                    pw.Expanded(flex: 1, child: pw.Text(i.quantity.toString(), textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10))),
                    pw.Expanded(flex: 2, child: pw.Text('Tk. ${(i.price * i.quantity).toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10))),
                  ]
                ),
              )),

              pw.SizedBox(height: 5),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 5),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('SUBTOTAL:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Tk. ${(total + discount).toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              if (discount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('DISCOUNT:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                    pw.Text('-Tk. ${discount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                  ],
                ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GRAND TOTAL:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Tk. ${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              
              pw.SizedBox(height: 15),
              pw.Text('Thank you for shopping!', style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic)),
              pw.Text('Powered by AyBay', style: const pw.TextStyle(fontSize: 8)),
            ],
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    if (share) {
      await Printing.sharePdf(bytes: bytes, filename: 'Invoice_${DateTime.now().millisecondsSinceEpoch}.pdf');
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat f) async => bytes,
        name: 'Invoice_${DateTime.now().millisecondsSinceEpoch}',
        format: format,
      );
    }
  }

  void _showCheckoutDialog(List<ProductModel> products) {
    if (_cart.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Checkout Complete'),
        content: const Text('Sale recorded successfully. Would you like to generate a receipt?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _generateInvoiceOptions(products, false, skipPdf: true);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _generateInvoiceOptions(products, false);
            },
            child: const Text('Print'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _generateInvoiceOptions(products, true);
            },
            child: const Text('Share/Download'),
          ),
        ],
      ),
    );
  }

  void _generateInvoiceOptions(List<ProductModel> products, bool share, {bool skipPdf = false}) async {
    final items = <SaleItem>[];
    _cart.forEach((id, qty) {
      final p = products.firstWhere((p) => p.id == id);
      items.add(SaleItem(
        productId: p.id!,
        productName: p.name,
        quantity: qty,
        price: p.price,
        cost: p.cost,
      ));
    });

    await Provider.of<ShopOwnerProvider>(context, listen: false).recordSale(items, discount: _discount, customerId: _selectedCustomerId);
    
    if (!skipPdf) {
      await _generateInvoice(items, _calculateTotal(products) - _discount, share, Provider.of<ShopOwnerProvider>(context, listen: false).shopName ?? 'My Shop', _discount);
    }

    setState(() {
      _cart.clear();
      _discount = 0.0;
      _selectedCustomerId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopProv = Provider.of<ShopOwnerProvider>(context);
    final products = shopProv.products;
    final total = _calculateTotal(products);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('POS Checkout'), backgroundColor: AppColors.orange, foregroundColor: Colors.white),
      body: Column(
        children: [
          // Product Grid
        Expanded(
          flex: 2,
          child: products.isEmpty
              ? const Center(child: Text('No products in inventory'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    final bool isLowStock = p.stock <= 5;

                    return InkWell(
                      onTap: () {
                        if (p.stock > (_cart[p.id] ?? 0)) {
                          setState(() {
                            _cart[p.id!] = (_cart[p.id] ?? 0) + 1;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Out of stock!')),
                          );
                        }
                      },
                      child: Card(
                        color: AppColors.orange.withValues(alpha: 0.1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isLowStock ? Colors.red : AppColors.orange.withValues(alpha: 0.5), width: isLowStock ? 2 : 1)),
                        child: Stack(
                          children: [
                            if (p.imagePath != null)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Opacity(
                                    opacity: 0.2, // background image
                                    child: Image.file(File(p.imagePath!), fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('৳${p.price.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(child: FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text('Stock: ${p.stock}', style: TextStyle(color: isLowStock ? Colors.red : Colors.grey, fontSize: 12, fontWeight: isLowStock ? FontWeight.bold : null)))),
                                      if (isLowStock)
                                        const Icon(Icons.warning, color: Colors.red, size: 16),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        
        // Cart Area
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Column(
            children: [
              Expanded(
                child: _cart.isEmpty
                    ? const Center(child: Text('Cart is empty', style: TextStyle(color: Colors.grey)))
                    : ListView(
                        children: _cart.entries.map((e) {
                          final p = products.firstWhere((p) => p.id == e.key);
                          return ListTile(
                            title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text('৳${p.price.toStringAsFixed(2)} x ${e.value}'),
                            trailing: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      if (_cart[p.id!]! > 1) {
                                        _cart[p.id!] = _cart[p.id!]! - 1;
                                      } else {
                                        _cart.remove(p.id);
                                      }
                                    });
                                  },
                                ),
                                Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    if (p.stock > e.value) {
                                      setState(() {
                                        _cart[p.id!] = e.value + 1;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Customer', isDense: true, border: OutlineInputBorder()),
                  value: _selectedCustomerId,
                  items: shopProv.customers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _selectedCustomerId = v),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: AppColors.orange,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text('Total: ৳${(total - _discount).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.orange),
                      onPressed: _cart.isEmpty ? null : () => _showCheckoutDialog(products),
                      child: const Text('Checkout'),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        ),
      ],
    ),
    );
  }
}
