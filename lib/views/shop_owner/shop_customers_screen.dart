import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shop_owner_provider.dart';
import '../../models/shop_owner_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/theme_provider.dart';

class ShopCustomersScreen extends StatefulWidget {
  const ShopCustomersScreen({super.key});

  @override
  State<ShopCustomersScreen> createState() => _ShopCustomersScreenState();
}

class _ShopCustomersScreenState extends State<ShopCustomersScreen> {
  void _showCustomerDialog([CustomerModel? existingCustomer]) {
    final nameCtrl = TextEditingController(text: existingCustomer?.name ?? '');
    final phoneCtrl =
        TextEditingController(text: existingCustomer?.phone ?? '');
    final debtCtrl = TextEditingController(
        text:
            existingCustomer != null ? existingCustomer.debt.toString() : '0');
    final isEdit = existingCustomer != null;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Customer / Khata' : 'Add Customer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                if (isEdit) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: debtCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Outstanding Debt (Khata)'),
                  ),
                ]
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                final debt = double.tryParse(debtCtrl.text.trim()) ?? 0.0;

                if (name.isNotEmpty) {
                  final prov =
                      Provider.of<ShopOwnerProvider>(context, listen: false);
                  if (isEdit) {
                    await prov.updateCustomer(existingCustomer!
                        .copyWith(name: name, phone: phone, debt: debt));
                  } else {
                    await prov.addCustomer(
                        CustomerModel(name: name, phone: phone, debt: 0.0));
                  }
                  if (mounted) Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ShopOwnerProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);
    final sym = themeProv.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers & Khata'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: prov.customers.isEmpty
          ? const Center(child: Text('No customers added yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prov.customers.length,
              itemBuilder: (context, index) {
                final c = prov.customers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person, color: Colors.white)),
                    title: Text(c.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(c.phone),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Due',
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(
                          CurrencyFormatter.formatSimple(c.debt, sym),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: c.debt > 0 ? AppColors.red : Colors.grey,
                              fontSize: 14),
                        ),
                      ],
                    ),
                    onTap: () => _showCustomerDialog(c),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
