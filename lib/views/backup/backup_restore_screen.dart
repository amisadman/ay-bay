import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/services/backup_service.dart';
import 'package:aybay_flutter/services/cloud_backup_service.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isLoading = false;
  GoogleSignInAccount? _currentUser;
  CloudBackupMetadata? _metadata;
  String _schedule = 'Never'; // 'Daily', 'Weekly', 'Monthly', 'Never'

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _schedule = prefs.getString('backup_schedule') ?? 'Never';
    
    final account = await CloudBackupService.signInSilently();
    setState(() => _currentUser = account);
    
    if (account != null) {
      await _fetchMetadata();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchMetadata() async {
    final meta = await CloudBackupService.getBackupMetadata();
    if (mounted) {
      setState(() => _metadata = meta);
    }
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
              Lottie.asset('assets/animations/success.json', width: 200, height: 200, repeat: false),
            ],
          ),
        );
      }
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
      }
    });
  }

  void _showRestoreAnimation() {
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
              Lottie.asset('assets/animations/restore.json', width: 200, height: 200, repeat: false),
            ],
          ),
        );
      }
    );

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.pop(dialogContext!);
      }
    });
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final account = await CloudBackupService.signIn();
    setState(() {
      _currentUser = account;
    });
    if (account != null) {
      await _fetchMetadata();
    }
    setState(() => _isLoading = false);
  }
  
  void _handleGoogleSignOut() async {
    setState(() => _isLoading = true);
    await CloudBackupService.signOut();
    setState(() {
      _currentUser = null;
      _metadata = null;
      _isLoading = false;
    });
  }

  void _doCloudBackup() async {
    setState(() => _isLoading = true);
    
    // First create local backup (for cloud upload, don't require external storage permission)
    final localPath = await BackupService.createLocalBackup(isCloud: true);
    if (localPath != null) {
      final success = await CloudBackupService.uploadBackup(localPath);
      if (success) {
        await _fetchMetadata();
        if (mounted) _showSuccessAnimation();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cloud backup failed.')));
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create snapshot for cloud.')));
    }
    
    setState(() => _isLoading = false);
  }
  
  void _doCloudRestore() async {
    setState(() => _isLoading = true);
    
    final file = await CloudBackupService.downloadBackup();
    if (file != null) {
      final success = await BackupService.restoreLocalBackup(file);
      if (success) {
        if (mounted) _showRestoreAnimation();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore failed.')));
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No cloud backup found.')));
    }
    
    setState(() => _isLoading = false);
  }

  void _doLocalBackup() async {
    setState(() => _isLoading = true);
    final path = await BackupService.createLocalBackup();
    setState(() => _isLoading = false);

    if (path != null && mounted) {
      _showSuccessAnimation();
    }
  }

  void _doLocalRestore() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    
    if (result != null && result.files.single.path != null) {
      setState(() => _isLoading = true);
      final file = File(result.files.single.path!);
      final success = await BackupService.restoreLocalBackup(file);
      setState(() => _isLoading = false);
      if (success && mounted) {
        _showRestoreAnimation();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore failed.')));
      }
    }
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Back up to Google Drive'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Never', 'Daily', 'Weekly', 'Monthly'].map((opt) => 
            RadioListTile<String>(
              title: Text(opt),
              value: opt,
              groupValue: _schedule,
              onChanged: (val) async {
                if (val != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('backup_schedule', val);
                  setState(() => _schedule = val);
                  Navigator.pop(ctx);
                }
              },
            )
          ).toList(),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Backup & Restore', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 20, top: 12),
                child: Center(
                  child: Lottie.asset('assets/animations/restore.json', width: 140, height: 140),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                const SizedBox(height: 16),
                const Text('Last backup', style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text(
                  'Back up your data and settings to Google Drive. You can restore them when you reinstall Aybay.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.cloud_done, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Google Drive', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(_metadata?.date ?? 'Never', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 32),
                    Text('Size: ${_metadata?.size ?? 'Unknown'}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: _currentUser != null ? _doCloudBackup : null,
                        child: const Text('Back up', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: _currentUser != null ? _doCloudRestore : null,
                        child: const Text('Restore', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                
                const Text('Google Drive settings', style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Back up to Google Drive'),
                  subtitle: Text(_schedule),
                  onTap: _showScheduleDialog,
                ),
                
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Google Account'),
                  subtitle: Text(_currentUser?.email ?? 'Not selected'),
                  onTap: _currentUser == null ? _handleGoogleSignIn : _handleGoogleSignOut,
                  trailing: _currentUser != null ? IconButton(icon: const Icon(Icons.logout, color: Colors.red), onPressed: _handleGoogleSignOut) : null,
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                const Text('Local Backup', style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.sd_storage, color: AppColors.black),
                  title: const Text('Create Local Backup'),
                  subtitle: const Text('Save to Downloads folder'),
                  onTap: _doLocalBackup,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.restore, color: AppColors.black),
                  title: const Text('Restore Local Backup'),
                  subtitle: const Text('Select a .json backup file'),
                  onTap: _doLocalRestore,
                ),
                
              ],
            ),
          ),
        ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.green))),
            ),
        ],
      ),
    );
  }
}
