import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/car_model.dart';
import '../../core/constants/app_colors.dart';
import 'car_reports_service.dart';

class CarProfileScreen extends StatelessWidget {
  final CarModel car;

  const CarProfileScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(car.carName, style: const TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'edit') {
                _showEditCarDialog(context);
              } else if (val == 'delete') {
                _showDeleteCarDialog(context);
              } else if (val == 'report') {
                _showReportOptions(context);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
              const PopupMenuItem(
                  value: 'report', child: Text('Download Report')),
              const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Profile',
                      style: TextStyle(color: Colors.red))),
            ],
          )
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, finProv, child) {
          final currentCar =
              finProv.cars.firstWhere((c) => c.id == car.id, orElse: () => car);

          List<dynamic> logs = [];
          try {
            logs = jsonDecode(currentCar.expenses);
          } catch (e) {
            // ignore
          }

          double totalExpenses = logs
              .where((l) =>
                  l['type'] == 'expense' ||
                  l['type'] == 'fuel' ||
                  l['type'] == 'maintenance' ||
                  l['type'] == 'insurance')
              .fold(
                  0.0,
                  (sum, item) =>
                      sum + ((item['amount'] as num?)?.toDouble() ?? 0.0));

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'License: ${currentCar.licensePlate}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Total Expenses',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '৳${totalExpenses.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: logs.isEmpty
                    ? const Center(
                        child: Text('No logs recorded for this car.',
                            style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          // reverse index to show newest first
                          final actualIndex = logs.length - 1 - index;
                          final log = logs[actualIndex];
                          return _buildLogCard(
                              context, currentCar, actualIndex, log);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Log', style: TextStyle(color: Colors.white)),
        onPressed: () => _showAddLogOptions(context),
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, CarModel currentCar, int logIndex,
      Map<String, dynamic> log) {
    IconData icon;
    Color color;
    String title = '';
    String subtitle = log['date'] ?? '';
    String trailing = '';

    final type = log['type'] ?? 'expense';

    if (type == 'expense') {
      icon = Icons.money_off;
      color = Colors.redAccent;
      title = log['note'] ?? 'Expense';
      trailing = '-৳${(log['amount'] as num).toDouble().toStringAsFixed(2)}';
    } else if (type == 'fuel') {
      icon = Icons.local_gas_station;
      color = Colors.orange;
      title = 'Fuel (${log['volume']}L)';
      subtitle += ' • Odo: ${log['odometer']}';
      trailing = '-৳${(log['amount'] as num).toDouble().toStringAsFixed(2)}';
    } else if (type == 'maintenance') {
      icon = Icons.build;
      color = Colors.brown;
      title = log['note'] ?? 'Maintenance';
      if (log['reminderDate'] != null)
        subtitle += ' • Next: ${log['reminderDate']}';
      if (log['amount'] != null)
        trailing = '-৳${(log['amount'] as num).toDouble().toStringAsFixed(2)}';
    } else if (type == 'insurance') {
      icon = Icons.security;
      color = Colors.blueGrey;
      title = log['note'] ?? 'Insurance';
      if (log['expiryDate'] != null) subtitle += ' • Exp: ${log['expiryDate']}';
      if (log['amount'] != null)
        trailing = '-৳${(log['amount'] as num).toDouble().toStringAsFixed(2)}';
    } else if (type == 'vault') {
      icon = Icons.file_present;
      color = Colors.indigo;
      title = log['note'] ?? 'Document Vault';
    } else {
      icon = Icons.info;
      color = Colors.grey;
      title = 'Log';
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: color, child: Icon(icon, color: Colors.white)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: trailing.isNotEmpty
            ? Text(trailing,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16))
            : null,
        onLongPress: () => _showDeleteLogDialog(context, currentCar, logIndex),
      ),
    );
  }

  void _showAddLogOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.money_off, color: Colors.redAccent),
              title: const Text('General Expense'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddLogDialog(context, 'expense');
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.local_gas_station, color: Colors.orange),
              title: const Text('Fuel Log'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddLogDialog(context, 'fuel');
              },
            ),
            ListTile(
              leading: const Icon(Icons.build, color: Colors.brown),
              title: const Text('Maintenance & Repair'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddLogDialog(context, 'maintenance');
              },
            ),
            ListTile(
              leading: const Icon(Icons.security, color: Colors.blueGrey),
              title: const Text('Insurance & Tax'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddLogDialog(context, 'insurance');
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_present, color: Colors.indigo),
              title: const Text('Document Vault'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddLogDialog(context, 'vault');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLogDialog(BuildContext context, String type) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final volumeCtrl = TextEditingController();
    final odoCtrl = TextEditingController();
    final dateCtrl = TextEditingController(
        text: DateTime.now().toIso8601String().split('T')[0]);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add $type log'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (type != 'vault')
                TextField(
                  controller: amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: 'Amount (৳)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              if (type != 'vault') const SizedBox(height: 12),
              if (type == 'fuel') ...[
                TextField(
                  controller: volumeCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: 'Volume (Liters)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: odoCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: 'Odometer (km)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  labelText: type == 'vault'
                      ? 'Document Name'
                      : (type == 'insurance' ? 'Insurance Provider' : 'Note'),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              if (type == 'maintenance' || type == 'insurance') ...[
                TextField(
                  controller: dateCtrl,
                  decoration: InputDecoration(
                      labelText: type == 'insurance'
                          ? 'Expiry Date (YYYY-MM-DD)'
                          : 'Reminder Date (YYYY-MM-DD)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue, foregroundColor: Colors.white),
            onPressed: () async {
              final finProv =
                  Provider.of<FinanceProvider>(context, listen: false);
              final date = DateTime.now().toIso8601String().split('T')[0];

              Map<String, dynamic> logData = {'type': type, 'date': date};

              if (noteCtrl.text.isNotEmpty)
                logData['note'] = noteCtrl.text.trim();

              if (type == 'fuel') {
                logData['volume'] = double.tryParse(volumeCtrl.text) ?? 0.0;
                logData['odometer'] = double.tryParse(odoCtrl.text) ?? 0.0;
              }

              if (type == 'maintenance') {
                if (dateCtrl.text.isNotEmpty)
                  logData['reminderDate'] = dateCtrl.text.trim();
              }

              if (type == 'insurance') {
                if (dateCtrl.text.isNotEmpty)
                  logData['expiryDate'] = dateCtrl.text.trim();
              }

              bool hasAmount = false;
              if (type != 'vault' && amountCtrl.text.isNotEmpty) {
                final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                if (amt > 0) {
                  logData['amount'] = amt;
                  hasAmount = true;
                }
              }

              await finProv.addCarLog(car.id!, logData,
                  createGlobalTx: hasAmount);

              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add Log'),
          ),
        ],
      ),
    );
  }

  void _showDeleteLogDialog(
      BuildContext context, CarModel currentCar, int logIndex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Log'),
        content: const Text(
            'Are you sure you want to delete this log? This will not delete the global transaction.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final finProv =
                  Provider.of<FinanceProvider>(context, listen: false);
              await finProv.deleteCarLog(currentCar.id!, logIndex);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditCarDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: car.carName);
    final plateCtrl = TextEditingController(text: car.licensePlate);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Car Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                  labelText: 'Car Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: plateCtrl,
              decoration: InputDecoration(
                  labelText: 'License Plate',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.isEmpty || plateCtrl.text.isEmpty) return;
              final finProv =
                  Provider.of<FinanceProvider>(context, listen: false);
              final updated = CarModel(
                id: car.id,
                carName: nameCtrl.text.trim(),
                licensePlate: plateCtrl.text.trim(),
                expenses: car.expenses,
                createdAt: car.createdAt,
              );
              await finProv.updateCar(updated);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Car Profile'),
        content: const Text(
            'Are you sure you want to delete this car? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final finProv =
                  Provider.of<FinanceProvider>(context, listen: false);
              await finProv.deleteCar(car.id!);
              if (ctx.mounted) {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(ctx); // Close profile screen
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showReportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Download PDF Report'),
              onTap: () async {
                Navigator.pop(ctx);
                final finProv =
                    Provider.of<FinanceProvider>(context, listen: false);
                final currentCar = finProv.cars
                    .firstWhere((c) => c.id == car.id, orElse: () => car);
                await CarReportsService.generatePdfReport(currentCar);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Download Excel Report'),
              onTap: () async {
                Navigator.pop(ctx);
                final finProv =
                    Provider.of<FinanceProvider>(context, listen: false);
                final currentCar = finProv.cars
                    .firstWhere((c) => c.id == car.id, orElse: () => car);
                await CarReportsService.generateExcelReport(currentCar);
              },
            ),
          ],
        ),
      ),
    );
  }
}
