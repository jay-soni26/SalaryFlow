import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/currency_format.dart';
import '../../providers/budgets_provider.dart';
import 'add_edit_budget_dialog.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressList = ref.watch(budgetProgressListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalBudget = progressList.fold(0.0, (sum, b) => sum + b.budget.limitAmount);
    final totalSpent = progressList.fold(0.0, (sum, b) => sum + b.spent);
    final overallPct = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets & Spending Limits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Budget',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddEditBudgetDialog(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Budget Card
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Period Budget Utilization',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${(overallPct * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: overallPct > 1.0
                              ? AppColors.expense
                              : overallPct > 0.8
                                  ? Colors.amber.shade700
                                  : AppColors.income,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: overallPct,
                      minHeight: 10,
                      backgroundColor: isDark ? Colors.white10 : Colors.black12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        overallPct > 1.0
                            ? AppColors.expense
                            : overallPct > 0.8
                                ? Colors.amber.shade700
                                : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent: ${CurrencyFormat.format(totalSpent, showDecimals: false)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        'Limit: ${CurrencyFormat.format(totalBudget, showDecimals: false)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Category Budgets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (progressList.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.pie_chart_outline,
                        size: 48,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(height: 12),
                      const Text('No budgets configured yet'),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const AddEditBudgetDialog(),
                          );
                        },
                        child: const Text('Add Category Budget'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: progressList.length,
                itemBuilder: (context, index) {
                  final bp = progressList[index];
                  final isOver = bp.spent > bp.budget.limitAmount;
                  final isWarning = bp.percentage >= 0.8 && !isOver;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isOver
                            ? AppColors.expense.withOpacity(0.5)
                            : isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  bp.budget.categoryName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                if (isOver) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.expense.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Exceeded',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.expense,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ] else if (isWarning) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Near Limit',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.amber.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AddEditBudgetDialog(existingBudget: bp.budget),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: bp.percentage,
                            minHeight: 8,
                            backgroundColor: isDark ? Colors.white10 : Colors.black12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isOver
                                  ? AppColors.expense
                                  : isWarning
                                      ? Colors.amber.shade700
                                      : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent: ${CurrencyFormat.format(bp.spent)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            Text(
                              isOver
                                  ? 'Over by ${CurrencyFormat.format(bp.spent - bp.budget.limitAmount)}'
                                  : 'Remaining: ${CurrencyFormat.format(bp.remaining)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isOver ? AppColors.expense : AppColors.income,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

