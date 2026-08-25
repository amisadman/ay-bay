import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/gym_owner_provider.dart';
import '../../models/gym_member_model.dart';
import '../../core/constants/app_colors.dart';
import 'gym_member_profile.dart';

class GymMembersScreen extends StatefulWidget {
  const GymMembersScreen({super.key});

  @override
  State<GymMembersScreen> createState() => _GymMembersScreenState();
}

class _GymMembersScreenState extends State<GymMembersScreen> {
  void _showAddEditDialog(BuildContext context, {GymMemberModel? member}) {
    final nameController = TextEditingController(text: member?.name ?? '');
    final phoneController = TextEditingController(text: member?.phone ?? '');
    String planType = member?.planType ?? 'Monthly';
    String? assignedTrainer = member?.assignedTrainer;
    DateTime selectedDate = member != null
        ? DateTime.parse(member.expiryDate)
        : DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (ctx) {
        final trainers = Provider.of<GymOwnerProvider>(context, listen: false)
            .employees
            .where((e) => e.role == 'Trainer' || e.role == 'Admin')
            .toList();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(member == null ? 'Add Member' : 'Edit Member',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Member Name',
                        prefixIcon: Icon(Icons.person,
                            color: Theme.of(context).colorScheme.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone,
                            color: Theme.of(context).colorScheme.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: planType,
                      decoration: InputDecoration(
                        labelText: 'Plan Type',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['Weekly', 'Monthly', 'Yearly']
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          planType = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (trainers.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: assignedTrainer,
                        decoration: InputDecoration(
                          labelText: 'Assign Trainer (Optional)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                              value: null, child: Text('None')),
                          ...trainers.map((t) => DropdownMenuItem(
                              value: t.name, child: Text(t.name))),
                        ],
                        onChanged: (val) {
                          setState(() {
                            assignedTrainer = val;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade400)),
                      leading: Icon(Icons.calendar_month,
                          color: Theme.of(context).colorScheme.primary),
                      title: Text(
                          'Expires: ${DateFormat('MMM dd, yyyy').format(selectedDate)}'),
                      trailing: const Icon(Icons.edit),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
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
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;

                    final isExpired = DateTime.now().isAfter(selectedDate);

                    final newMember = GymMemberModel(
                      cloudId: member?.cloudId,
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      planType: planType,
                      expiryDate: selectedDate.toIso8601String(),
                      status: isExpired ? 'Expired' : 'Active',
                      createdAt:
                          member?.createdAt ?? DateTime.now().toIso8601String(),
                      assignedTrainer: assignedTrainer,
                    );

                    final prov =
                        Provider.of<GymOwnerProvider>(context, listen: false);
                    if (member == null) {
                      prov.addMember(newMember);
                    } else {
                      prov.updateMember(newMember);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(member == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gymProv = Provider.of<GymOwnerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Gym Members'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: gymProv.members.isEmpty
          ? const Center(child: Text('No members found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: gymProv.members.length,
              itemBuilder: (context, index) {
                final member = gymProv.members[index];
                final isActive = member.status == 'Active';
                final statusColor = isActive ? AppColors.green : AppColors.red;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => GymMemberProfileScreen(
                                  memberId: member.cloudId!)));
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withValues(alpha: 0.1),
                        child: Icon(Icons.person, color: statusColor),
                      ),
                      title: Text(member.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(member.phone,
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            'Expires: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(member.expiryDate))}',
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showAddEditDialog(context, member: member),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirm(
                                context, member.cloudId!, gymProv),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteConfirm(
      BuildContext context, String cloudId, GymOwnerProvider gymProv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member?'),
        content: const Text('Are you sure you want to remove this member?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              gymProv.deleteMember(cloudId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
