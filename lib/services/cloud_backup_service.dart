import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aybay_flutter/services/backup_service.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class CloudBackupMetadata {
  final String date;
  final String size;

  CloudBackupMetadata({required this.date, required this.size});
}

class CloudBackupService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return null;
    }
  }

  static Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  static Future<drive.DriveApi?> _getDriveApi() async {
    final account = _googleSignIn.currentUser ?? await signInSilently();
    if (account == null) return null;

    final authHeaders = await account.authHeaders;
    final client = GoogleAuthClient(authHeaders);
    return drive.DriveApi(client);
  }

  static Future<CloudBackupMetadata?> getBackupMetadata() async {
    final api = await _getDriveApi();
    if (api == null) return null;

    try {
      final fileList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = 'aybay_backup.json'",
        $fields: "files(id, name, modifiedTime, size)",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final file = fileList.files!.first;
        final sizeBytes = int.tryParse(file.size ?? '0') ?? 0;
        final kb = sizeBytes / 1024;
        String sizeStr = kb > 1024
            ? '${(kb / 1024).toStringAsFixed(2)} MB'
            : '${kb.toStringAsFixed(2)} KB';

        // Format date
        String dateStr = 'Unknown';
        if (file.modifiedTime != null) {
          final localTime = file.modifiedTime!.toLocal();
          dateStr =
              "${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')} ${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}";
        }

        return CloudBackupMetadata(date: dateStr, size: sizeStr);
      }
    } catch (e) {
      debugPrint('Error getting metadata: $e');
    }
    return null;
  }

  static Future<bool> uploadBackup(String filePath) async {
    final api = await _getDriveApi();
    if (api == null) return false;

    try {
      final localFile = File(filePath);
      if (!await localFile.exists()) return false;

      // Check if exists
      String? fileId;
      final fileList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = 'aybay_backup.json'",
      );
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        fileId = fileList.files!.first.id;
      }

      final media = drive.Media(localFile.openRead(), localFile.lengthSync());
      final driveFile = drive.File()
        ..name = 'aybay_backup.json'
        ..parents = ['appDataFolder'];

      if (fileId != null) {
        await api.files.update(driveFile, fileId, uploadMedia: media);
      } else {
        await api.files.create(driveFile, uploadMedia: media);
      }
      return true;
    } catch (e) {
      debugPrint('Error uploading backup: $e');
      return false;
    }
  }

  static Future<File?> downloadBackup() async {
    final api = await _getDriveApi();
    if (api == null) return null;

    try {
      final fileList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = 'aybay_backup.json'",
      );

      if (fileList.files == null || fileList.files!.isEmpty) return null;

      final fileId = fileList.files!.first.id!;
      final drive.Media media = await api.files.get(fileId,
          downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

      final dir = Directory.systemTemp;
      final localFile = File('${dir.path}/aybay_cloud_backup.json');

      final sink = localFile.openWrite();
      await media.stream.pipe(sink);
      await sink.close();

      return localFile;
    } catch (e) {
      debugPrint('Error downloading backup: $e');
      return null;
    }
  }

  static Future<void> autoBackupCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedule = prefs.getString('backup_schedule') ?? 'Never';
      if (schedule == 'Never') return;

      final lastBackupStr = prefs.getString('last_auto_backup_date');
      final now = DateTime.now();

      bool shouldBackup = false;
      if (lastBackupStr == null) {
        shouldBackup = true;
      } else {
        final lastBackup = DateTime.tryParse(lastBackupStr);
        if (lastBackup != null) {
          final diff = now.difference(lastBackup).inDays;
          if (schedule == 'Daily' && diff >= 1) shouldBackup = true;
          if (schedule == 'Weekly' && diff >= 7) shouldBackup = true;
          if (schedule == 'Monthly' && diff >= 30) shouldBackup = true;
        } else {
          shouldBackup = true;
        }
      }

      if (shouldBackup) {
        final account = await signInSilently();
        if (account == null) return;

        final localPath = await BackupService.createLocalBackup(isCloud: true);
        if (localPath != null) {
          final success = await uploadBackup(localPath);
          if (success) {
            await prefs.setString(
                'last_auto_backup_date', now.toIso8601String());
          }
        }
      }
    } catch (e) {
      debugPrint('Auto backup failed: $e');
    }
  }
}
