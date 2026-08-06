import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class MonthlyAnalyticsTab extends StatefulWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthChanged;
  const MonthlyAnalyticsTab({super.key, required this.selectedMonth, required this.onMonthChanged});
  

  @override
  State<MonthlyAnalyticsTab> createState() => _MonthlyAnalyticsTabState();
}

class _MonthlyAnalyticsTabState extends State<MonthlyAnalyticsTab> {
  

  @override
  Widget build(BuildContext context) {
    final finProv = Provider.of<FinanceProvider>(context);
    final sym = Provider.of<ThemeProvider>(context).currencySymbol;

    final monthStr = "${widget.selectedMonth.year}-${widget.selectedMonth.month.toString().padLeft(2, '0')}";
    final monthTxs = finProv.transactions.where((tx) => tx.date.startsWith(monthStr)).toList();

    Map<String, double> incomeByCategory = {};
    Map<String, double> expenseByCategory = {};
    
    for (var tx in monthTxs) {
      if (tx.type == 'income') {
        incomeByCategory[tx.category] = (incomeByCategory[tx.category] ?? 0) + tx.amount;
      } else {
        expenseByCategory[tx.category] = (expenseByCategory[tx.category] ?? 0) + tx.amount;
      }
    }

    List<PieChartSectionData> _buildPieSections(Map<String, double> data, Color baseColor) {
      if (data.isEmpty) return [PieChartSectionData(value: 1, color: Colors.grey.shade300, title: 'No Data')];
      
      final List<Color> shades = [
        baseColor,
        baseColor.withValues(alpha: 0.8),
        baseColor.withValues(alpha: 0.6),
        baseColor.withValues(alpha: 0.4),
        baseColor.withValues(alpha: 0.2),
      ];
      
      int i = 0;
      return data.entries.map((e) {
        final c = shades[i % shades.length];
        i++;
        return PieChartSectionData(
          value: e.value,
          color: c,
          title: '${e.key}\n${CurrencyFormatter.formatSimple(e.value, sym)}',
          radius: 60,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        );
      }).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => widget.onMonthChanged(DateTime(widget.selectedMonth.year, widget.selectedMonth.month - 1)),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    // Note: A real month picker would be better here, but date picker works as fallback
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: widget.selectedMonth,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) widget.onMonthChanged(picked);
                  },
                  child: Text(
                    DateFormat.yMMMM().format(widget.selectedMonth), 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () => widget.onMonthChanged(DateTime(widget.selectedMonth.year, widget.selectedMonth.month + 1)),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text('Income by Category', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.green)),
                SizedBox(
                  height: 200,
                  child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 40, sections: _buildPieSections(incomeByCategory, AppColors.green))),
                ),
                
                const SizedBox(height: 20),
                
                const Text('Expense by Category', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.red)),
                SizedBox(
                  height: 200,
                  child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 40, sections: _buildPieSections(expenseByCategory, AppColors.red))),
                ),
                
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Align(alignment: Alignment.centerLeft, child: Text('Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brown))),
                ),
                
                ...monthTxs.map((tx) {
                  final isIncome = tx.type == 'income';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isIncome ? AppColors.green.withValues(alpha: 0.1) : AppColors.red.withValues(alpha: 0.1),
                      child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? AppColors.green : AppColors.red),
                    ),
                    title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(tx.date),
                    trailing: Text('${isIncome ? '+' : '-'} ${CurrencyFormatter.formatSimple(tx.amount, sym)}', 
                      style: TextStyle(color: isIncome ? AppColors.green : AppColors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                  );
                }),
              ],
            ),
          ),
        )
      ],
    );
  }
}
