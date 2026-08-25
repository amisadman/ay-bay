import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_owner_provider.dart';
import '../../core/constants/app_colors.dart';

class GymTrainerDashboard extends StatelessWidget {
  const GymTrainerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<GymOwnerProvider>(context);

    // Filter to trainers only
    final trainers = prov.employees
        .where((e) => e.role == 'Trainer' || e.role == 'Admin')
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Trainer Dashboard'),
        elevation: 0,
      ),
      body: trainers.isEmpty
          ? const Center(child: Text('No trainers found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trainers.length,
              itemBuilder: (context, index) {
                final trainer = trainers[index];

                // Count assigned members
                final assignedMembers = prov.members
                    .where((m) => m.assignedTrainer == trainer.name)
                    .toList();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ExpansionTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.orange,
                      child: Icon(Icons.sports, color: Colors.white),
                    ),
                    title: Text(trainer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                        Text('Assigned Clients: ${assignedMembers.length}'),
                    children: [
                      if (assignedMembers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No clients assigned yet.'),
                        )
                      else
                        ...assignedMembers.map((m) => ListTile(
                              title: Text(m.name),
                              subtitle: Text('Plan: ${m.planType}'),
                              trailing: Text(m.status,
                                  style: TextStyle(
                                      color: m.status == 'Active'
                                          ? AppColors.green
                                          : AppColors.red,
                                      fontWeight: FontWeight.bold)),
                            ))
                    ],
                  ),
                );
              },
            ),
    );
  }
}
