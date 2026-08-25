import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/gym_owner_provider.dart';
import '../../models/gym_member_model.dart';
import '../../models/gym_payment_model.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';

class GymMemberProfileScreen extends StatefulWidget {
  final String memberId;

  const GymMemberProfileScreen({super.key, required this.memberId});

  @override
  State<GymMemberProfileScreen> createState() => _GymMemberProfileScreenState();
}

class _GymMemberProfileScreenState extends State<GymMemberProfileScreen> {
  void _showAddPaymentDialog(
      BuildContext context, GymMemberModel member, GymOwnerProvider prov) {
    final amtCtrl = TextEditingController();
    String pType = 'Monthly';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount Paid'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: pType,
              items: ['Weekly', 'Monthly', 'Yearly']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => pType = val!,
              decoration: const InputDecoration(labelText: 'Plan Renewed'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amtCtrl.text) ?? 0.0;
              if (amt > 0) {
                // Add payment record
                prov.addPayment(GymPaymentModel(
                  memberId: member.cloudId!,
                  amount: amt,
                  planType: pType,
                  date: DateTime.now().toIso8601String(),
                ));

                // Update member expiry
                DateTime currentExpiry = DateTime.parse(member.expiryDate);
                if (DateTime.now().isAfter(currentExpiry)) {
                  currentExpiry = DateTime.now();
                }

                DateTime newExpiry;
                if (pType == 'Weekly')
                  newExpiry = currentExpiry.add(const Duration(days: 7));
                else if (pType == 'Monthly')
                  newExpiry = currentExpiry.add(const Duration(days: 30));
                else
                  newExpiry = currentExpiry.add(const Duration(days: 365));

                prov.updateMember(member.copyWith(
                  expiryDate: newExpiry.toIso8601String(),
                  planType: pType,
                  status: 'Active',
                ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<GymOwnerProvider>(context);
    final member = prov.members.firstWhere((m) => m.cloudId == widget.memberId,
        orElse: () => GymMemberModel(
            name: '',
            phone: '',
            planType: '',
            expiryDate: '',
            status: '',
            createdAt: ''));
    if (member.cloudId == null)
      return const Scaffold(body: Center(child: Text('Member not found')));

    final memberPayments =
        prov.payments.where((p) => p.memberId == member.cloudId).toList();
    memberPayments.sort((a, b) => b.date.compareTo(a.date));

    final currency = Provider.of<ThemeProvider>(context).currencySymbol;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${member.name} Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.blue.withValues(alpha: 0.2),
                        child: const Icon(Icons.person,
                            size: 40, color: AppColors.blue)),
                    const SizedBox(height: 12),
                    Text(member.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(member.phone,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBadge(
                            'Status',
                            member.status,
                            member.status == 'Active'
                                ? AppColors.green
                                : AppColors.red),
                        _buildBadge(
                            'Current Plan', member.planType, AppColors.blue),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                        'Expires: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(member.expiryDate))}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (member.assignedTrainer != null) ...[
                      const SizedBox(height: 8),
                      Text('Trainer: ${member.assignedTrainer}',
                          style: const TextStyle(
                              color: AppColors.orange,
                              fontWeight: FontWeight.bold)),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment History',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => _showAddPaymentDialog(context, member, prov),
                  icon: const Icon(Icons.payment),
                  label: const Text('Renew Plan'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 12),
            if (memberPayments.isEmpty)
              const Text('No payments recorded.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: memberPayments.length,
                itemBuilder: (ctx, i) {
                  final p = memberPayments[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.receipt, color: AppColors.blue),
                      title: Text(p.planType),
                      subtitle: Text(DateFormat('yyyy-MM-dd HH:mm')
                          .format(DateTime.parse(p.date))),
                      trailing: Text('$currency${p.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.green)),
                    ),
                  );
                },
              )
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}
