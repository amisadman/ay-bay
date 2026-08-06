import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme() {
    final textFont = GoogleFonts.outfitTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.emeraldGreen,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.emeraldGreen,
        secondary: AppColors.leatherBrown,
        tertiary: AppColors.vibrantGold,
        surface: AppColors.lightSurface,
        error: AppColors.expenseRed,
      ),
      textTheme: textFont.apply(
        bodyColor: AppColors.lightTextPrimary,
        displayColor: AppColors.lightTextPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle:
            GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)
                .copyWith(color: AppColors.lightTextPrimary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.emeraldGreen,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.emeraldGreen, width: 2),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final textFont = GoogleFonts.outfitTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.emeraldGreen,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.emeraldGreen,
        secondary: AppColors.leatherBrown,
        tertiary: AppColors.vibrantGold,
        surface: AppColors.darkSurface,
        error: AppColors.expenseRed,
      ),
      textTheme: textFont.apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle:
            GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)
                .copyWith(color: AppColors.darkTextPrimary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.emeraldGreen,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.emeraldGreen, width: 2),
        ),
      ),
    );
  }
}
