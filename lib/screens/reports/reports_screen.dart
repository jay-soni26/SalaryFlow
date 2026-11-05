import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/currency_format.dart';
import '../../core/utils/date_cycle_helper.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/salary_cycle_provider.dart';
import 'widgets/spending_chart.dart';
import 'widgets/category_breakdown_widget.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodTransactions = ref.watch(periodTransactionsProvider);
    final summary = ref.watch(periodFinancialSummaryProvider);
    final activePeriodAsync = ref.watch(activeSalaryPeriodProvider);
    final selectedMonth = ref.watch(selectedCycleMonthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Projected Month End Balance = Available Spending Balance remaining
    final projectedMonthEndBalance = summary.availableSpendingBalance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports & Insights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector & Exact Period Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateCycleHelper.formatMonthYear(
                          DateTime(selectedMonth.year, selectedMonth.month),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      activePeriodAsync.when(
                        data: (p) => Text(
                          'Cycle: ${DateCycleHelper.formatPeriodRange(p.startDate, p.endDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        loading: () => const Text('Loading...', style: TextStyle(fontSize: 12)),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          ref.read(selectedCycleMonthProvider.notifier).state =
                              selectedMonth.previous();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          ref.read(selectedCycleMonthProvider.notifier).state =
                              selectedMonth.next();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Cashflow Overview: Income vs Expense vs Deductions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cycle Cashflow Summary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem('Net Inflow', summary.totalIncome, AppColors.income),
                      _buildSummaryItem('Total Spent', summary.totalExpenses, AppColors.expense),
                      _buildSummaryItem('Deductions', summary.totalDeductions, AppColors.deduction),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Projected Cycle-End Surplus:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        CurrencyFormat.format(projectedMonthEndBalance),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: projectedMonthEndBalance >= 0 ? AppColors.income : AppColors.expense,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Spending Distribution Bar Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: SpendingBarChart(transactions: periodTransactions),
            ),

            const SizedBox(height: 20),

            // Category-wise Breakdown
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: CategoryBreakdownWidget(transactions: periodTransactions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormat.format(amount, showDecimals: false),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

