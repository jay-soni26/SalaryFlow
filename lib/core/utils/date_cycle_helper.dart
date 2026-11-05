import 'package:intl/intl.dart';

class DateCycleHelper {
  /// Returns the number of days in a given month of a given year, properly handling leap years.
  static int getDaysInMonth(int year, int month) {
    if (month == 2) {
      final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const daysInMonths = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonths[month];
  }

  /// Clamps a preferred day (e.g. 31st) to the maximum valid day of that specific month
  /// without modifying the user's underlying preferred setting.
  static int clampDayToMonth(int year, int month, int preferredDay) {
    final maxDays = getDaysInMonth(year, month);
    if (preferredDay > maxDays) {
      return maxDays;
    }
    if (preferredDay < 1) {
      return 1;
    }
    return preferredDay;
  }

  /// Calculates the salary credit date for a given year and month given the preferred day.
  static DateTime getSalaryCreditDate(int year, int month, int preferredDay) {
    final clampedDay = clampDayToMonth(year, month, preferredDay);
    return DateTime(year, month, clampedDay);
  }

  /// Calculates the default salary period:
  /// Starts on the salary credit date of [month],
  /// and ends on the day before the next salary credit date (month + 1).
  static ({DateTime startDate, DateTime endDate}) getDefaultPeriodDates({
    required int year,
    required int month,
    required int preferredSalaryDay,
  }) {
    final start = getSalaryCreditDate(year, month, preferredSalaryDay);

    int nextMonth = month + 1;
    int nextYear = year;
    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear += 1;
    }

    final nextCreditDate = getSalaryCreditDate(nextYear, nextMonth, preferredSalaryDay);
    final end = nextCreditDate.subtract(const Duration(days: 1));

    return (
      startDate: DateTime(start.year, start.month, start.day, 0, 0, 0),
      endDate: DateTime(end.year, end.month, end.day, 23, 59, 59),
    );
  }

  /// Formats a date range cleanly: e.g. "25 Oct 2026 - 24 Nov 2026"
  static String formatPeriodRange(DateTime start, DateTime end) {
    final f = DateFormat('dd MMM yyyy');
    return '${f.format(start)} - ${f.format(end)}';
  }

  /// Formats month & year header: e.g. "November 2026"
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Formats short date: e.g. "05 Nov 2026"
  static String formatShortDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Formats day & month: e.g. "05 Nov"
  static String formatDayMonth(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  /// Formats day of week: e.g. "Thu"
  static String formatWeekday(DateTime date) {
    return DateFormat('E').format(date);
  }
}

