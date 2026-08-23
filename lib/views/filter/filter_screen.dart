import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';
import 'package:aybay_flutter/models/transaction_model.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/views/navigation/main_navigation_screen.dart';

class FilterScreen extends StatefulWidget {
  final String? initialType;
  const FilterScreen({super.key, this.initialType});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _isSearchVisible = false;
  String _timeFilter = 'monthly'; // 'daily', 'monthly', 'yearly'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSuccessAnimation() {
    BuildContext? dialogContext;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          dialogContext = ctx;
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/success.json',
                    width: 200, height: 200, repeat: false),
              ],
            ),
          );
        });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
      }
    });
  }

  void _showEditDialog(TransactionModel tx, FinanceProvider finProv) {
    final amountController = TextEditingController(text: tx.amount.toString());
    final reasonController = TextEditingController(text: tx.title);
    final customCatController = TextEditingController();

    DateTime selectedDate = DateTime.tryParse(tx.date) ?? DateTime.now();

    List<String> categories =
        finProv.transactions.map((t) => t.category).toSet().toList();
    categories.removeWhere((c) => c.trim().isEmpty);
    if (!categories.contains(tx.category)) categories.add(tx.category);
    categories.add('Custom...');

    String selectedCategory =
        categories.contains(tx.category) ? tx.category : categories.first;

    final isIncome = tx.type == 'income';
    final themeColor = isIncome ? AppColors.green : AppColors.brown;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/animations/update_data.json',
                        width: 120, height: 120),
                    Text(
                      'Edit ${isIncome ? 'Income' : 'Expense'}',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: themeColor),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Amount',
                        prefixIcon: Icon(Icons.attach_money, color: themeColor),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: 'Enter Reason',
                        prefixIcon: Icon(Icons.comment, color: themeColor),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                  colorScheme:
                                      ColorScheme.light(primary: themeColor)),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: themeColor),
                            const SizedBox(width: 12),
                            Text(
                              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color ??
                                      AppColors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedCategory,
                          dropdownColor:
                              Theme.of(context).dialogBackgroundColor,
                          icon: Icon(Icons.arrow_drop_down, color: themeColor),
                          items: categories
                              .map((cat) => DropdownMenuItem(
                                  value: cat, child: Text(cat)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => selectedCategory = val);
                          },
                        ),
                      ),
                    ),
                    if (selectedCategory == 'Custom...') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: customCatController,
                        decoration: InputDecoration(
                          labelText: 'Enter Custom Category',
                          prefixIcon: Icon(Icons.category, color: themeColor),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final amount =
                            double.tryParse(amountController.text.trim()) ??
                                0.0;
                        final reason = reasonController.text.trim();
                        if (amount <= 0) return;

                        String finalCat = selectedCategory;
                        if (selectedCategory == 'Custom...') {
                          if (customCatController.text.trim().isEmpty) return;
                          finalCat = customCatController.text.trim();
                        }

                        final dateStr =
                            "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

                        final updatedTx = TransactionModel(
                          id: tx.id,
                          title: reason.isEmpty ? 'Record' : reason,
                          amount: amount,
                          type: tx.type,
                          category: finalCat,
                          date: dateStr,
                          createdAt: tx.createdAt,
                        );

                        await finProv.updateTransaction(updatedTx);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          _showSuccessAnimation();
                        }
                      },
                      child: const Text('Update Transaction',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final finProv = Provider.of<FinanceProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);
    final now = DateTime.now();

    final filteredList = finProv.transactions.where((t) {
      if (widget.initialType != null && t.type != widget.initialType)
        return false;

      final tDate = DateTime.tryParse(t.date);
      if (tDate != null) {
        if (_timeFilter == 'daily' &&
            (tDate.year != now.year ||
                tDate.month != now.month ||
                tDate.day != now.day)) return false;
        if (_timeFilter == 'monthly' &&
            (tDate.year != now.year || tDate.month != now.month)) return false;
        if (_timeFilter == 'yearly' && tDate.year != now.year) return false;
      }

      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        if (!t.title.toLowerCase().contains(q) &&
            !t.category.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();

    String titleText = 'History';
    if (widget.initialType == 'income') titleText = 'Income History';
    if (widget.initialType == 'expense') titleText = 'Expense History';

    final Color headerColor = widget.initialType == 'income'
        ? AppColors.green
        : (widget.initialType == 'expense' ? AppColors.brown : AppColors.blue);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: headerColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              (route) => false),
        ),
        title: Text(titleText,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () =>
                setState(() => _isSearchVisible = !_isSearchVisible),
          ),
        ],
      ),
      body: Column(
        children: [
          // Immersive Header
          Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                if (_isSearchVisible) ...[
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _query = val),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: false,
                      labelText: 'Search',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.white54)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Time Filters
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeFilterButton('Daily', 'daily', headerColor),
                    _buildTimeFilterButton('Monthly', 'monthly', headerColor),
                    _buildTimeFilterButton('Yearly', 'yearly', headerColor),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: filteredList.isEmpty
                ? const Center(
                    child: Text('No data found for this period',
                        style: TextStyle(fontSize: 16, color: Colors.grey)))
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final isIncome = item.type == 'income';

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (isIncome
                                        ? AppColors.green
                                        : AppColors.brown)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                isIncome
                                    ? 'assets/images/add_income.png'
                                    : 'assets/images/add_expense.png',
                                width: 28,
                                height: 28,
                                color: isIncome
                                    ? AppColors.green
                                    : AppColors.brown,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text("${item.date} • ${item.category}",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.formatSimple(
                                      item.amount, themeProv.currencySymbol),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isIncome
                                        ? AppColors.green
                                        : AppColors.brown,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.grey),
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showEditDialog(item, finProv);
                                } else if (val == 'delete' && item.id != null) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Are you sure?',
                                          style: TextStyle(
                                              color: AppColors.brown)),
                                      content: const Text(
                                          'Do you really want to delete this transaction?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel',
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white),
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            finProv.deleteTransaction(item);
                                            _showSuccessAnimation();
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(children: [
                                      Icon(Icons.edit,
                                          color: AppColors.brown, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit')
                                    ])),
                                const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(children: [
                                      Icon(Icons.delete,
                                          color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text('Delete')
                                    ])),
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

  Widget _buildTimeFilterButton(String label, String value, Color headerColor) {
    final isSelected = _timeFilter == value;
    return InkWell(
      onTap: () => setState(() => _timeFilter = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.white : Colors.white54),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? headerColor : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
