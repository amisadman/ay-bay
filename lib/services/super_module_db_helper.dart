import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/subscription_model.dart';

class SuperModuleDBHelper {
  static final SuperModuleDBHelper instance = SuperModuleDBHelper._init();
  static Database? _database;

  // Web in-memory storage fallbacks
  final List<SubscriptionModel> _webSubscriptions = [];

  SuperModuleDBHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('aybay_super_modules.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subscriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cost REAL NOT NULL,
        billingCycle TEXT NOT NULL,
        nextDueDate TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // --- Subscriptions ---
  Future<int> insertSubscription(SubscriptionModel sub) async {
    if (kIsWeb) {
      final newSub = sub.copyWith(id: _webSubscriptions.length + 1);
      _webSubscriptions.add(newSub);
      return newSub.id!;
    }
    final db = await instance.database;
    return await db!.insert('subscriptions', sub.toMap());
  }

  Future<List<SubscriptionModel>> getAllSubscriptions() async {
    if (kIsWeb) return List.from(_webSubscriptions);
    final db = await instance.database;
    final result = await db!.query('subscriptions');
    return result.map((json) => SubscriptionModel.fromMap(json)).toList();
  }

  Future<int> updateSubscription(SubscriptionModel sub) async {
    if (kIsWeb) {
      final index = _webSubscriptions.indexWhere((s) => s.id == sub.id);
      if (index != -1) {
        _webSubscriptions[index] = sub;
        return 1;
      }
      return 0;
    }
    final db = await instance.database;
    return await db!.update(
      'subscriptions',
      sub.toMap(),
      where: 'id = ?',
      whereArgs: [sub.id],
    );
  }

  Future<int> deleteSubscription(int id) async {
    if (kIsWeb) {
      _webSubscriptions.removeWhere((s) => s.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db!.delete('subscriptions', where: 'id = ?', whereArgs: [id]);
  }
}
