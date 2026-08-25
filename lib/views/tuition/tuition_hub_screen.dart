import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/tuition_model.dart';
import '../../core/constants/app_colors.dart';
import 'tuition_profile_screen.dart';

class TuitionHubScreen extends StatelessWidget {
  const TuitionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finProv = Provider.of<FinanceProvider>(context);
    final tuitions = finProv.tuitions;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Tuition Fees', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: tuitions.isEmpty
          ? const Center(
              child: Text(
                'No tuition profiles added yet.\nTap + to add a student.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tuitions.length,
              itemBuilder: (context, index) {
                final tuition = tuitions[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.purple,
                      child: Icon(Icons.school, color: Colors.white),
                    ),
                    title: Text(tuition.studentName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${tuition.institution} • ৳${tuition.monthlyFee.toStringAsFixed(0)}/mo'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TuitionProfileScreen(tuition: tuition),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.purple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddTuitionDialog(context, finProv),
      ),
    );
  }

  void _showAddTuitionDialog(BuildContext context, FinanceProvider finProv) {
    final nameCtrl = TextEditingController();
    final instCtrl = TextEditingController();
    final feeCtrl = TextEditingController();
    final dueCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Tuition Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: instCtrl,
                decoration: InputDecoration(
                  labelText: 'Institution (School/College)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feeCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monthly Fee (৳)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dueCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Due Date (Day 1-31)',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.isEmpty ||
                  instCtrl.text.isEmpty ||
                  feeCtrl.text.isEmpty ||
                  dueCtrl.text.isEmpty) return;
              final fee = double.tryParse(feeCtrl.text) ?? 0.0;
              final due = int.tryParse(dueCtrl.text) ?? 1;

              final newTuition = TuitionModel(
                studentName: nameCtrl.text.trim(),
                institution: instCtrl.text.trim(),
                monthlyFee: fee,
                dueDate: due,
                expenses: '[]',
                createdAt: DateTime.now().toIso8601String(),
              );
              await finProv.addTuition(newTuition);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add Profile'),
          ),
        ],
      ),
    );
  }
}
