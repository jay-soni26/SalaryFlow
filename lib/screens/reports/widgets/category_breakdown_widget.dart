import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/currency_format.dart';
import '../../../models/transaction_model.dart';

class CategoryBreakdownWidget extends StatelessWidget {
  final List<TransactionModel> transactions;

  const CategoryBreakdownWidget({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Aggregate expenses by category
    final Map<String, double> categoryTotals = {};
    double totalExpenses = 0.0;

    for (final tx in transactions) {
      if (tx.type == TransactionType.expense) {
        categoryTotals[tx.categoryName] =
            (categoryTotals[tx.categoryName] ?? 0.0) + tx.amount;
        totalExpenses += tx.amount;
      }
    }

    if (categoryTotals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No expenses recorded in this period',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
      );
    }

    // Sort categories by highest spend
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending by Category',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedCategories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final entry = sortedCategories[index];
            final pct = totalExpenses > 0 ? (entry.value / totalExpenses) : 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      '${CurrencyFormat.format(entry.value)} (${(pct * 100).toStringAsFixed(1)}%)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getColorForIndex(index),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Color _getColorForIndex(int index) {
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.savings,
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
      Color(0xFF10B981),
      Color(0xFF8B5CF6),
    ];
    return colors[index % colors.length];
  }
}

