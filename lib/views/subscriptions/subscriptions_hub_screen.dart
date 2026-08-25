import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/subscription_model.dart';
import '../../core/constants/app_colors.dart';

class SubscriptionsHubScreen extends StatefulWidget {
  const SubscriptionsHubScreen({super.key});

  @override
  State<SubscriptionsHubScreen> createState() => _SubscriptionsHubScreenState();
}

class _SubscriptionsHubScreenState extends State<SubscriptionsHubScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SubscriptionProvider>(context, listen: false)
            .fetchSubscriptions());
  }

  void _showAddEditDialog(BuildContext context, {SubscriptionModel? sub}) {
    final nameController = TextEditingController(text: sub?.name ?? '');
    final costController =
        TextEditingController(text: sub?.cost.toString() ?? '');
    String billingCycle = sub?.billingCycle ?? 'Monthly';
    DateTime selectedDate = sub != null
        ? DateTime.parse(sub.nextDueDate)
        : DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                  sub == null ? 'Add Subscription' : 'Edit Subscription',
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
                        labelText: 'Service Name (e.g., Netflix)',
                        prefixIcon: Icon(Icons.live_tv,
                            color: Theme.of(context).colorScheme.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cost',
                        prefixIcon: Icon(Icons.attach_money,
                            color: Theme.of(context).colorScheme.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: billingCycle,
                      decoration: InputDecoration(
                        labelText: 'Billing Cycle',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['Monthly', 'Yearly']
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          billingCycle = val!;
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
                          'Next Due: ${DateFormat('MMM dd, yyyy').format(selectedDate)}'),
                      trailing: const Icon(Icons.edit),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
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
                    if (nameController.text.trim().isEmpty ||
                        costController.text.trim().isEmpty) {
                      return;
                    }
                    final cost = double.tryParse(costController.text) ?? 0.0;
                    if (cost <= 0) return;

                    final newSub = SubscriptionModel(
                      id: sub?.id,
                      name: nameController.text.trim(),
                      cost: cost,
                      billingCycle: billingCycle,
                      nextDueDate: selectedDate.toIso8601String(),
                      createdAt:
                          sub?.createdAt ?? DateTime.now().toIso8601String(),
                    );

                    final prov = Provider.of<SubscriptionProvider>(context,
                        listen: false);
                    if (sub == null) {
                      prov.addSubscription(newSub);
                    } else {
                      prov.updateSubscription(newSub);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(sub == null ? 'Add' : 'Save'),
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
    final subProv = Provider.of<SubscriptionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscriptions', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Sub', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.purple,
      ),
      body: subProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryCard(context, subProv),
                Expanded(
                  child: subProv.subscriptions.isEmpty
                      ? const Center(
                          child: Text('No active subscriptions. Add one!'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: subProv.subscriptions.length,
                          itemBuilder: (context, index) {
                            final sub = subProv.subscriptions[index];
                            return _buildSubscriptionCard(
                                context, sub, subProv);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, SubscriptionProvider subProv) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet,
              color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Monthly Cost',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                '${Provider.of<ThemeProvider>(context).currencySymbol}${subProv.totalMonthlyCost.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, SubscriptionModel sub,
      SubscriptionProvider subProv) {
    final nextDate = DateTime.parse(sub.nextDueDate);
    final now = DateTime.now();
    final daysLeft = nextDate.difference(now).inDays;

    // Calculate progress (Assuming 30 day cycle for simplicity of UI)
    double progress = 1.0 - (daysLeft / 30);
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;

    Color statusColor = daysLeft <= 3 ? AppColors.red : AppColors.green;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      child: Icon(Icons.subscriptions,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sub.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                            '${sub.billingCycle} • ${Provider.of<ThemeProvider>(context).currencySymbol}${sub.cost.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showAddEditDialog(context, sub: sub),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _showDeleteConfirm(context, sub.id!, subProv),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Next Bill: ${DateFormat('MMM dd').format(nextDate)}',
                    style: const TextStyle(fontSize: 13)),
                Text(daysLeft < 0 ? 'Overdue' : '$daysLeft days left',
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(
      BuildContext context, int id, SubscriptionProvider subProv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subscription?'),
        content:
            const Text('Are you sure you want to delete this subscription?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              subProv.deleteSubscription(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
