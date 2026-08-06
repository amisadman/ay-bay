import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/models/savings_model.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';
import 'package:aybay_flutter/views/savings/savings_profile_screen.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  void _showAddSavingsDialog() {
    final bankCtrl = TextEditingController();
    final accountCtrl = TextEditingController();
    final branchCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Savings Account',
            style:
                TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bankCtrl,
                decoration: InputDecoration(
                    labelText: 'Bank Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Account Number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: branchCtrl,
                decoration: InputDecoration(
                    labelText: 'Branch Address',
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
                backgroundColor: AppColors.black,
                foregroundColor: Colors.white),
            onPressed: () {
              final bank = bankCtrl.text.trim();
              final account = accountCtrl.text.trim();
              final branch = branchCtrl.text.trim();

              if (bank.isNotEmpty && account.isNotEmpty) {
                final newAccount = SavingsModel(
                  bankName: bank,
                  accountNumber: account,
                  branchAddress: branch,
                  balance: 0.0,
                  transactions: '[]',
                  createdAt: DateTime.now().toIso8601String(),
                );
                Provider.of<FinanceProvider>(context, listen: false)
                    .addSavingsAccount(newAccount);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Account'),
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.vibrantGold,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Savings Accounts',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.black,
        onPressed: _showAddSavingsDialog,
        child: const Icon(Icons.add_business_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          // Total Savings Widget
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Saved',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade700)),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatSimple(finProv.totalSavings, sym),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.vibrantGold,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.savings_rounded,
                  color: AppColors.vibrantGold,
                  size: 40,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List of Accounts
          Expanded(
            child: finProv.savings.isEmpty
                ? const Center(
                    child: Text('No savings accounts found.',
                        style: TextStyle(color: Colors.grey, fontSize: 16)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: finProv.savings.length,
                    itemBuilder: (context, index) {
                      final acc = finProv.savings[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    SavingsProfileScreen(savingsId: acc.id!)),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                    AppColors.vibrantGold.withOpacity(0.15),
                                child: const Icon(Icons.account_balance_rounded,
                                    color: AppColors.vibrantGold, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(acc.bankName,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color ??
                                                AppColors.black)),
                                    Text('A/C: ${acc.accountNumber}',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.formatSimple(
                                        acc.balance, sym),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.brown),
                                  ),
                                  const SizedBox(height: 4),
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 14, color: Colors.grey),
                                ],
                              ),
                            ],
                          ),
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
