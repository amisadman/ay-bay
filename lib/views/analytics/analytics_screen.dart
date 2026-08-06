import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/views/analytics/tabs/daily_analytics_tab.dart';
import 'package:aybay_flutter/views/analytics/tabs/monthly_analytics_tab.dart';
import 'package:aybay_flutter/views/analytics/tabs/yearly_analytics_tab.dart';
import 'package:aybay_flutter/services/export_service.dart';
import 'package:aybay_flutter/models/transaction_model.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  final int initialTab;
  const AnalyticsScreen({super.key, this.initialTab = 0});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  int _selectedYear = DateTime.now().year;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  void _showExportOptions(BuildContext context, FinanceProvider finProv) {
    List<TransactionModel> filteredTxs = [];
    String reportPeriod = '';

    if (_tabController.index == 0) {
      final dateStr = _selectedDate.toIso8601String().split('T')[0];
      filteredTxs = finProv.transactions
          .where((tx) => tx.date.startsWith(dateStr))
          .toList();
      reportPeriod = DateFormat.yMMMd().format(_selectedDate);
    } else if (_tabController.index == 1) {
      final monthStr =
          "${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}";
      filteredTxs = finProv.transactions
          .where((tx) => tx.date.startsWith(monthStr))
          .toList();
      reportPeriod = DateFormat.yMMMM().format(_selectedMonth);
    } else {
      final yearStr = "${_selectedYear}-";
      filteredTxs = finProv.transactions
          .where((tx) => tx.date.startsWith(yearStr))
          .toList();
      reportPeriod = 'Year $_selectedYear';
    }

    final themeProv = Provider.of<ThemeProvider>(context, listen: false);
    final sym = themeProv.currencySymbol;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Export Analytics',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf,
                  color: AppColors.red, size: 30),
              title: const Text('Export as PDF'),
              subtitle: const Text('Save to Downloads folder'),
              onTap: () async {
                Navigator.pop(ctx);
                await ExportService.exportToPdf(
                  transactions: filteredTxs,
                  context: context,
                  currencySymbol: sym,
                  reportPeriod: reportPeriod,
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.table_view_rounded,
                  color: AppColors.green, size: 30),
              title: const Text('Export as Excel (XLSX)'),
              subtitle: const Text('Save to Downloads folder'),
              onTap: () async {
                Navigator.pop(ctx);
                await ExportService.exportToExcel(
                  transactions: filteredTxs,
                  context: context,
                  currencySymbol: sym,
                  reportPeriod: reportPeriod,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finProv = Provider.of<FinanceProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Analytics',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.white),
            onPressed: () => _showExportOptions(context, finProv),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Monthly'),
            Tab(text: 'Yearly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DailyAnalyticsTab(
            selectedDate: _selectedDate,
            onDateChanged: (d) => setState(() => _selectedDate = d),
          ),
          MonthlyAnalyticsTab(
            selectedMonth: _selectedMonth,
            onMonthChanged: (m) => setState(() => _selectedMonth = m),
          ),
          YearlyAnalyticsTab(
            selectedYear: _selectedYear,
            onYearChanged: (y) => setState(() => _selectedYear = y),
          ),
        ],
      ),
    );
  }
}
