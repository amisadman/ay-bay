import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';

class UpdateService {
  static Future<void> checkForUpdate(BuildContext context, {bool manualCheck = false}) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final doc = await FirebaseFirestore.instance.collection('app_config').doc('update_info').get();
      
      if (!doc.exists) {
        if (manualCheck && context.mounted) {
          _showNoUpdateDialog(context);
        }
        return;
      }

      final data = doc.data()!;
      final latestVersion = data['latest_version'] as String? ?? '1.0.0';
      final downloadUrl = data['download_url'] as String? ?? '';
      final rawNotes = data['release_notes'] as String? ?? 'Bug fixes and performance improvements.';
      final releaseNotes = rawNotes.replaceAll('\\n', '\n');
      final isForceUpdate = data['force_update'] as bool? ?? false;

      if (_isUpdateAvailable(currentVersion, latestVersion)) {
        if (context.mounted) {
          _showUpdateDialog(context, latestVersion, downloadUrl, releaseNotes, isForceUpdate);
        }
      } else {
        if (manualCheck && context.mounted) {
          _showNoUpdateDialog(context);
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      if (manualCheck && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to check for updates. Please check your internet connection.')),
        );
      }
    }
  }

  static bool _isUpdateAvailable(String current, String latest) {
    List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < latestParts.length; i++) {
      int c = i < currentParts.length ? currentParts[i] : 0;
      int l = latestParts[i];
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  static void _showNoUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Up to date', style: TextStyle(color: AppColors.green)),
        content: const Text('You are already on the latest version of AyBay.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppColors.brown)),
          ),
        ],
      ),
    );
  }

  static void _showUpdateDialog(BuildContext context, String newVersion, String url, String notes, bool isForceUpdate) {
    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate, // Prevent dismissing if forced
      builder: (ctx) => WillPopScope(
        onWillPop: () async => !isForceUpdate,
        child: AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.system_update, color: AppColors.green),
              const SizedBox(width: 8),
              Expanded(child: Text('New Update Available ($newVersion)')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What\'s new:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(notes, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          actions: [
            if (!isForceUpdate)
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Download & Update'),
            ),
          ],
        ),
      ),
    );
  }
}
