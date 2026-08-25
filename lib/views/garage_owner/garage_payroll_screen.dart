import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/garage_owner_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';

class GaragePayrollScreen extends StatelessWidget {
  const GaragePayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<GarageOwnerProvider>(context);
    final currency = Provider.of<ThemeProvider>(context).currencySymbol;

    // Group labor cost by mechanic
    final Map<String, double> mechanicEarnings = {};
    for (var v in prov.vehicles) {
      if (v.status == 'Ready' || v.status == 'Delivered') {
        final mech = v.mechanicName ?? 'Unassigned';
        mechanicEarnings[mech] = (mechanicEarnings[mech] ?? 0.0) + v.laborCost;
      }
    }

    final entries = mechanicEarnings.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        title: const Text('Mechanic Payroll'),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: entries.isEmpty
          ? const Center(child: Text('No completed jobs found for payroll.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.brown,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(e.key,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Total Labor Earned (Completed Jobs)'),
                    trailing: Text('$currency${e.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.green)),
                  ),
                );
              },
            ),
    );
  }
}
