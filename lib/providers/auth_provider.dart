import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthProvider extends ChangeNotifier {
  bool _isPinEnabled = true;
  bool _isBiometricEnabled = false;
  bool _hasSetup = false;
  bool _isHomeOwnerMode = false;
  bool _isShopOwnerMode = false;
  bool _isSubscriptionMode = false;
  bool _isGymOwnerMode = false;
  bool _isGarageOwnerMode = false;
  bool _isCarOwnerMode = false;
  bool _isTuitionMode = false;
  String _currentPin = '1234';
  String _userName = 'AyBay User';
  String? _profileImagePath;

  bool get isPinEnabled => _isPinEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get hasSetup => _hasSetup;
  bool get isHomeOwnerMode => _isHomeOwnerMode;
  bool get isShopOwnerMode => _isShopOwnerMode;
  bool get isSubscriptionMode => _isSubscriptionMode;
  bool get isGymOwnerMode => _isGymOwnerMode;
  bool get isGarageOwnerMode => _isGarageOwnerMode;
  bool get isCarOwnerMode => _isCarOwnerMode;
  bool get isTuitionMode => _isTuitionMode;
  String get currentPin => _currentPin;
  String get userName => _userName;
  String? get profileImagePath => _profileImagePath;

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  AuthProvider();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPinEnabled = prefs.getBool('is_pin_enabled') ?? true;
    _isBiometricEnabled = prefs.getBool('is_biometric_enabled') ?? false;
    _hasSetup = prefs.getBool('has_setup') ?? false;
    _isHomeOwnerMode = prefs.getBool('is_home_owner_mode') ?? false;
    _isShopOwnerMode = prefs.getBool('is_shop_owner_mode') ?? false;
    _isSubscriptionMode = prefs.getBool('is_subscription_mode') ?? false;
    _isGymOwnerMode = prefs.getBool('is_gym_owner_mode') ?? false;
    _isGarageOwnerMode = prefs.getBool('is_garage_owner_mode') ?? false;
    _isCarOwnerMode = prefs.getBool('is_car_owner_mode') ?? false;
    _isTuitionMode = prefs.getBool('is_tuition_mode') ?? false;
    _currentPin = prefs.getString('user_pin') ?? '1234';
    _userName = prefs.getString('user_name') ?? 'AyBay User';
    _profileImagePath = prefs.getString('profile_image_path');
    notifyListeners();
  }

  Future<void> togglePinEnabled(bool enabled) async {
    _isPinEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_pin_enabled', enabled);
    notifyListeners();
  }

  Future<void> toggleBiometrics(bool enabled) async {
    _isBiometricEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_biometric_enabled', enabled);
    notifyListeners();
  }

  Future<void> toggleHomeOwnerMode(bool enabled) async {
    _isHomeOwnerMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_home_owner_mode', enabled);
    notifyListeners();
  }

  Future<void> toggleShopOwnerMode(bool enabled) async {
    _isShopOwnerMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_shop_owner_mode', enabled);
    notifyListeners();
  }

  Future<void> toggleSubscriptionMode(bool enabled) async {
    _isSubscriptionMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_subscription_mode', enabled);
    notifyListeners();
  }

  Future<void> toggleGymOwnerMode(bool enabled) async {
    _isGymOwnerMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_gym_owner_mode', enabled);
    notifyListeners();
  }

  Future<void> toggleGarageOwnerMode(bool enabled) async {
    _isGarageOwnerMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_garage_owner_mode', enabled);
    notifyListeners();
  }

  Future<void> toggleCarOwnerMode(bool enabled) async {
    _isCarOwnerMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_car_owner_mode', enabled);
    notifyListeners();
  }

  Future<void> toggleTuitionMode(bool enabled) async {
    _isTuitionMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_tuition_mode', enabled);
    notifyListeners();
  }

  Future<void> changeUserName(String newName) async {
    if (newName.trim().isEmpty) return;
    _userName = newName.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
    notifyListeners();
  }

  Future<void> completeSetup(String name, String pin) async {
    if (name.trim().isEmpty || pin.trim().length < 4) return;
    _userName = name.trim();
    _currentPin = _hashPin(pin.trim());
    _hasSetup = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
    await prefs.setString(
        'user_pin', _currentPin); // _currentPin is already hashed
    await prefs.setBool('has_setup', true);
    notifyListeners();
  }

  Future<void> setProfileImage(String path) async {
    _profileImagePath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
    notifyListeners();
  }

  Future<bool> changePin(String newPin) async {
    if (newPin.trim().length < 4) return false;
    _currentPin = _hashPin(newPin.trim());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', _currentPin);
    notifyListeners();
    return true;
  }

  bool verifyPin(String enteredPin) {
    if (!_isPinEnabled) return true;
    return _currentPin == _hashPin(enteredPin.trim());
  }
}
