import 'package:intl/intl.dart';

class DateFormatter {
  static String formatShort(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatFull(DateTime date) {
    return DateFormat('EEEE, MMMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatYear(DateTime date) {
    return DateFormat('yyyy').format(date);
  }
}
