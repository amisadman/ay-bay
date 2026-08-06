import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/models/budget_model.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';
import 'package:aybay_flutter/views/budget/budget_profile_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {

  void _showAddMonthDialog() {
    final monthCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Budget Profile', style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: monthCtrl,
          decoration: InputDecoration(
            labelText: 'Month Name (e.g. August 2026)', 
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.black, foregroundColor: Colors.white),
            onPressed: () {
              final month = monthCtrl.text.trim();
              if (month.isNotEmpty) {
                final newBudget = BudgetModel(
                  monthYear: month,
                  budgets: '[]',
                  createdAt: DateTime.now().toIso8601String(),
                );
                Provider.of<FinanceProvider>(context, listen: false).addBudgetMonth(newBudget);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
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
        backgroundColor: AppColors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Budgets', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.black,
        onPressed: _showAddMonthDialog,
        child: const Icon(Icons.calendar_month, color: Colors.white),
      ),
      body: finProv.budgets.isEmpty
          ? const Center(child: Text('No budget profiles found.', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: finProv.budgets.length,
              itemBuilder: (context, index) {
                final budget = finProv.budgets[index];
                
                double totalAllocated = 0.0;
                double totalSpent = 0.0;
                try {
                  final list = jsonDecode(budget.budgets) as List<dynamic>;
                  for (var b in list) {
                    totalAllocated += (b['amount'] as num).toDouble();
                    totalSpent += (b['spent'] as num).toDouble();
                  }
                } catch (e) {}

                final double progress = totalAllocated > 0 ? (totalSpent / totalAllocated).clamp(0.0, 1.0) : 0.0;
                final bool overBudget = totalSpent > totalAllocated;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BudgetProfileScreen(budgetId: budget.id!)),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white1,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.deepTeal.withValues(alpha: 0.1),
                              child: const Icon(Icons.pie_chart, color: AppColors.deepTeal),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(budget.monthYear, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Spent: ${CurrencyFormatter.formatSimple(totalSpent, sym)}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            Text('Allocated: ${CurrencyFormatter.formatSimple(totalAllocated, sym)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.brown)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade300,
                          color: overBudget ? AppColors.red : AppColors.green,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
