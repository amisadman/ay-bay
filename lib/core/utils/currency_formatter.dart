import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String currencySymbol) {
    final formatter = NumberFormat.currency(
      symbol: '$currencySymbol ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatSimple(double amount, String currencySymbol) {
    final formatter = NumberFormat('#,##0.##');
    return '$currencySymbol${formatter.format(amount)}';
  }
}
