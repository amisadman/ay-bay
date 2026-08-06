import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/auth_provider.dart';
import 'package:aybay_flutter/views/navigation/main_navigation_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  String? _errorMsg;

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _completeSetup() {
    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMsg = 'Please enter your name';
      });
      return;
    }
    if (pin.length < 4) {
      setState(() {
        _errorMsg = 'PIN must be at least 4 digits';
      });
      return;
    }

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    authProv.completeSetup(name, pin).then((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100),
              Center(
                child: Image.asset('assets/images/aybay-logo.png', height: 120),
              ),
              const Text(
                'Welcome to AyBay',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Let\'s set up your profile to get started',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.brown,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.brown.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        prefixIcon:
                            const Icon(Icons.person, color: AppColors.brown),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: InputDecoration(
                        labelText: 'Create 4-digit PIN',
                        prefixIcon:
                            const Icon(Icons.lock, color: AppColors.brown),
                        errorText: _errorMsg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.grey),
                        ),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                      onPressed: _completeSetup,
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
