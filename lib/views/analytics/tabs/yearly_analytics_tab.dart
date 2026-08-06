import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';

class YearlyAnalyticsTab extends StatefulWidget {
  final int selectedYear;
  final Function(int) onYearChanged;
  const YearlyAnalyticsTab({super.key, required this.selectedYear, required this.onYearChanged});
  

  @override
  State<YearlyAnalyticsTab> createState() => _YearlyAnalyticsTabState();
}

class _YearlyAnalyticsTabState extends State<YearlyAnalyticsTab> {
  

  @override
  Widget build(BuildContext context) {
    final finProv = Provider.of<FinanceProvider>(context);
    final sym = Provider.of<ThemeProvider>(context).currencySymbol;

    List<double> monthlyIncome = List.filled(12, 0.0);
    List<double> monthlyExpense = List.filled(12, 0.0);

    for (var tx in finProv.transactions) {
      final txDate = DateTime.parse(tx.date);
      if (txDate.year == widget.selectedYear) {
        if (tx.type == 'income') {
          monthlyIncome[txDate.month - 1] += tx.amount;
        } else {
          monthlyExpense[txDate.month - 1] += tx.amount;
        }
      }
    }

    double maxVal = 0.0;
    for (int i = 0; i < 12; i++) {
      if (monthlyIncome[i] > maxVal) maxVal = monthlyIncome[i];
      if (monthlyExpense[i] > maxVal) maxVal = monthlyExpense[i];
    }
    if (maxVal == 0) maxVal = 100;

    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];
    for (int i = 0; i < 12; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), monthlyIncome[i]));
      expenseSpots.add(FlSpot(i.toDouble(), monthlyExpense[i]));
    }

    LineChartBarData _buildLine(List<FlSpot> spots, Color color) {
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }

    final monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => widget.onYearChanged(widget.selectedYear - 1)),
              Expanded(child: Text('${widget.selectedYear}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => widget.onYearChanged(widget.selectedYear + 1)),
            ],
          ),
        ),
        
        Container(
          height: 300,
          padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white1,
            borderRadius: BorderRadius.circular(20),
          ),
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(enabled: true),
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 2,
                    getTitlesWidget: (val, meta) => Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(monthLabels[val.toInt() % 12], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 11,
              minY: 0,
              maxY: maxVal * 1.2,
              lineBarsData: [
                _buildLine(incomeSpots, AppColors.green),
                _buildLine(expenseSpots, AppColors.red),
              ],
            ),
          ),
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, color: AppColors.green, size: 12), SizedBox(width: 4), Text('Income'),
              SizedBox(width: 16),
              Icon(Icons.circle, color: AppColors.red, size: 12), SizedBox(width: 4), Text('Expense'),
            ],
          ),
        ),
        
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Align(alignment: Alignment.centerLeft, child: Text('Monthly Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brown))),
        ),
        
        Expanded(
          child: ListView.builder(
            itemCount: 12,
            itemBuilder: (context, index) {
              if (monthlyIncome[index] == 0 && monthlyExpense[index] == 0) return const SizedBox.shrink();
              return ListTile(
                title: Text(monthLabels[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Inc: ${CurrencyFormatter.formatSimple(monthlyIncome[index], sym)} | Exp: ${CurrencyFormatter.formatSimple(monthlyExpense[index], sym)}'),
                trailing: Text(
                  CurrencyFormatter.formatSimple(monthlyIncome[index] - monthlyExpense[index], sym),
                  style: TextStyle(
                    color: (monthlyIncome[index] - monthlyExpense[index]) >= 0 ? AppColors.green : AppColors.red,
                    fontWeight: FontWeight.bold,
                  )
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
