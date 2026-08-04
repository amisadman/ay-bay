import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/models/cloud_event_model.dart';
import 'package:aybay_flutter/providers/cloud_event_provider.dart';
import 'package:aybay_flutter/providers/auth_provider.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/services/export_service.dart';

class EventProfileScreen extends StatefulWidget {
  final CloudEventModel event;

  const EventProfileScreen({super.key, required this.event});

  @override
  State<EventProfileScreen> createState() => _EventProfileScreenState();
}

class _EventProfileScreenState extends State<EventProfileScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Add Event Expense', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount Spent', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final authProv = Provider.of<AuthProvider>(context, listen: false);
                final evProv = Provider.of<CloudEventProvider>(context, listen: false);
                final uid = authProv.userName.toLowerCase().replaceAll(' ', '_');
                final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
                
                if (amount > 0 && _descController.text.isNotEmpty) {
                  final expense = CloudEventExpenseModel(
                    expenseId: '',
                    eventId: widget.event.eventId,
                    amount: amount,
                    description: _descController.text.trim(),
                    category: 'Event',
                    paidBy: authProv.userName,
                    addedBy: uid,
                    addedByName: authProv.userName,
                    timestamp: DateTime.now(),
                  );
                  await evProv.addExpense(widget.event.eventId, expense);
                  if (mounted) {
                    Navigator.pop(ctx);
                    _descController.clear();
                    _amountController.clear();
                  }
                }
              },
              child: const Text('Add Expense'),
            ),
          ],
        );
      },
    );
  }

  void _showAddBalanceDialog(double currentBudget) {
    final balanceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Add Balance to Event', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This will increase the total budget of the event.'),
              const SizedBox(height: 12),
              TextField(
                controller: balanceCtrl,
                decoration: InputDecoration(labelText: 'Amount to Add', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white),
              onPressed: () async {
                final evProv = Provider.of<CloudEventProvider>(context, listen: false);
                final amount = double.tryParse(balanceCtrl.text.trim()) ?? 0.0;
                if (amount > 0) {
                  await evProv.updateEventBudget(widget.event.eventId, currentBudget + amount);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Balance Added!')));
                  }
                }
              },
              child: const Text('Add Balance'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);
    final sym = themeProv.currencySymbol;
    final evProv = Provider.of<CloudEventProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.event.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: StreamBuilder<List<CloudEventExpenseModel>>(
        stream: evProv.streamEventExpenses(widget.event.eventId),
        builder: (context, snapshot) {
          double totalSpent = 0.0;
          List<CloudEventExpenseModel> expenses = [];
          
          if (snapshot.hasData) {
            expenses = snapshot.data!;
            totalSpent = expenses.fold(0.0, (sum, item) => sum + item.amount);
          }
          
          // Note: Because we don't have real-time sync for the event metadata itself in this view (it relies on the passed widget.event), 
          // we fetch the most up to date event from the provider.
          final updatedEvent = evProv.myEvents.firstWhere(
            (e) => e.eventId == widget.event.eventId, 
            orElse: () => widget.event
          );

          final remainingBalance = updatedEvent.budget - totalSpent;
          final progress = updatedEvent.budget > 0 ? (totalSpent / updatedEvent.budget).clamp(0.0, 1.0) : 0.0;

          return Column(
            children: [
              // Event Profile Card (Light UI)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white1,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Remaining Balance', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.formatSimple(remainingBalance, sym),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: remainingBalance < 0 ? AppColors.red : AppColors.green,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.brown.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text('CODE: ${updatedEvent.inviteCode}', style: const TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(updatedEvent.description, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spent: ${CurrencyFormatter.formatSimple(totalSpent, sym)}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          'Budget: ${CurrencyFormatter.formatSimple(updatedEvent.budget, sym)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.brown),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade300,
                      color: progress > 0.9 ? AppColors.red : AppColors.green,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),

              // Ledger Title & Export & Add Balance Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Shared Ledger', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brown)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.green),
                          tooltip: 'Add Balance to Budget',
                          onPressed: () => _showAddBalanceDialog(updatedEvent.budget),
                        ),
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: AppColors.red),
                          tooltip: 'Export PDF',
                          onPressed: () async {
                            if (mounted) {
                              await ExportService.exportEventToPdf(
                                expenses: expenses,
                                context: context,
                                currencySymbol: sym,
                                eventName: updatedEvent.title,
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.table_chart, color: AppColors.green),
                          tooltip: 'Export Excel',
                          onPressed: () async {
                            if (mounted) {
                              await ExportService.exportEventToExcel(
                                expenses: expenses,
                                context: context,
                                currencySymbol: sym,
                                eventName: updatedEvent.title,
                              );
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Ledger List
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : expenses.isEmpty
                        ? const Center(child: Text('No expenses logged yet.', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {
                              final exp = expenses[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: AppColors.white1,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppColors.red.withOpacity(0.1),
                                        child: const Icon(Icons.receipt, color: AppColors.red),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(exp.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.black)),
                                            const SizedBox(height: 4),
                                            Text('Added by ${exp.addedByName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                            Text('${exp.timestamp.day}/${exp.timestamp.month}/${exp.timestamp.year} ${exp.timestamp.hour}:${exp.timestamp.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '- ${CurrencyFormatter.formatSimple(exp.amount, sym)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.red, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.red,
        onPressed: _showAddExpenseDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
