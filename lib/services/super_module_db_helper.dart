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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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
    
    await db.execute('''
      CREATE TABLE room_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        moduleType TEXT NOT NULL,
        roomCode TEXT NOT NULL,
        roomName TEXT NOT NULL,
        joinedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE room_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          moduleType TEXT NOT NULL,
          roomCode TEXT NOT NULL,
          roomName TEXT NOT NULL,
          joinedAt TEXT NOT NULL
        )
      ''');
    }
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

  // --- Room History ---
  Future<int> insertRoomHistory(String moduleType, String roomCode, String roomName) async {
    if (kIsWeb) return 0; // Not supported on web currently
    final db = await instance.database;
    
    // Check if it already exists to avoid duplicates
    final existing = await db!.query('room_history', 
      where: 'moduleType = ? AND roomCode = ?', 
      whereArgs: [moduleType, roomCode]
    );
    
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }

    return await db.insert('room_history', {
      'moduleType': moduleType,
      'roomCode': roomCode,
      'roomName': roomName,
      'joinedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getRoomHistory(String moduleType) async {
    if (kIsWeb) return [];
    final db = await instance.database;
    return await db!.query('room_history', 
      where: 'moduleType = ?', 
      whereArgs: [moduleType],
      orderBy: 'joinedAt DESC'
    );
  }

  Future<int> deleteRoomHistory(String moduleType, String roomCode) async {
    if (kIsWeb) return 0;
    final db = await instance.database;
    return await db!.delete('room_history', 
      where: 'moduleType = ? AND roomCode = ?', 
      whereArgs: [moduleType, roomCode]
    );
  }
}
