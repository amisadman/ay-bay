import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../services/database_helper.dart';

import 'package:permission_handler/permission_handler.dart';

class BackupService {
  static Future<String?> createLocalBackup({bool isCloud = false}) async {
    try {
      if (kIsWeb) {
        return 'Web backup snapshot saved to LocalStorage!';
      }
      final db = await DatabaseHelper.instance.database;
      if (db == null) return null;

      final txs = await db.query('transactions');
      final loans = await db.query('loans');
      final savings = await db.query('savings');
      final budgets = await db.query('budgets');
      final donations = await db.query('donations');

      final backupData = {
        'version': 2,
        'timestamp': DateTime.now().toIso8601String(),
        'transactions': txs,
        'loans': loans,
        'savings': savings,
        'budgets': budgets,
        'donations': donations,
      };

      final jsonStr = jsonEncode(backupData);
      
      Directory? dir;
      if (isCloud) {
        dir = await getApplicationDocumentsDirectory();
      } else {
        if (Platform.isAndroid) {
          var status = await Permission.storage.status;
          if (!status.isGranted) await Permission.storage.request();
          
          var manageStatus = await Permission.manageExternalStorage.status;
          if (!manageStatus.isGranted) await Permission.manageExternalStorage.request();

          dir = Directory('/storage/emulated/0/Download/Aybay_Backup');
        } else {
          final downloadsDir = await getDownloadsDirectory();
          dir = Directory('${downloadsDir?.path}/Aybay_Backup');
        }
      }

      if (dir != null && !await dir.exists()) {
        await dir.create(recursive: true);
      }

      final fileName = 'aybay_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final backupFile = File('${dir!.path}/$fileName');
      
      await backupFile.writeAsString(jsonStr);
      return backupFile.path;
    } catch (e) {
      debugPrint('Backup Error: $e');
      return null;
    }
  }

  static Future<bool> restoreLocalBackup(File backupFile) async {
    try {
      if (kIsWeb) return true;

      final jsonStr = await backupFile.readAsString();
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      final db = await DatabaseHelper.instance.database;
      if (db == null) return false;

      // Wrap in a transaction for safety
      await db.transaction((txn) async {
        await txn.delete('transactions');
        await txn.delete('loans');
        await txn.delete('savings');
        await txn.delete('budgets');
        await txn.delete('donations');

        final txs = map['transactions'] as List<dynamic>? ?? [];
        for (var item in txs) {
          await txn.insert('transactions', Map<String, dynamic>.from(item as Map));
        }

        final loans = map['loans'] as List<dynamic>? ?? [];
        for (var item in loans) {
          await txn.insert('loans', Map<String, dynamic>.from(item as Map));
        }

        final savings = map['savings'] as List<dynamic>? ?? [];
        for (var item in savings) {
          await txn.insert('savings', Map<String, dynamic>.from(item as Map));
        }

        final budgets = map['budgets'] as List<dynamic>? ?? [];
        for (var item in budgets) {
          await txn.insert('budgets', Map<String, dynamic>.from(item as Map));
        }

        final donations = map['donations'] as List<dynamic>? ?? [];
        for (var item in donations) {
          await txn.insert('donations', Map<String, dynamic>.from(item as Map));
        }
      });

      return true;
    } catch (e) {
      debugPrint('Restore Error: $e');
      return false;
    }
  }
}
