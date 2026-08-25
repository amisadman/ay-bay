import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/tuition_model.dart';
import '../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class TuitionProfileScreen extends StatelessWidget {
  final TuitionModel tuition;

  const TuitionProfileScreen({super.key, required this.tuition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(tuition.studentName, style: const TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'edit') {
                _showEditTuitionDialog(context);
              } else if (val == 'delete') {
                _showDeleteTuitionDialog(context);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
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
          final currentTuition = finProv.tuitions
              .firstWhere((t) => t.id == tuition.id, orElse: () => tuition);

          List<dynamic> logs = [];
          try {
            logs = jsonDecode(currentTuition.expenses);
          } catch (e) {
            // ignore
          }

          final now = DateTime.now();
          final currentMonthYear = DateFormat('MMMM yyyy').format(now);
          final isPaidThisMonth = logs.any((l) =>
              l['type'] == 'Monthly Fee' && l['monthYear'] == currentMonthYear);

          // Calculate Installment Progress if configured
          double totalSemesterFee = 0.0;
          final configLog = logs.where((l) => l['type'] == 'config').lastOrNull;
          if (configLog != null) {
            totalSemesterFee =
                (configLog['totalSemesterFee'] as num?)?.toDouble() ?? 0.0;
          }

          double totalSemesterPaid = logs
              .where((l) => l['type'] == 'Semester Fee')
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
                  color: AppColors.purple,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      currentTuition.institution,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Monthly Tuition Fee',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '৳${currentTuition.monthlyFee.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isPaidThisMonth ? AppColors.green : AppColors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPaidThisMonth
                            ? 'Paid for $currentMonthYear'
                            : 'Unpaid for $currentMonthYear',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (totalSemesterFee > 0) ...[
                      const SizedBox(height: 24),
                      const Text('Semester Fee Progress',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (totalSemesterPaid / totalSemesterFee)
                            .clamp(0.0, 1.0),
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.green),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          '৳${totalSemesterPaid.toStringAsFixed(0)} / ৳${totalSemesterFee.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white70)),
                    ]
                  ],
                ),
              ),
              Expanded(
                child: logs.isEmpty
                    ? const Center(
                        child: Text('No payments or logs recorded yet.',
                            style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final actualIndex = logs.length - 1 - index;
                          final log = logs[actualIndex];
                          if (log['type'] == 'config')
                            return const SizedBox
                                .shrink(); // Hide internal config
                          return _buildLogCard(
                              context, currentTuition, actualIndex, log);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.purple,
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text('Add Payment', style: TextStyle(color: Colors.white)),
        onPressed: () => _showAddPaymentDialog(context),
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, TuitionModel currentTuition,
      int logIndex, Map<String, dynamic> log) {
    final type = log['type'] ?? 'Monthly Fee';
    IconData icon;
    Color color;

    if (type == 'Monthly Fee') {
      icon = Icons.calendar_month;
      color = AppColors.green;
    } else if (type == 'Exam Fee') {
      icon = Icons.assignment;
      color = Colors.orange;
    } else if (type == 'Semester Fee') {
      icon = Icons.account_balance;
      color = AppColors.blue;
    } else if (type == 'Picnic Fee') {
      icon = Icons.celebration;
      color = Colors.pink;
    } else if (type == 'Vault') {
      icon = Icons.file_present;
      color = Colors.indigo;
    } else {
      icon = Icons.payment;
      color = Colors.grey;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: color, child: Icon(icon, color: Colors.white)),
        title: Text(type == 'Vault' ? (log['note'] ?? 'Document') : type,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(log['monthYear'] ?? log['date'] ?? ''),
        trailing: log['amount'] != null
            ? Text('৳${(log['amount'] as num).toDouble().toStringAsFixed(2)}',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16))
            : null,
        onLongPress: () =>
            _showDeleteLogDialog(context, currentTuition, logIndex),
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
    String selectedType = 'Monthly Fee';
    final amountCtrl =
        TextEditingController(text: tuition.monthlyFee.toStringAsFixed(0));
    final noteCtrl = TextEditingController();

    final now = DateTime.now();
    final monthYearCtrl =
        TextEditingController(text: DateFormat('MMMM yyyy').format(now));

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Payment / Log'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12))),
                    items: [
                      'Monthly Fee',
                      'Exam Fee',
                      'Semester Fee',
                      'Picnic Fee',
                      'Vault',
                      'Other'
                    ]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedType = val!;
                        if (val == 'Monthly Fee')
                          amountCtrl.text =
                              tuition.monthlyFee.toStringAsFixed(0);
                        else
                          amountCtrl.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedType != 'Vault')
                    TextField(
                      controller: amountCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText: 'Amount (৳)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                  if (selectedType != 'Vault') const SizedBox(height: 12),
                  TextField(
                    controller:
                        selectedType == 'Vault' ? noteCtrl : monthYearCtrl,
                    decoration: InputDecoration(
                      labelText: selectedType == 'Vault'
                          ? 'Document Name'
                          : 'Month/Year (or Note)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  if (selectedType != 'Vault' && amountCtrl.text.isEmpty)
                    return;

                  final finProv =
                      Provider.of<FinanceProvider>(context, listen: false);
                  final date = DateTime.now().toIso8601String().split('T')[0];

                  Map<String, dynamic> logData = {
                    'type': selectedType,
                    'date': date
                  };

                  bool hasAmount = false;
                  if (selectedType != 'Vault') {
                    final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                    if (amt > 0) {
                      logData['amount'] = amt;
                      hasAmount = true;
                    }
                    logData['monthYear'] = monthYearCtrl.text.trim();
                  } else {
                    logData['note'] = noteCtrl.text.trim();
                  }

                  await finProv.addTuitionLog(tuition.id!, logData,
                      createGlobalTx: hasAmount);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showDeleteLogDialog(
      BuildContext context, TuitionModel currentTuition, int logIndex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Log'),
        content: const Text(
            'Are you sure you want to delete this payment log? This will not delete the global transaction.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final finProv =
                  Provider.of<FinanceProvider>(context, listen: false);
              await finProv.deleteTuitionLog(currentTuition.id!, logIndex);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditTuitionDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: tuition.studentName);
    final instCtrl = TextEditingController(text: tuition.institution);
    final feeCtrl =
        TextEditingController(text: tuition.monthlyFee.toStringAsFixed(0));
    final semesterFeeCtrl = TextEditingController();

    // Find existing config if any
    final finProv = Provider.of<FinanceProvider>(context, listen: false);
    final currentTuition = finProv.tuitions
        .firstWhere((t) => t.id == tuition.id, orElse: () => tuition);
    List<dynamic> logs = [];
    try {
      logs = jsonDecode(currentTuition.expenses);
    } catch (e) {}
    final configIdx = logs.indexWhere((l) => l['type'] == 'config');
    if (configIdx != -1) {
      semesterFeeCtrl.text =
          logs[configIdx]['totalSemesterFee']?.toString() ?? '';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Tuition Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                    labelText: 'Student Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: instCtrl,
                decoration: InputDecoration(
                    labelText: 'Institution',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feeCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                    labelText: 'Monthly Fee (৳)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: semesterFeeCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                    labelText: 'Total Semester Fee (Optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.isEmpty ||
                  instCtrl.text.isEmpty ||
                  feeCtrl.text.isEmpty) return;

              final updated = TuitionModel(
                id: tuition.id,
                studentName: nameCtrl.text.trim(),
                institution: instCtrl.text.trim(),
                monthlyFee: double.tryParse(feeCtrl.text) ?? 0.0,
                dueDate: tuition.dueDate,
                expenses: currentTuition.expenses,
                createdAt: tuition.createdAt,
              );
              await finProv.updateTuition(updated);

              // Handle config for semester fee
              if (semesterFeeCtrl.text.isNotEmpty) {
                final semFee = double.tryParse(semesterFeeCtrl.text) ?? 0.0;
                if (configIdx != -1) {
                  await finProv.updateTuitionLog(tuition.id!, configIdx,
                      {'type': 'config', 'totalSemesterFee': semFee});
                } else {
                  await finProv.addTuitionLog(tuition.id!,
                      {'type': 'config', 'totalSemesterFee': semFee});
                }
              }

              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTuitionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tuition Profile'),
        content: const Text(
            'Are you sure you want to delete this profile? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final finProv =
                  Provider.of<FinanceProvider>(context, listen: false);
              await finProv.deleteTuition(tuition.id!);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
