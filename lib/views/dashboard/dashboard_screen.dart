import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/models/transaction_model.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/providers/auth_provider.dart';
import 'package:aybay_flutter/views/auth/login_screen.dart';
import 'package:aybay_flutter/views/filter/filter_screen.dart';
import 'package:aybay_flutter/views/walleo_ai/walleo_ai_chat_screen.dart';
import 'package:aybay_flutter/views/backup/backup_restore_screen.dart';
import 'package:aybay_flutter/views/profile/profile_settings_screen.dart';
import 'package:aybay_flutter/views/events/events_screen.dart';
import 'package:aybay_flutter/views/loans/loan_screen.dart';
import 'package:aybay_flutter/views/savings/savings_screen.dart';
import 'package:aybay_flutter/views/budget/budget_screen.dart';
import 'package:aybay_flutter/views/analytics/analytics_screen.dart';
import 'package:aybay_flutter/views/donations/donation_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finProv = Provider.of<FinanceProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);
    Color cardColor;
    switch (themeProv.cardThemeIndex) {
      case 0:
        cardColor = AppColors.green;
        break;
      case 1:
        cardColor = Colors.blue.shade700;
        break;
      case 2:
        cardColor = Colors.grey.shade900;
        break;
      case 3:
        cardColor = Colors.deepPurple.shade700;
        break;
      case 4:
        cardColor = Colors.orange.shade800;
        break;
      case 5:
      case 6:
        cardColor = Colors.black87; // Base color for shadow when image is used
        break;
      default:
        cardColor = AppColors.green;
    }

    DecorationImage? cardImage;
    if (themeProv.cardThemeIndex == 5) {
      cardImage = const DecorationImage(
          image: AssetImage('assets/images/vangogh_card.jpg'),
          fit: BoxFit.cover,
          opacity: 0.85);
    } else if (themeProv.cardThemeIndex == 6) {
      cardImage = const DecorationImage(
          image: AssetImage('assets/images/cartoon_card.jpg'),
          fit: BoxFit.cover,
          opacity: 0.85);
    }

    final sym = themeProv.currencySymbol;
    final authProv = Provider.of<AuthProvider>(context);

    // Calculate Valid From/Thru dates
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final validFrom = "01/${now.month.toString().padLeft(2, '0')}";
    final validThru =
        "${lastDay.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        title: const Text('Welcome back',
            style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.green),
              child: const Icon(Icons.settings, color: Colors.white, size: 18),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProfileSettingsScreen()));
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary),
              child: const Icon(Icons.logout, color: Colors.white, size: 18),
            ),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Premium Custom Credit Card Balance Section
              Container(
                width: double.infinity,
                height: 235,
                decoration: BoxDecoration(
                  color: cardImage == null ? cardColor : null,
                  image: cardImage,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: cardColor.withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // --- Geometric Background Designs ---
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -80,
                        left: -40,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 100,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),

                      // Gradient overlay for better text/logo visibility on image backgrounds
                      if (themeProv.cardThemeIndex >= 5)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.6),
                                Colors.black.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),

                      // --- Card Content ---

                      // NFC Logo (Top Right)
                      const Positioned(
                        top: 20,
                        right: 20,
                        child: Icon(Icons.contactless_rounded,
                            color: Colors.white70, size: 28),
                      ),

                      // Total Balance (Top Left)
                      Positioned(
                        top: 44,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL BALANCE',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.formatSimple(
                                  finProv.netBalance, sym),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Copper Chip (Middle Right)
                      const Positioned(
                        top: 90,
                        right: 40,
                        child: Icon(Icons.memory_rounded,
                            color: AppColors.vibrantGold, size: 44),
                      ),

                      // Validity (Centered below Balance)
                      if (finProv.resetBalanceMonthly)
                        Positioned(
                          bottom: 60,
                          left: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('VALID',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 6,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0)),
                                  Text('FROM',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 6,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0)),
                                ],
                              ),
                              const SizedBox(width: 4),
                              Text(validFrom,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5)),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('VALID',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 6,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0)),
                                  Text('THRU',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 6,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0)),
                                ],
                              ),
                              const SizedBox(width: 4),
                              Text(validThru,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5)),
                            ],
                          ),
                        ),

                      // User Name (Bottom Left)
                      Positioned(
                        bottom: 24,
                        left: 20,
                        child: Text(
                          authProv.userName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),

                      // AyBay Logo (Bottom Right)
                      Positioned(
                        bottom: 0,
                        right: 12,
                        child: Image.asset(
                          'assets/images/aybay-logo.png',
                          height: 70,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Multi-Color Brand Buttons for Adding Income & Expense
              Row(
                children: [
                  Expanded(
                    child: _buildSolidColorBrandButton(
                      icon: Icons.add_circle_outline,
                      label: 'Add Income',
                      color: AppColors.green,
                      onTap: () =>
                          _showAddTransactionDialog(context, 'income', finProv),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSolidColorBrandButton(
                      icon: Icons.remove_circle_outline,
                      label: 'Add Expense',
                      color: AppColors.brown,
                      onTap: () => _showAddTransactionDialog(
                          context, 'expense', finProv),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.grey, height: 20),

              // 4. Financial Metrics Summary Cards
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Income',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    AppColors.black)),
                        Text(
                            CurrencyFormatter.formatSimple(
                                finProv.totalIncome, sym),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.green)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Expense',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    AppColors.black)),
                        Text(
                            CurrencyFormatter.formatSimple(
                                finProv.totalExpense, sym),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brown)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.grey, height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Loan',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    AppColors.black)),
                        Text(
                            CurrencyFormatter.formatSimple(
                                finProv.totalLoanGiven, sym),
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF5722))),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Owe',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    AppColors.black)),
                        Text(
                            CurrencyFormatter.formatSimple(
                                finProv.totalOweBorrowed, sym),
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.purple)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Savings',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    AppColors.black)),
                        Text(
                            CurrencyFormatter.formatSimple(
                                finProv.totalSavings, sym),
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.vibrantGold)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.grey, height: 20),

              // Row 1: Income, Expense, Loan, Owe
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: _buildVectorGridButton(context: context, 
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Income',
                    color: AppColors.green,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const FilterScreen(initialType: 'income'))),
                  )),
                  Expanded(
                      child: _buildVectorGridButton(context: context, 
                    icon: Icons.receipt_long_rounded,
                    label: 'Expense',
                    color: AppColors.brown,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const FilterScreen(initialType: 'expense'))),
                  )),
                  Expanded(
                      child: _buildVectorGridButton(context: context, 
                    icon: Icons.handshake_rounded,
                    label: 'Loan',
                    color: const Color(0xFFFF5722),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const LoanScreen(initialType: 'loan'))),
                  )),
                  Expanded(
                      child: _buildVectorGridButton(context: context, 
                    icon: Icons.credit_score_rounded,
                    label: 'Owe',
                    color: AppColors.purple,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const LoanScreen(initialType: 'owe'))),
                  )),
                ],
              ),
              const SizedBox(height: 20),

              // Row 2: Savings, Budget, Donations, Daily
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: _buildVectorGridButton(context: context, 
                    icon: Icons.savings_rounded,
                    label: 'Savings',
                    color: AppColors.vibrantGold,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SavingsScreen())),
                  )),
                  Expanded(
                      child: _buildVectorGridButton(context: context, 
                    icon: Icons.pie_chart_rounded,
                    label: 'Budget',
                    color: AppColors.green,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BudgetScreen())),
                  )),
                  Expanded(
                      child: _buildVectorGridButton(context: context, 
                    icon: Icons.favorite_rounded,
                    label: 'Donations',
                    color: AppColors.purple,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DonationScreen())),
                  )),
                  Expanded(
                      child: _buildVectorGridButton(context: context, 
                    icon: Icons.event_available_rounded,
                    label: 'Event\nManagement',
                    color: AppColors.blue,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EventsScreen())),
                  )),
                ],
              ),
              const SizedBox(height: 20),

              // Row 3: Daily, Monthly, Yearly, Backup/Restore
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: _buildVectorGridButton(context: context, 
                    icon: Icons.insert_chart_rounded,
                    label: 'Daily Analytics',
                    color: AppColors.blue,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const AnalyticsScreen(initialTab: 0))),
                  )),
                  Expanded(
                      child: _buildVectorGridButton(context: context, 
                    icon: Icons.pie_chart_outline_rounded,
                    label: 'Monthly Analytics',
                    color: AppColors.vibrantGold,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const AnalyticsScreen(initialTab: 1))),
                  )),
                  Expanded(
                      child: _buildVectorGridButton(context: context, 
                    icon: Icons.ssid_chart_rounded,
                    label: 'Yearly Analytics',
                    color: AppColors.red,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const AnalyticsScreen(initialTab: 2))),
                  )),
                  Expanded(
                      child: _buildVectorGridButton(context: context, 
                    icon: Icons.sd_storage_rounded,
                    label: 'Backup/Restore',
                    color: AppColors.deepTeal,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BackupRestoreScreen())),
                  )),
                ],
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Multi-Color Gradient Top Add Buttons
  Widget _buildSolidColorBrandButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // Multi-Color Vector Action Grid Buttons
  Widget _buildVectorGridButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 36, // Ensure uniform height for text so icons align
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      AppColors.black,
                  fontWeight: FontWeight.w600,
                  height: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessAnimation(BuildContext context) {
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

  void _showAddTransactionDialog(
      BuildContext context, String type, FinanceProvider finProv) {
    final isIncome = type == 'income';
    final themeColor = isIncome ? AppColors.green : AppColors.brown;

    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    final customCatController = TextEditingController();

    DateTime selectedDate = DateTime.now();

    // Extract unique categories from DB, and always append 'Custom...'
    List<String> categories =
        finProv.transactions.map((t) => t.category).toSet().toList();
    categories.removeWhere((c) => c.trim().isEmpty);
    categories.add('Custom...');

    String selectedCategory = categories.first;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lottie Animation
                    Lottie.asset('assets/animations/add_data.json',
                        width: 120, height: 120),

                    Text(
                      isIncome ? 'Add Income' : 'Add Expense',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: themeColor),
                    ),
                    const SizedBox(height: 20),

                    // Amount Field
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

                    // Reason Field
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

                    // Date Picker
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
                                    ColorScheme.light(primary: themeColor),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
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

                    // Category Dropdown
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
                          icon: Icon(Icons.arrow_drop_down, color: themeColor),
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedCategory = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    // Custom Category Field (Only shows if 'Custom...' is selected)
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

                    // Save Button
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

                        final tx = TransactionModel(
                          title: reason.isEmpty ? 'Record' : reason,
                          amount: amount,
                          type: type,
                          category: finalCat,
                          date: dateStr,
                          createdAt: DateTime.now().toIso8601String(),
                        );

                        await finProv.addTransaction(tx);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          _showSuccessAnimation(context);
                        }
                      },
                      child: const Text('Save Transaction',
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
}
