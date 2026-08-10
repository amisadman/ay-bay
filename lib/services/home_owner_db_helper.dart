import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/apartment_model.dart';

class HomeOwnerDBHelper {
  static final HomeOwnerDBHelper instance = HomeOwnerDBHelper._init();
  static Database? _database;
  final List<ApartmentModel> _webApartments = [];

  HomeOwnerDBHelper._init() {
    if (kIsWeb) {
      _webApartments.add(
        ApartmentModel(
          id: 1,
          name: 'Demo Appt 1A',
          boarderName: 'John Doe',
          boarderPhone: '01711223344',
          rentAmount: 12000,
          paidMonths: [],
          createdAt: DateTime.now().toIso8601String(),
        )
      );
    }
  }

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('aybay_home_owner.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE apartments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            boarderName TEXT NOT NULL,
            boarderPhone TEXT NOT NULL,
            rentAmount REAL NOT NULL,
            paidMonths TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<ApartmentModel>> getAllApartments() async {
    if (kIsWeb) return List.from(_webApartments);
    final db = await instance.database;
    final result = await db!.query('apartments');
    return result.map((json) => ApartmentModel.fromMap(json)).toList();
  }

  Future<ApartmentModel> insertApartment(ApartmentModel apartment) async {
    if (kIsWeb) {
      final newAppt = apartment.copyWith(id: _webApartments.length + 1);
      _webApartments.add(newAppt);
      return newAppt;
    }
    final db = await instance.database;
    final id = await db!.insert('apartments', apartment.toMap());
    return apartment.copyWith(id: id);
  }

  Future<int> updateApartment(ApartmentModel apartment) async {
    if (kIsWeb) {
      final index = _webApartments.indexWhere((a) => a.id == apartment.id);
      if (index != -1) {
        _webApartments[index] = apartment;
        return 1;
      }
      return 0;
    }
    final db = await instance.database;
    return await db!.update(
      'apartments',
      apartment.toMap(),
      where: 'id = ?',
      whereArgs: [apartment.id],
    );
  }

  Future<int> deleteApartment(int id) async {
    if (kIsWeb) {
      _webApartments.removeWhere((a) => a.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db!.delete(
      'apartments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
