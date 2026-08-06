import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _currencySymbol = '৳'; // Default Bengali Taka ৳ or $
  int _cardThemeIndex = 0;

  bool get isDarkMode => _isDarkMode;
  String get currencySymbol => _currencySymbol;
  int get cardThemeIndex => _cardThemeIndex;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    _currencySymbol = prefs.getString('currency_symbol') ?? '৳';
    _cardThemeIndex = prefs.getInt('card_theme_index') ?? 0;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
    notifyListeners();
  }

  Future<void> setCardTheme(int index) async {
    _cardThemeIndex = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('card_theme_index', index);
    notifyListeners();
  }

  Future<void> setCurrency(String symbol) async {
    _currencySymbol = symbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_symbol', symbol);
    notifyListeners();
  }
}
