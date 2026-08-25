import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/auth_provider.dart';
import 'package:aybay_flutter/views/navigation/main_navigation_screen.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pwdController = TextEditingController();
  final _pwdFocusNode = FocusNode();
  bool _isPasswordFocused = false;
  bool _obscurePin = true;
  final FlareControls _teddyControls = FlareControls();
  final LocalAuthentication _localAuth = LocalAuthentication();
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _pwdFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _pwdFocusNode.hasFocus;
        if (_isPasswordFocused) {
          _teddyControls.play(_obscurePin ? 'hands_up' : 'hands_down');
        } else {
          _teddyControls.play('hands_down');
        }
      });
    });
  }

  @override
  void dispose() {
    _pwdFocusNode.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  void _doLogin() {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    if (authProv.verifyPin(_pwdController.text)) {
      _teddyControls.play('success');
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      });
    } else {
      setState(() {
        _errorMsg = 'Incorrect PIN! Default is 1234';
      });
      _teddyControls.play('fail');
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        if (_isPasswordFocused) {
          _teddyControls.play(_obscurePin ? 'hands_up' : 'hands_down');
        }
      });
    }
  }

  Future<void> _doBiometricLogin() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to log in',
        options: const AuthenticationOptions(
            useErrorDialogs: true, stickyAuth: true),
      );
      if (didAuthenticate) {
        if (!mounted) return;
        _teddyControls.play('success');
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        });
      }
    } catch (e) {
      debugPrint('Biometric auth error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              SizedBox(
                height: 220,
                child: GestureDetector(
                  onTap: () {
                    // Tap teddy to make him shy/fail
                    _teddyControls.play('fail');
                    Future.delayed(const Duration(seconds: 1), () {
                      if (!mounted) return;
                      if (_isPasswordFocused) {
                        _teddyControls
                            .play(_obscurePin ? 'hands_up' : 'hands_down');
                      }
                    });
                  },
                  child: FlareActor(
                    'assets/animations/Teddy.flr',
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    controller: _teddyControls,
                    animation: 'idle',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _pwdController,
                      focusNode: _pwdFocusNode,
                      obscureText: _obscurePin,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter 4-digit PIN',
                        prefixIcon:
                            const Icon(Icons.lock, color: AppColors.brown),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePin
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.brown,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePin = !_obscurePin;
                              if (_isPasswordFocused) {
                                _teddyControls.play(
                                    _obscurePin ? 'hands_up' : 'hands_down');
                              }
                            });
                          },
                        ),
                        errorText: _errorMsg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                      onPressed: _doLogin,
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, authProv, child) {
                        if (authProv.isBiometricEnabled) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: IconButton(
                              icon: const Icon(Icons.fingerprint,
                                  size: 48, color: AppColors.green),
                              onPressed: _doBiometricLogin,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/aybay-logo.png',
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
