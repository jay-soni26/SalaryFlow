import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/currency_format.dart';
import '../../../core/utils/date_cycle_helper.dart';
import '../../../providers/salary_cycle_provider.dart';
import '../../../providers/accounts_provider.dart';
import 'credit_salary_dialog.dart';

class MonthSalaryCard extends ConsumerWidget {
  const MonthSalaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePeriodAsync = ref.watch(activeSalaryPeriodProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final selectedMonth = ref.watch(selectedCycleMonthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final monthName = DateCycleHelper.formatMonthYear(
      DateTime(selectedMonth.year, selectedMonth.month),
    );

    return activePeriodAsync.when(
      data: (period) {
        final hasSalary = period.netSalary > 0;
        final accountName = accountsAsync.when(
          data: (accs) {
            final acc = accs.firstWhere(
              (a) => a.id == period.salaryAccountId,
              orElse: () => accs.firstWhere((a) => a.isSalaryDefault, orElse: () => accs.first),
            );
            return acc.name;
          },
          loading: () => 'Bank Account',
          error: (_, __) => 'Bank Account',
        );

        if (hasSalary) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.income.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_circle, color: AppColors.income, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Take-Home Salary Credited',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormat.format(period.netSalary),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.income,
                        ),
                      ),
                      Text(
                        '${DateCycleHelper.formatShortDate(period.creditDate)} • $accountName',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => CreditSalaryDialog(period: period),
                    );
                  },
                  child: const Text('Edit'),
                ),
              ],
            ),
          );
        }

        // Empty state for this month: No salary recorded yet
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Salary for $monthName',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Credit in-hand salary to your bank',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CreditSalaryDialog(period: period),
                  );
                },
                child: const Text('+ Credit Salary'),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
