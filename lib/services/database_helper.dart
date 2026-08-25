import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';
import '../models/loan_model.dart';
import '../models/savings_model.dart';
import '../models/budget_model.dart';
import '../models/donation_model.dart';
import '../models/car_model.dart';
import '../models/tuition_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final List<TransactionModel> _webTransactions = [];
  final List<LoanModel> _webLoans = [];
  final List<SavingsModel> _webSavings = [];
  final List<BudgetModel> _webBudgets = [];
  final List<DonationModel> _webDonations = [];
  final List<CarModel> _webCars = [];
  final List<TuitionModel> _webTuitions = [];

  DatabaseHelper._init() {
    if (kIsWeb) {
      _seedWebDemoData();
    }
  }

  void _seedWebDemoData() {
    // No seed data for production release
  }

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('aybay_finance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 6) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS cars (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              carName TEXT NOT NULL,
              licensePlate TEXT NOT NULL,
              expenses TEXT NOT NULL,
              createdAt TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS tuitions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              studentName TEXT NOT NULL,
              institution TEXT NOT NULL,
              monthlyFee REAL NOT NULL,
              dueDate INTEGER NOT NULL,
              expenses TEXT NOT NULL,
              createdAt TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE loans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        personName TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        amount REAL NOT NULL,
        amountPaid REAL NOT NULL,
        type TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        status TEXT NOT NULL,
        installments TEXT NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        monthYear TEXT NOT NULL,
        budgets TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE savings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bankName TEXT NOT NULL,
        accountNumber TEXT NOT NULL,
        branchAddress TEXT NOT NULL,
        balance REAL NOT NULL,
        transactions TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        sender TEXT NOT NULL,
        text TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isActionExecuted INTEGER DEFAULT 0,
        actionDetails TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE donations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        organizationName TEXT NOT NULL,
        amount REAL NOT NULL,
        totalDonated REAL NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cars (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carName TEXT NOT NULL,
        licensePlate TEXT NOT NULL,
        expenses TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tuitions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentName TEXT NOT NULL,
        institution TEXT NOT NULL,
        monthlyFee REAL NOT NULL,
        dueDate INTEGER NOT NULL,
        expenses TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // No seed data inserted on database creation for production release
  }

  Future<int> insertTransaction(TransactionModel tx) async {
    if (kIsWeb) {
      _webTransactions.insert(0, tx);
      return 1;
    }
    final db = await instance.database;
    return await db!.insert('transactions', tx.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    if (kIsWeb) {
      return List.from(_webTransactions);
    }
    final db = await instance.database;
    final result =
        await db!.query('transactions', orderBy: 'date DESC, id DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<int> deleteTransaction(int id) async {
    if (kIsWeb) {
      _webTransactions.removeWhere((t) => t.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db!.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTransaction(TransactionModel tx) async {
    if (kIsWeb) {
      final index = _webTransactions.indexWhere((t) => t.id == tx.id);
      if (index != -1) _webTransactions[index] = tx;
      return 1;
    }
    final db = await instance.database;
    return await db!.update('transactions', tx.toMap(),
        where: 'id = ?', whereArgs: [tx.id]);
  }

  Future<int> insertLoan(LoanModel loan) async {
    if (kIsWeb) {
      _webLoans.insert(0, loan);
      return 1;
    }
    final db = await instance.database;
    return await db!.insert('loans', loan.toMap());
  }

  Future<List<LoanModel>> getAllLoans() async {
    if (kIsWeb) {
      return List.from(_webLoans);
    }
    final db = await instance.database;
    final result = await db!.query('loans', orderBy: 'dueDate ASC, id DESC');
    return result.map((json) => LoanModel.fromMap(json)).toList();
  }

  Future<int> updateLoan(LoanModel loan) async {
    if (kIsWeb) {
      final index = _webLoans.indexWhere((l) => l.id == loan.id);
      if (index != -1) _webLoans[index] = loan;
      return 1;
    }
    final db = await instance.database;
    return await db!
        .update('loans', loan.toMap(), where: 'id = ?', whereArgs: [loan.id]);
  }

  Future<int> deleteLoan(int id) async {
    if (kIsWeb) {
      _webLoans.removeWhere((l) => l.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db!.delete('loans', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllData() async {
    if (kIsWeb) {
      _webTransactions.clear();
      _webLoans.clear();
      _webSavings.clear();
      _webBudgets.clear();
      return;
    }
    final db = await instance.database;
    await db!.delete('transactions');
    await db.delete('loans');
    await db.delete('chat_messages');
    await db.delete('savings');
    await db.delete('budgets');
  }

  Future<int> insertSavings(SavingsModel savings) async {
    if (kIsWeb) {
      _webSavings.insert(0, savings);
      return 1;
    }
    final db = await instance.database;
    return await db!.insert('savings', savings.toMap());
  }

  Future<List<SavingsModel>> getAllSavings() async {
    if (kIsWeb) {
      return List.from(_webSavings);
    }
    final db = await instance.database;
    final result = await db!.query('savings', orderBy: 'id DESC');
    return result.map((json) => SavingsModel.fromMap(json)).toList();
  }

  Future<int> updateSavings(SavingsModel savings) async {
    if (kIsWeb) {
      final index = _webSavings.indexWhere((s) => s.id == savings.id);
      if (index != -1) _webSavings[index] = savings;
      return 1;
    }
    final db = await instance.database;
    return await db!.update('savings', savings.toMap(),
        where: 'id = ?', whereArgs: [savings.id]);
  }

  Future<int> deleteSavings(int id) async {
    if (kIsWeb) {
      _webSavings.removeWhere((s) => s.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db!.delete('savings', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertBudget(BudgetModel budget) async {
    if (kIsWeb) {
      _webBudgets.insert(0, budget);
      return 1;
    }
    final db = await instance.database;
    return await db!.insert('budgets', budget.toMap());
  }

  Future<List<BudgetModel>> getAllBudgets() async {
    if (kIsWeb) {
      return List.from(_webBudgets);
    }
    final db = await instance.database;
    final result = await db!.query('budgets', orderBy: 'id DESC');
    return result.map((json) => BudgetModel.fromMap(json)).toList();
  }

  Future<int> updateBudget(BudgetModel budget) async {
    if (kIsWeb) {
      final index = _webBudgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) _webBudgets[index] = budget;
      return 1;
    }
    final db = await instance.database;
    return await db!.update('budgets', budget.toMap(),
        where: 'id = ?', whereArgs: [budget.id]);
  }

  Future<int> deleteBudget(int id) async {
    if (kIsWeb) {
      _webBudgets.removeWhere((b) => b.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db!.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD for Donations ---
  Future<int> insertDonation(DonationModel donation) async {
    if (kIsWeb) {
      final newId = _webDonations.isEmpty
          ? 1
          : (_webDonations.map((e) => e.id!).reduce((a, b) => a > b ? a : b)) +
              1;
      final newDonation = DonationModel(
        id: newId,
        organizationName: donation.organizationName,
        amount: donation.amount,
        totalDonated: donation.totalDonated,
        note: donation.note,
        createdAt: donation.createdAt,
      );
      _webDonations.add(newDonation);
      return newId;
    }
    final db = await instance.database;
    return await db!.insert('donations', donation.toMap());
  }

  Future<List<DonationModel>> getDonations() async {
    if (kIsWeb) return List.from(_webDonations);
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db!.query('donations');
    return List.generate(maps.length, (i) => DonationModel.fromMap(maps[i]));
  }

  Future<int> updateDonation(DonationModel donation) async {
    if (kIsWeb) {
      final index = _webDonations.indexWhere((e) => e.id == donation.id);
      if (index != -1) {
        _webDonations[index] = donation;
        return 1;
      }
      return 0;
    }
    final db = await instance.database;
    return await db!.update(
      'donations',
      donation.toMap(),
      where: 'id = ?',
      whereArgs: [donation.id],
    );
  }

  Future<int> deleteDonation(int id) async {
    if (kIsWeb) {
      _webDonations.removeWhere((e) => e.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db!.delete(
      'donations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Cars ---
  Future<int> insertCar(CarModel car) async {
    if (kIsWeb) {
      final newCar = CarModel(
        id: _webCars.length + 1,
        carName: car.carName,
        licensePlate: car.licensePlate,
        expenses: car.expenses,
        createdAt: car.createdAt,
      );
      _webCars.add(newCar);
      return newCar.id!;
    }
    final db = await instance.database;
    return await db!.insert('cars', car.toMap());
  }

  Future<List<CarModel>> getAllCars() async {
    if (kIsWeb) return List.from(_webCars);
    final db = await instance.database;
    final result = await db!.query('cars');
    return result.map((json) => CarModel.fromMap(json)).toList();
  }

  Future<int> updateCar(CarModel car) async {
    if (kIsWeb) {
      final index = _webCars.indexWhere((c) => c.id == car.id);
      if (index != -1) {
        _webCars[index] = car;
        return 1;
      }
      return 0;
    }
    final db = await instance.database;
    return await db!
        .update('cars', car.toMap(), where: 'id = ?', whereArgs: [car.id]);
  }

  Future<int> deleteCar(int id) async {
    if (kIsWeb) {
      _webCars.removeWhere((c) => c.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db!.delete('cars', where: 'id = ?', whereArgs: [id]);
  }

  // --- Tuitions ---
  Future<int> insertTuition(TuitionModel tuition) async {
    if (kIsWeb) {
      final newTuition = TuitionModel(
        id: _webTuitions.length + 1,
        studentName: tuition.studentName,
        institution: tuition.institution,
        monthlyFee: tuition.monthlyFee,
        dueDate: tuition.dueDate,
        expenses: tuition.expenses,
        createdAt: tuition.createdAt,
      );
      _webTuitions.add(newTuition);
      return newTuition.id!;
    }
    final db = await instance.database;
    return await db!.insert('tuitions', tuition.toMap());
  }

  Future<List<TuitionModel>> getAllTuitions() async {
    if (kIsWeb) return List.from(_webTuitions);
    final db = await instance.database;
    final result = await db!.query('tuitions');
    return result.map((json) => TuitionModel.fromMap(json)).toList();
  }

  Future<int> updateTuition(TuitionModel tuition) async {
    if (kIsWeb) {
      final index = _webTuitions.indexWhere((t) => t.id == tuition.id);
      if (index != -1) {
        _webTuitions[index] = tuition;
        return 1;
      }
      return 0;
    }
    final db = await instance.database;
    return await db!.update('tuitions', tuition.toMap(),
        where: 'id = ?', whereArgs: [tuition.id]);
  }

  Future<int> deleteTuition(int id) async {
    if (kIsWeb) {
      _webTuitions.removeWhere((t) => t.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db!.delete('tuitions', where: 'id = ?', whereArgs: [id]);
  }
}
