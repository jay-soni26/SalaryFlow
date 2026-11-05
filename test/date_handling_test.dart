import 'package:flutter_test/flutter_test.dart';
import 'package:salaryflow/core/utils/date_cycle_helper.dart';

void main() {
  group('DateCycleHelper - Date Handling & Clamping Tests', () {
    test('Correctly identifies days in regular months and leap years', () {
      // Leap year 2024
      expect(DateCycleHelper.getDaysInMonth(2024, 2), equals(29));
      // Non-leap years 2025, 2026
      expect(DateCycleHelper.getDaysInMonth(2025, 2), equals(28));
      expect(DateCycleHelper.getDaysInMonth(2026, 2), equals(28));

      // 30-day months
      expect(DateCycleHelper.getDaysInMonth(2026, 4), equals(30)); // April
      expect(DateCycleHelper.getDaysInMonth(2026, 6), equals(30)); // June
      expect(DateCycleHelper.getDaysInMonth(2026, 9), equals(30)); // September
      expect(DateCycleHelper.getDaysInMonth(2026, 11), equals(30)); // November

      // 31-day months
      expect(DateCycleHelper.getDaysInMonth(2026, 1), equals(31)); // Jan
      expect(DateCycleHelper.getDaysInMonth(2026, 3), equals(31)); // March
      expect(DateCycleHelper.getDaysInMonth(2026, 5), equals(31)); // May
      expect(DateCycleHelper.getDaysInMonth(2026, 7), equals(31)); // July
      expect(DateCycleHelper.getDaysInMonth(2026, 8), equals(31)); // Aug
      expect(DateCycleHelper.getDaysInMonth(2026, 10), equals(31)); // Oct
      expect(DateCycleHelper.getDaysInMonth(2026, 12), equals(31)); // Dec
    });

    test('Safely clamps 31st salary date in shorter months without mutating preferred setting', () {
      const preferredDay = 31;

      // February non-leap (28 days max)
      final febDay = DateCycleHelper.clampDayToMonth(2026, 2, preferredDay);
      expect(febDay, equals(28));

      // February leap year (29 days max)
      final febLeapDay = DateCycleHelper.clampDayToMonth(2024, 2, preferredDay);
      expect(febLeapDay, equals(29));

      // April (30 days max)
      final aprDay = DateCycleHelper.clampDayToMonth(2026, 4, preferredDay);
      expect(aprDay, equals(30));

      // July (31 days max)
      final julDay = DateCycleHelper.clampDayToMonth(2026, 7, preferredDay);
      expect(julDay, equals(31));
    });
  });
}

