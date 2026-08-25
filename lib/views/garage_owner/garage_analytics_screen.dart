import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/garage_owner_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../models/garage_expense_model.dart';

class GarageAnalyticsScreen extends StatefulWidget {
  const GarageAnalyticsScreen({super.key});

  @override
  State<GarageAnalyticsScreen> createState() => _GarageAnalyticsScreenState();
}

class _GarageAnalyticsScreenState extends State<GarageAnalyticsScreen> {
  int _selectedFilterIndex = 0; // 0: Daily, 1: Monthly, 2: Yearly

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<GarageOwnerProvider>(context);
    final currency = Provider.of<ThemeProvider>(context).currencySymbol;

    // Calculate Totals
    double totalRevenue = 0;
    double partsCost = 0;

    for (var v in prov.vehicles) {
      if (v.status == 'Ready' || v.status == 'Delivered') {
        totalRevenue += v.estimatedCost;
        for (var p in v.usedParts) {
          // We need unitCost, but we only saved 'cost' (which was sellPrice) in usedParts.
          // Ideally, we'd subtract the original part unitCost from profit.
          // For now, we will sum up overhead expenses.
        }
      }
    }

    double totalOverhead = 0;
    for (var e in prov.expenses) {
      totalOverhead += e.amount;
    }

    final netProfit = totalRevenue - totalOverhead; // Simplified profit

    // Bar Chart Data
    final now = DateTime.now();
    final List<BarChartGroupData> barGroups = [];
    String chartTitle = '';
    double maxY = 100;

    if (_selectedFilterIndex == 0) {
      chartTitle = 'Revenue (Last 7 Days)';
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateStr = DateFormat('yyyy-MM-dd').format(date);

        double rev = 0;
        for (var v in prov.vehicles) {
          if ((v.status == 'Ready' || v.status == 'Delivered') &&
              v.createdAt.startsWith(dateStr)) {
            rev += v.estimatedCost;
          }
        }
        barGroups.add(BarChartGroupData(x: 6 - i, barRods: [
          BarChartRodData(
              toY: rev,
              color: AppColors.brown,
              width: 16,
              borderRadius: BorderRadius.circular(4))
        ]));
      }
    } else if (_selectedFilterIndex == 1) {
      chartTitle = 'Revenue (Last 6 Months)';
      for (int i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final monthStr = DateFormat('yyyy-MM').format(date);

        double rev = 0;
        for (var v in prov.vehicles) {
          if ((v.status == 'Ready' || v.status == 'Delivered') &&
              v.createdAt.startsWith(monthStr)) {
            rev += v.estimatedCost;
          }
        }
        barGroups.add(BarChartGroupData(x: 5 - i, barRods: [
          BarChartRodData(
              toY: rev,
              color: AppColors.brown,
              width: 16,
              borderRadius: BorderRadius.circular(4))
        ]));
      }
    } else {
      chartTitle = 'Revenue (Last 5 Years)';
      for (int i = 4; i >= 0; i--) {
        final yearStr = (now.year - i).toString();

        double rev = 0;
        for (var v in prov.vehicles) {
          if ((v.status == 'Ready' || v.status == 'Delivered') &&
              v.createdAt.startsWith(yearStr)) {
            rev += v.estimatedCost;
          }
        }
        barGroups.add(BarChartGroupData(x: 4 - i, barRods: [
          BarChartRodData(
              toY: rev,
              color: AppColors.brown,
              width: 16,
              borderRadius: BorderRadius.circular(4))
        ]));
      }
    }

    if (barGroups.isNotEmpty) {
      double max = barGroups
          .map((g) => g.barRods[0].toY)
          .reduce((a, b) => a > b ? a : b);
      maxY = (max * 1.2).clamp(100.0, double.infinity);
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.brown,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Garage Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                      context,
                      'Total Revenue',
                      '$currency${totalRevenue.toStringAsFixed(2)}',
                      Icons.monetization_on,
                      AppColors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                      context,
                      'Net Profit',
                      '$currency${netProfit.toStringAsFixed(2)}',
                      Icons.trending_up,
                      netProfit >= 0 ? AppColors.green : Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(chartTitle,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brown.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedFilterIndex,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: AppColors.brown),
                      style: const TextStyle(
                          color: AppColors.brown, fontWeight: FontWeight.bold),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedFilterIndex = newValue!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Daily')),
                        DropdownMenuItem(value: 1, child: Text('Monthly')),
                        DropdownMenuItem(value: 2, child: Text('Yearly')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10)
                ],
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          Widget text;
                          if (_selectedFilterIndex == 0) {
                            final date =
                                now.subtract(Duration(days: 6 - value.toInt()));
                            text = Text(DateFormat('E').format(date),
                                style: const TextStyle(fontSize: 12));
                          } else if (_selectedFilterIndex == 1) {
                            final date = DateTime(
                                now.year, now.month - (5 - value.toInt()), 1);
                            text = Text(DateFormat('MMM').format(date),
                                style: const TextStyle(fontSize: 12));
                          } else {
                            text = Text(
                                (now.year - (4 - value.toInt())).toString(),
                                style: const TextStyle(fontSize: 12));
                          }
                          return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: text);
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Text('$currency${value.toInt()}',
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 100,
                    getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Expenses List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Overhead Expenses',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.brown),
                  onPressed: () => _showAddExpenseDialog(context, prov),
                )
              ],
            ),
            if (prov.expenses.isEmpty)
              const Text('No expenses recorded.',
                  style: TextStyle(color: Colors.grey))
            else
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: prov.expenses.length,
                  itemBuilder: (context, index) {
                    final e = prov.expenses[index];
                    return ListTile(
                      title: Text(e.category),
                      subtitle: Text(DateFormat('yyyy-MM-dd')
                          .format(DateTime.parse(e.date))),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$currency${e.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.grey, size: 20),
                            onPressed: () => prov.deleteExpense(e.id!),
                          )
                        ],
                      ),
                    );
                  })
          ],
        ),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, GarageOwnerProvider prov) {
    final catCtrl = TextEditingController();
    final amtCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: catCtrl,
                decoration: const InputDecoration(
                    labelText: 'Category (e.g. Rent, Tools)')),
            TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final cat = catCtrl.text.trim();
              final amt = double.tryParse(amtCtrl.text) ?? 0.0;
              if (cat.isNotEmpty && amt > 0) {
                prov.addExpense(GarageExpenseModel(
                  category: cat,
                  amount: amt,
                  date: DateTime.now().toIso8601String(),
                ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String amount,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}
