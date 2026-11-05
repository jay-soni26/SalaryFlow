import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';
import '../models/salary_config.dart';
import '../models/salary_period.dart';

// Represents current selected cycle month & year
class SelectedCycleMonth {
  final int year;
  final int month;

  const SelectedCycleMonth(this.year, this.month);

  SelectedCycleMonth next() {
    if (month == 12) return SelectedCycleMonth(year + 1, 1);
    return SelectedCycleMonth(year, month + 1);
  }

  SelectedCycleMonth previous() {
    if (month == 1) return SelectedCycleMonth(year - 1, 12);
    return SelectedCycleMonth(year, month - 1);
  }

  String get id => '$year-${month.toString().padLeft(2, '0')}';
}

final selectedCycleMonthProvider = StateProvider<SelectedCycleMonth>((ref) {
  final now = DateTime.now();
  return SelectedCycleMonth(now.year, now.month);
});

// Provides global SalaryConfig
final salaryConfigProvider = FutureProvider<SalaryConfig>((ref) async {
  return await AppDatabase.instance.getSalaryConfig();
});

// Provides the active SalaryPeriod for the selected month
final activeSalaryPeriodProvider =
    StateNotifierProvider<ActiveSalaryPeriodNotifier, AsyncValue<SalaryPeriod>>((ref) {
  final selectedMonth = ref.watch(selectedCycleMonthProvider);
  return ActiveSalaryPeriodNotifier(selectedMonth);
});

class ActiveSalaryPeriodNotifier extends StateNotifier<AsyncValue<SalaryPeriod>> {
  final SelectedCycleMonth selectedMonth;

  ActiveSalaryPeriodNotifier(this.selectedMonth) : super(const AsyncValue.loading()) {
    loadPeriod();
  }

  Future<void> loadPeriod() async {
    try {
      final period = await AppDatabase.instance
          .getOrCreateSalaryPeriod(selectedMonth.year, selectedMonth.month);
      state = AsyncValue.data(period);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> creditSalaryForMonth({
    required double amount,
    required String accountId,
    required DateTime creditDate,
    String? notes,
  }) async {
    await AppDatabase.instance.creditSalaryForPeriod(
      year: selectedMonth.year,
      month: selectedMonth.month,
      netSalary: amount,
      accountId: accountId,
      creditDate: creditDate,
      notes: notes,
    );
    await loadPeriod();
  }

  Future<void> updatePeriodDetails({
    required DateTime creditDate,
    required DateTime startDate,
    required DateTime endDate,
    required double grossSalary,
    required double deductions,
    required double netSalary,
    double? carryForwardBalance,
    String? salaryAccountId,
    String? notes,
  }) async {
    if (state.value == null) return;
    final updated = state.value!.copyWith(
      creditDate: creditDate,
      startDate: startDate,
      endDate: endDate,
      grossSalary: grossSalary,
      deductions: deductions,
      netSalary: netSalary,
      carryForwardBalance: carryForwardBalance ?? state.value!.carryForwardBalance,
      salaryAccountId: salaryAccountId ?? state.value!.salaryAccountId,
      isCustomized: true,
      notes: notes ?? state.value!.notes,
    );

    await AppDatabase.instance.updateSalaryPeriod(updated);
    state = AsyncValue.data(updated);
  }
}

