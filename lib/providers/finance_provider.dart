import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../models/transaction_model.dart';
import '../models/loan_model.dart';
import '../models/savings_model.dart';
import '../models/budget_model.dart';
import '../models/donation_model.dart';
import '../services/database_helper.dart';

enum FilterTimeFrame { all, today, thisMonth, thisYear, custom }

class FinanceProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<LoanModel> _loans = [];
  List<SavingsModel> _savings = [];
  List<BudgetModel> _budgets = [];
  List<DonationModel> _donations = [];
  
  bool _isLoading = false;
  String _selectedCategory = 'all';
  String _selectedType = 'all'; // 'all', 'income', 'expense', 'loan', 'owe'
  FilterTimeFrame _timeFrame = FilterTimeFrame.all;
  DateTimeRange? _customDateRange;
  
  bool _resetBalanceMonthly = true;
  bool get resetBalanceMonthly => _resetBalanceMonthly;

  // Last deleted item for Command / Undo functionality
  TransactionModel? _lastDeletedTransaction;
  LoanModel? _lastDeletedLoan;

  List<TransactionModel> get transactions => _filteredTransactions;
  List<LoanModel> get loans => _filteredLoans;
  List<SavingsModel> get savings => _savings;
  List<BudgetModel> get budgets => _budgets;
  List<DonationModel> get donations => _donations;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get selectedType => _selectedType;
  FilterTimeFrame get timeFrame => _timeFrame;
  DateTimeRange? get customDateRange => _customDateRange;

  // Financial Metrics
  double get totalIncome {
    final now = DateTime.now();
    return _transactions.where((t) {
      if (t.type != 'income') return false;
      if (_resetBalanceMonthly) {
        final tDate = DateTime.tryParse(t.date);
        if (tDate != null && (tDate.year != now.year || tDate.month != now.month)) return false;
      }
      return true;
    }).fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    final now = DateTime.now();
    return _transactions.where((t) {
      if (t.type != 'expense') return false;
      if (_resetBalanceMonthly) {
        final tDate = DateTime.tryParse(t.date);
        if (tDate != null && (tDate.year != now.year || tDate.month != now.month)) return false;
      }
      return true;
    }).fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalLoanGiven {
    return _loans
        .where((l) => l.type == 'loan' && l.status == 'pending')
        .fold(0.0, (sum, l) => sum + (l.amount - l.amountPaid));
  }

  double get totalOweBorrowed {
    return _loans
        .where((l) => l.type == 'owe' && l.status == 'pending')
        .fold(0.0, (sum, l) => sum + (l.amount - l.amountPaid));
  }

  double get totalSavings {
    return _savings.fold(0.0, (sum, s) => sum + s.balance);
  }

  double get netBalance {
    return totalIncome - totalExpense;
  }

  FinanceProvider() {
    _loadPrefsAndData();
  }

  Future<void> _loadPrefsAndData() async {
    final prefs = await SharedPreferences.getInstance();
    _resetBalanceMonthly = prefs.getBool('reset_balance_monthly') ?? true;
    await fetchData();
  }

  Future<void> toggleResetBalanceMonthly(bool value) async {
    _resetBalanceMonthly = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reset_balance_monthly', value);
    notifyListeners();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    _transactions = await DatabaseHelper.instance.getAllTransactions();
    _loans = await DatabaseHelper.instance.getAllLoans();
    _savings = await DatabaseHelper.instance.getAllSavings();
    _budgets = await DatabaseHelper.instance.getAllBudgets();
    _donations = await DatabaseHelper.instance.getDonations();

    _isLoading = false;
    notifyListeners();
  }

  // --- Filtering Logic ---
  List<TransactionModel> get _filteredTransactions {
    return _transactions.where((t) {
      if (_selectedType != 'all' && _selectedType != t.type) return false;
      if (_selectedCategory != 'all' && _selectedCategory != t.category) return false;

      final tDate = DateTime.tryParse(t.date);
      if (tDate == null) return true;

      final now = DateTime.now();

      switch (_timeFrame) {
        case FilterTimeFrame.today:
          return tDate.year == now.year && tDate.month == now.month && tDate.day == now.day;
        case FilterTimeFrame.thisMonth:
          return tDate.year == now.year && tDate.month == now.month;
        case FilterTimeFrame.thisYear:
          return tDate.year == now.year;
        case FilterTimeFrame.custom:
          if (_customDateRange != null) {
            return tDate.isAfter(_customDateRange!.start.subtract(const Duration(days: 1))) &&
                tDate.isBefore(_customDateRange!.end.add(const Duration(days: 1)));
          }
          return true;
        case FilterTimeFrame.all:
        default:
          return true;
      }
    }).toList();
  }

  List<LoanModel> get _filteredLoans {
    return _loans.where((l) {
      if (_selectedType != 'all' && _selectedType != l.type) return false;
      return true;
    }).toList();
  }

  void setFilterType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setFilterCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setTimeFrame(FilterTimeFrame frame, {DateTimeRange? customRange}) {
    _timeFrame = frame;
    _customDateRange = customRange;
    notifyListeners();
  }

  void resetFilters() {
    _selectedType = 'all';
    _selectedCategory = 'all';
    _timeFrame = FilterTimeFrame.all;
    _customDateRange = null;
    notifyListeners();
  }

  // --- Transaction Operations ---
  Future<void> addTransaction(TransactionModel tx) async {
    await DatabaseHelper.instance.insertTransaction(tx);
    await fetchData();
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    await DatabaseHelper.instance.updateTransaction(tx);
    await fetchData();
  }

  Future<void> deleteTransaction(TransactionModel tx) async {
    _lastDeletedTransaction = tx;
    if (tx.id != null) {
      await DatabaseHelper.instance.deleteTransaction(tx.id!);
      await fetchData();
    }
  }

  Future<void> undoDeleteTransaction() async {
    if (_lastDeletedTransaction != null) {
      await DatabaseHelper.instance.insertTransaction(_lastDeletedTransaction!);
      _lastDeletedTransaction = null;
      await fetchData();
    }
  }

  // --- Loan Operations ---
  Future<void> addLoan(LoanModel loan) async {
    await DatabaseHelper.instance.insertLoan(loan);
    await fetchData();
  }

  Future<void> updateLoan(LoanModel loan) async {
    await DatabaseHelper.instance.updateLoan(loan);
    await fetchData();
  }

  Future<void> addLoanInstallment(int loanId, double installmentAmount, String date, {bool logToTransactions = false}) async {
    final idx = _loans.indexWhere((l) => l.id == loanId);
    if (idx != -1) {
      final loan = _loans[idx];
      List<dynamic> parsedInstallments = [];
      try {
        parsedInstallments = jsonDecode(loan.installments);
      } catch (e) {}

      parsedInstallments.add({
        'amount': installmentAmount,
        'date': date,
      });

      final newAmountPaid = loan.amountPaid + installmentAmount;
      String newStatus = loan.status;
      if (newAmountPaid >= loan.amount) {
        newStatus = 'settled';
      }

      final updatedLoan = LoanModel(
        id: loan.id,
        personName: loan.personName,
        phoneNumber: loan.phoneNumber,
        amount: loan.amount,
        amountPaid: newAmountPaid,
        type: loan.type,
        dueDate: loan.dueDate,
        status: newStatus,
        installments: jsonEncode(parsedInstallments),
        note: loan.note,
        createdAt: loan.createdAt,
      );

      await DatabaseHelper.instance.updateLoan(updatedLoan);
      
      if (logToTransactions) {
        final tx = TransactionModel(
          title: 'Loan Installment: ${loan.personName}',
          amount: installmentAmount,
          date: date,
          category: 'Loan',
          type: loan.type == 'loan' ? 'income' : 'expense',
          createdAt: DateTime.now().toIso8601String(),
        );
        await DatabaseHelper.instance.insertTransaction(tx);
      }
      
      await fetchData();
    }
  }

  Future<void> completeLoan(int loanId) async {
    final idx = _loans.indexWhere((l) => l.id == loanId);
    if (idx != -1) {
      final loan = _loans[idx];
      final updatedLoan = LoanModel(
        id: loan.id,
        personName: loan.personName,
        phoneNumber: loan.phoneNumber,
        amount: loan.amount,
        amountPaid: loan.amount, // fully paid
        type: loan.type,
        dueDate: loan.dueDate,
        status: 'settled',
        installments: loan.installments,
        note: loan.note,
        createdAt: loan.createdAt,
      );
      await DatabaseHelper.instance.updateLoan(updatedLoan);
      await fetchData();
    }
  }

  Future<void> toggleLoanStatus(LoanModel loan) async {
    final newStatus = loan.status == 'pending' ? 'settled' : 'pending';
    if (loan.id != null) {
      final updatedLoan = LoanModel(
        id: loan.id,
        personName: loan.personName,
        phoneNumber: loan.phoneNumber,
        amount: loan.amount,
        amountPaid: newStatus == 'settled' ? loan.amount : loan.amountPaid,
        type: loan.type,
        dueDate: loan.dueDate,
        status: newStatus,
        installments: loan.installments,
        note: loan.note,
        createdAt: loan.createdAt,
      );
      await DatabaseHelper.instance.updateLoan(updatedLoan);
      await fetchData();
    }
  }

  Future<void> deleteLoan(LoanModel loan) async {
    _lastDeletedLoan = loan;
    if (loan.id != null) {
      await DatabaseHelper.instance.deleteLoan(loan.id!);
      await fetchData();
    }
  }

  Future<void> undoDeleteLoan() async {
    if (_lastDeletedLoan != null) {
      await DatabaseHelper.instance.insertLoan(_lastDeletedLoan!);
      _lastDeletedLoan = null;
      await fetchData();
    }
  }

  // --- Savings Operations ---
  Future<void> addSavingsAccount(SavingsModel saving) async {
    await DatabaseHelper.instance.insertSavings(saving);
    await fetchData();
  }

  Future<void> updateSavingsAccount(SavingsModel saving) async {
    await DatabaseHelper.instance.updateSavings(saving);
    await fetchData();
  }

  Future<void> deleteSavingsAccount(int id) async {
    await DatabaseHelper.instance.deleteSavings(id);
    await fetchData();
  }

  Future<void> addSavingsTransaction(int savingsId, double amount, String type, String date, {bool logToTransactions = false}) async {
    final idx = _savings.indexWhere((s) => s.id == savingsId);
    if (idx != -1) {
      final acc = _savings[idx];
      List<dynamic> parsedTransactions = [];
      try {
        parsedTransactions = jsonDecode(acc.transactions);
      } catch (e) {}

      parsedTransactions.add({
        'type': type, // 'add' or 'retrieve'
        'amount': amount,
        'date': date,
      });

      double newBalance = acc.balance;
      if (type == 'add') {
        newBalance += amount;
      } else if (type == 'retrieve') {
        newBalance -= amount;
        if (newBalance < 0) newBalance = 0; // Prevent negative balance if desired
      }

      final updatedAcc = SavingsModel(
        id: acc.id,
        bankName: acc.bankName,
        accountNumber: acc.accountNumber,
        branchAddress: acc.branchAddress,
        balance: newBalance,
        transactions: jsonEncode(parsedTransactions),
        createdAt: acc.createdAt,
      );

      await DatabaseHelper.instance.updateSavings(updatedAcc);
      
      if (logToTransactions) {
        final tx = TransactionModel(
          title: 'Savings ${type == 'add' ? 'Deposit' : 'Withdrawal'}: ${acc.bankName}',
          amount: amount,
          date: date,
          category: 'Savings',
          type: type == 'add' ? 'expense' : 'income', // Depositing into savings is an expense from main balance. Withdrawing is income.
          createdAt: DateTime.now().toIso8601String(),
        );
        await DatabaseHelper.instance.insertTransaction(tx);
      }

      await fetchData();
    }
  }

  // --- Budget Operations ---
  Future<void> addBudgetMonth(BudgetModel budget) async {
    await DatabaseHelper.instance.insertBudget(budget);
    await fetchData();
  }

  Future<void> updateBudgetMonth(BudgetModel budget) async {
    await DatabaseHelper.instance.updateBudget(budget);
    await fetchData();
  }

  Future<void> deleteBudgetMonth(int id) async {
    await DatabaseHelper.instance.deleteBudget(id);
    await fetchData();
  }

  Future<void> addBudgetCategory(int budgetId, String category, double amount) async {
    final idx = _budgets.indexWhere((b) => b.id == budgetId);
    if (idx != -1) {
      final b = _budgets[idx];
      List<dynamic> parsed = [];
      try {
        parsed = jsonDecode(b.budgets);
      } catch (e) {}

      parsed.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'category': category,
        'amount': amount,
        'spent': 0.0,
      });

      final updated = BudgetModel(
        id: b.id,
        monthYear: b.monthYear,
        budgets: jsonEncode(parsed),
        createdAt: b.createdAt,
      );
      await DatabaseHelper.instance.updateBudget(updated);
      await fetchData();
    }
  }

  Future<void> adjustBudgetCategory(int budgetId, String catId, double change) async {
    final idx = _budgets.indexWhere((b) => b.id == budgetId);
    if (idx != -1) {
      final b = _budgets[idx];
      List<dynamic> parsed = [];
      try {
        parsed = jsonDecode(b.budgets);
      } catch (e) {}

      for (var item in parsed) {
        if (item['id'] == catId) {
          double amt = (item['amount'] as num).toDouble();
          item['amount'] = (amt + change) < 0 ? 0 : (amt + change);
          break;
        }
      }

      final updated = BudgetModel(
        id: b.id,
        monthYear: b.monthYear,
        budgets: jsonEncode(parsed),
        createdAt: b.createdAt,
      );
      await DatabaseHelper.instance.updateBudget(updated);
      await fetchData();
    }
  }

  Future<void> logBudgetExpense(int budgetId, String catId, double expense, {bool logToTransactions = false}) async {
    final idx = _budgets.indexWhere((b) => b.id == budgetId);
    if (idx != -1) {
      final b = _budgets[idx];
      List<dynamic> parsed = [];
      try {
        parsed = jsonDecode(b.budgets);
      } catch (e) {}

      String catName = 'Budget';
      for (var item in parsed) {
        if (item['id'] == catId) {
          catName = item['category'];
          double spent = (item['spent'] as num).toDouble();
          item['spent'] = spent + expense;
          break;
        }
      }

      final updated = BudgetModel(
        id: b.id,
        monthYear: b.monthYear,
        budgets: jsonEncode(parsed),
        createdAt: b.createdAt,
      );
      await DatabaseHelper.instance.updateBudget(updated);

      if (logToTransactions) {
        final tx = TransactionModel(
          title: 'Budget Spent: $catName',
          amount: expense,
          date: DateTime.now().toIso8601String().split('T')[0],
          category: 'Budget',
          type: 'expense',
          createdAt: DateTime.now().toIso8601String(),
        );
        await DatabaseHelper.instance.insertTransaction(tx);
      }

      await fetchData();
    }
  }

  // --- Donations ---
  Future<void> fetchDonations() async {
    _donations = await DatabaseHelper.instance.getDonations();
    notifyListeners();
  }

  Future<void> addDonation(DonationModel donation) async {
    try {
      await DatabaseHelper.instance.insertDonation(donation);
      await fetchDonations();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> updateDonation(DonationModel donation) async {
    try {
      await DatabaseHelper.instance.updateDonation(donation);
      await fetchDonations();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> deleteDonation(int id) async {
    try {
      await DatabaseHelper.instance.deleteDonation(id);
      await fetchDonations();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> addDonationExpense(int donationId, double amountPaid, String note) async {
    final donation = _donations.firstWhere((d) => d.id == donationId);
    
    // Add transaction
    final tx = TransactionModel(
      title: 'Donation: ${donation.organizationName}',
      amount: amountPaid,
      type: 'expense',
      category: 'donation',
      date: DateTime.now().toIso8601String().split('T')[0],
      note: note,
      createdAt: DateTime.now().toIso8601String(),
    );
    await addTransaction(tx);

    // Update donation
    final updated = DonationModel(
      id: donation.id,
      organizationName: donation.organizationName,
      amount: donation.amount,
      totalDonated: donation.totalDonated + amountPaid,
      note: donation.note,
      createdAt: donation.createdAt,
    );
    await updateDonation(updated);
  }
}
