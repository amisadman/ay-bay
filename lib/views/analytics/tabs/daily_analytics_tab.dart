import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class DailyAnalyticsTab extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  const DailyAnalyticsTab({super.key, required this.selectedDate, required this.onDateChanged});
  

  @override
  State<DailyAnalyticsTab> createState() => _DailyAnalyticsTabState();
}

class _DailyAnalyticsTabState extends State<DailyAnalyticsTab> {
  

  @override
  Widget build(BuildContext context) {
    final finProv = Provider.of<FinanceProvider>(context);
    final sym = Provider.of<ThemeProvider>(context).currencySymbol;

    final dateStr = widget.selectedDate.toIso8601String().split('T')[0];
    final todayTxs = finProv.transactions.where((tx) => tx.date.startsWith(dateStr)).toList();

    double income = 0;
    double expense = 0;
    for (var tx in todayTxs) {
      if (tx.type == 'income') income += tx.amount;
      if (tx.type == 'expense') expense += tx.amount;
    }

    // Check if it's today for a nice label
    final now = DateTime.now();
    final isToday = now.year == widget.selectedDate.year && now.month == widget.selectedDate.month && now.day == widget.selectedDate.day;
    final dateLabel = isToday ? 'Today, ${DateFormat.yMMMd().format(widget.selectedDate)}' : DateFormat.yMMMd().format(widget.selectedDate);

    return Column(
      children: [
        // Date Switcher
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => widget.onDateChanged(widget.selectedDate.subtract(const Duration(days: 1))),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: widget.selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) widget.onDateChanged(picked);
                  },
                  child: Text(
                    dateLabel, 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () => widget.onDateChanged(widget.selectedDate.add(const Duration(days: 1))),
              ),
            ],
          ),
        ),
        
        // Bar Chart
        Container(
          height: 250,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.white1,
            borderRadius: BorderRadius.circular(20),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (income > expense ? income : expense) * 1.2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) => Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(val == 0 ? 'Income' : 'Expense', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [BarChartRodData(toY: income, color: AppColors.green, width: 40, borderRadius: BorderRadius.circular(4))],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [BarChartRodData(toY: expense, color: AppColors.red, width: 40, borderRadius: BorderRadius.circular(4))],
                ),
              ],
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.centerLeft, 
            child: Text(isToday ? 'Today\'s Transactions' : 'Transactions', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brown))
          ),
        ),
        
        Expanded(
          child: todayTxs.isEmpty
              ? Center(child: Text(isToday ? 'No transactions today.' : 'No transactions on this date.', style: const TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: todayTxs.length,
                  itemBuilder: (context, index) {
                    final tx = todayTxs[index];
                    final isIncome = tx.type == 'income';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isIncome ? AppColors.green.withValues(alpha: 0.1) : AppColors.red.withValues(alpha: 0.1),
                        child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? AppColors.green : AppColors.red),
                      ),
                      title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(tx.category),
                      trailing: Text("${isIncome ? '+' : '-'} ${CurrencyFormatter.formatSimple(tx.amount, sym)}", 
                        style: TextStyle(color: isIncome ? AppColors.green : AppColors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    );
                  },
                ),
        )
      ],
    );
  }
}
