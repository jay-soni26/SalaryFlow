import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/currency_format.dart';
import '../../../models/transaction_model.dart';

class SpendingBarChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const SpendingBarChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group expenses by day of the month
    final Map<int, double> dailyExpenses = {};
    for (final tx in transactions) {
      if (tx.type == TransactionType.expense) {
        final day = tx.date.day;
        dailyExpenses[day] = (dailyExpenses[day] ?? 0) + tx.amount;
      }
    }

    if (dailyExpenses.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text(
          'No expense data to graph',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    final sortedDays = dailyExpenses.keys.toList()..sort();
    final maxAmount = dailyExpenses.values.fold(0.0, (max, v) => v > max ? v : max);

    final barGroups = sortedDays.map((day) {
      final amount = dailyExpenses[day] ?? 0.0;
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: AppColors.primary,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Spending Distribution',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'Max: ${CurrencyFormat.format(maxAmount, showDecimals: false)}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxAmount * 1.15,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      'Day ${group.x}\n${CurrencyFormat.format(rod.toY, showDecimals: false)}',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final day = value.toInt();
                      if (sortedDays.contains(day)) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    );
  }
}

