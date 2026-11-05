import 'package:flutter_test/flutter_test.dart';
import 'package:salaryflow/core/utils/date_cycle_helper.dart';

void main() {
  group('Salary Cycle Calculation Tests', () {
    test('Calculates standard period starting on 1st of month', () {
      final period = DateCycleHelper.getDefaultPeriodDates(
        year: 2026,
        month: 11, // November 2026
        preferredSalaryDay: 1,
      );

      expect(period.startDate.year, equals(2026));
      expect(period.startDate.month, equals(11));
      expect(period.startDate.day, equals(1));

      // Ends day before 1st of December 2026 -> 30th November 2026
      expect(period.endDate.year, equals(2026));
      expect(period.endDate.month, equals(11));
      expect(period.endDate.day, equals(30));
    });

    test('Calculates mid-month salary cycle (e.g. 25th to 24th of next month)', () {
      final period = DateCycleHelper.getDefaultPeriodDates(
        year: 2026,
        month: 10, // October 2026
        preferredSalaryDay: 25,
      );

      // Starts 25 October 2026
      expect(period.startDate.day, equals(25));
      expect(period.startDate.month, equals(10));
      expect(period.startDate.year, equals(2026));

      // Ends 24 November 2026
      expect(period.endDate.day, equals(24));
      expect(period.endDate.month, equals(11));
      expect(period.endDate.year, equals(2026));
    });

    test('Calculates year-end transition salary cycle (December to January)', () {
      final period = DateCycleHelper.getDefaultPeriodDates(
        year: 2026,
        month: 12, // December 2026
        preferredSalaryDay: 25,
      );

      // Starts 25 Dec 2026
      expect(period.startDate.year, equals(2026));
      expect(period.startDate.month, equals(12));
      expect(period.startDate.day, equals(25));

      // Ends 24 Jan 2027
      expect(period.endDate.year, equals(2027));
      expect(period.endDate.month, equals(1));
      expect(period.endDate.day, equals(24));
    });
  });
}

