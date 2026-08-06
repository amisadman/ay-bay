import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';

class BudgetProfileScreen extends StatefulWidget {
  final int budgetId;
  const BudgetProfileScreen({super.key, required this.budgetId});

  @override
  State<BudgetProfileScreen> createState() => _BudgetProfileScreenState();
}

class _BudgetProfileScreenState extends State<BudgetProfileScreen> {

  void _showAddCategoryDialog(BuildContext context, FinanceProvider finProv) {
    final catCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Budget Category', style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Category Name (e.g. Groceries)')),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Allocated Amount')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.black, foregroundColor: Colors.white),
            onPressed: () {
              final cat = catCtrl.text.trim();
              final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
              if (cat.isNotEmpty && amt > 0) {
                finProv.addBudgetCategory(widget.budgetId, cat, amt);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showLogExpenseDialog(BuildContext context, FinanceProvider finProv, String catId, String catName) {
    final amountCtrl = TextEditingController();
    bool logToGlobal = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateBuilder) => AlertDialog(
          title: Text('Log Expense: $catName', style: const TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount Spent',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Log as Global Expense', style: TextStyle(fontSize: 14)),
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white),
              onPressed: () {
                final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                if (amt > 0) {
                  finProv.logBudgetExpense(widget.budgetId, catId, amt, logToTransactions: logToGlobal);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Log Spent'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finProv = Provider.of<FinanceProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);
    final sym = themeProv.currencySymbol;

    final idx = finProv.budgets.indexWhere((b) => b.id == widget.budgetId);
    if (idx == -1) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Not Found')));
    }
    final budget = finProv.budgets[idx];
    
    List<dynamic> categories = [];
    double totalAllocated = 0.0;
    double totalSpent = 0.0;
    try {
      categories = jsonDecode(budget.budgets);
      for (var b in categories) {
        totalAllocated += (b['amount'] as num).toDouble();
        totalSpent += (b['spent'] as num).toDouble();
      }
    } catch (e) {}

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(budget.monthYear, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              finProv.deleteBudgetMonth(budget.id!);
              Navigator.pop(context);
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.black,
        onPressed: () => _showAddCategoryDialog(context, finProv),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Category', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Immersive Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 12),
            decoration: const BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Budget', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(CurrencyFormatter.formatSimple(totalAllocated, sym), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Spent', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(CurrencyFormatter.formatSimple(totalSpent, sym), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: totalSpent > totalAllocated ? AppColors.red : AppColors.green)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? const Center(child: Text('No categories added.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      final catId = item['id'];
                      final catName = item['category'];
                      final amount = (item['amount'] as num).toDouble();
                      final spent = (item['spent'] as num).toDouble();
                      final remaining = amount - spent;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 1)]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(catName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.red),
                                      onPressed: () => finProv.adjustBudgetCategory(budget.id!, catId, -50.0), // Decrement by 50
                                    ),
                                    Text(CurrencyFormatter.formatSimple(amount, sym), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: AppColors.green),
                                      onPressed: () => finProv.adjustBudgetCategory(budget.id!, catId, 50.0), // Increment by 50
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Spent: ${CurrencyFormatter.formatSimple(spent, sym)}', style: const TextStyle(color: Colors.grey)),
                                Text(
                                  'Left: ${CurrencyFormatter.formatSimple(remaining, sym)}',
                                  style: TextStyle(color: remaining < 0 ? AppColors.red : AppColors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.white1,
                                  foregroundColor: AppColors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300))
                                ),
                                onPressed: () => _showLogExpenseDialog(context, finProv, catId, catName),
                                child: const Text('Log Expense'),
                              ),
                            )
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
