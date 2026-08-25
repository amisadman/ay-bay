import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/models/savings_model.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';

class SavingsProfileScreen extends StatefulWidget {
  final int savingsId;
  const SavingsProfileScreen({super.key, required this.savingsId});

  @override
  State<SavingsProfileScreen> createState() => _SavingsProfileScreenState();
}

class _SavingsProfileScreenState extends State<SavingsProfileScreen> {
  void _showTransactionDialog(
      BuildContext context, FinanceProvider finProv, String type) {
    final amountCtrl = TextEditingController();
    final isAdd = type == 'add';
    bool logToGlobal = true;

    showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
              builder: (context, setStateBuilder) => AlertDialog(
                title: Text(isAdd ? 'Add Money' : 'Retrieve Money',
                    style: const TextStyle(
                        color: AppColors.brown, fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Log as Income/Expense',
                          style: TextStyle(fontSize: 14)),
                      value: logToGlobal,
                      activeColor: AppColors.black,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setStateBuilder(() => logToGlobal = val);
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isAdd ? AppColors.green : AppColors.red,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      final amount =
                          double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                      if (amount > 0) {
                        final date =
                            DateTime.now().toIso8601String().split('T')[0];
                        finProv.addSavingsTransaction(
                            widget.savingsId, amount, type, date,
                            logToTransactions: logToGlobal);
                        Navigator.pop(ctx);
                      }
                    },
                    child: Text(isAdd ? 'Deposit' : 'Withdraw'),
                  ),
                ],
              ),
            ));
  }

  void _showEditTransactionDialog(BuildContext context, FinanceProvider finProv,
      int originalIndex, double currentAmount, String currentDate) {
    final amountCtrl = TextEditingController(text: currentAmount.toString());
    final dateCtrl = TextEditingController(text: currentDate);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Transaction',
            style:
                TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateCtrl,
              decoration: InputDecoration(
                labelText: 'Date (YYYY-MM-DD)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: Colors.white),
            onPressed: () async {
              final newAmount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
              final newDate = dateCtrl.text.trim();
              if (newAmount > 0 && newDate.isNotEmpty) {
                await finProv.updateSavingsTransaction(
                    widget.savingsId, originalIndex, newAmount, newDate);
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finProv = Provider.of<FinanceProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);
    final sym = themeProv.currencySymbol;

    final idx = finProv.savings.indexWhere((s) => s.id == widget.savingsId);
    if (idx == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account Not Found')),
        body: const Center(child: Text('This account no longer exists.')),
      );
    }
    final acc = finProv.savings[idx];

    List<dynamic> transactions = [];
    try {
      transactions = jsonDecode(acc.transactions);
    } catch (e) {}

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.vibrantGold,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Account Details',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Simple Edit dialog
              final bankCtrl = TextEditingController(text: acc.bankName);
              final acCtrl = TextEditingController(text: acc.accountNumber);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Edit Account'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                          controller: bankCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Bank Name')),
                      TextField(
                          controller: acCtrl,
                          decoration:
                              const InputDecoration(labelText: 'A/C Number')),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        final updated = SavingsModel(
                          id: acc.id,
                          bankName: bankCtrl.text,
                          accountNumber: acCtrl.text,
                          branchAddress: acc.branchAddress,
                          balance: acc.balance,
                          transactions: acc.transactions,
                          createdAt: acc.createdAt,
                        );
                        finProv.updateSavingsAccount(updated);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (val) async {
              if (val == 'delete') {
                await finProv.deleteSavingsAccount(widget.savingsId);
                if (mounted) Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Profile'),
              )
            ],
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Immersive Header Card
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 12),
            decoration: const BoxDecoration(
              color: AppColors.vibrantGold,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(acc.bankName.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5)),
                    const Icon(Icons.account_balance_rounded,
                        color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Current Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatSimple(acc.balance, sym),
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('A/C Number',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(acc.accountNumber,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    if (acc.branchAddress.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Branch',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(acc.branchAddress,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16)),
                        ],
                      ),
                  ],
                )
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add Money'),
                    onPressed: () =>
                        _showTransactionDialog(context, finProv, 'add'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('Retrieve'),
                    onPressed: () =>
                        _showTransactionDialog(context, finProv, 'retrieve'),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Transaction History',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown)),
          ),

          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text('No transactions yet.',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      // Reverse order to show newest first
                      final trans =
                          transactions[transactions.length - 1 - index];
                      final amount = (trans['amount'] as num).toDouble();
                      final date = trans['date'] as String;
                      final type = trans['type'] as String;
                      final isAdd = type == 'add';

                      return ListTile(
                        leading: CircleAvatar(
                            backgroundColor: isAdd
                                ? AppColors.green.withValues(alpha: 0.1)
                                : AppColors.red.withValues(alpha: 0.1),
                            child: Icon(
                                isAdd
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color:
                                    isAdd ? AppColors.green : AppColors.red)),
                        title: Text(isAdd ? 'Deposit' : 'Withdrawal',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(date),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                '${isAdd ? '+' : '-'} ${CurrencyFormatter.formatSimple(amount, sym)}',
                                style: TextStyle(
                                    color:
                                        isAdd ? AppColors.green : AppColors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.grey),
                              onSelected: (val) async {
                                if (val == 'delete') {
                                  // The index in the reversed list maps to the original index
                                  final originalIndex =
                                      transactions.length - 1 - index;
                                  await finProv.deleteSavingsTransaction(
                                      widget.savingsId, originalIndex);
                                } else if (val == 'edit') {
                                  final originalIndex =
                                      transactions.length - 1 - index;
                                  _showEditTransactionDialog(context, finProv,
                                      originalIndex, amount, date);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
