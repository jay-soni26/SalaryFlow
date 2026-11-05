import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_cycle_helper.dart';
import '../../../providers/salary_cycle_provider.dart';
import '../../calendar/edit_cycle_dialog.dart';

class CycleBanner extends ConsumerWidget {
  const CycleBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedCycleMonthProvider);
    final activePeriodAsync = ref.watch(activeSalaryPeriodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  ref.read(selectedCycleMonthProvider.notifier).state =
                      selectedMonth.previous();
                },
                tooltip: 'Previous Period',
              ),
              Column(
                children: [
                  Text(
                    DateCycleHelper.formatMonthYear(
                      DateTime(selectedMonth.year, selectedMonth.month),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  activePeriodAsync.when(
                    data: (period) => Text(
                      DateCycleHelper.formatPeriodRange(period.startDate, period.endDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    loading: () => const Text('Loading period...', style: TextStyle(fontSize: 12)),
                    error: (_, __) => const Text('Error loading period', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  ref.read(selectedCycleMonthProvider.notifier).state =
                      selectedMonth.next();
                },
                tooltip: 'Next Period',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              activePeriodAsync.when(
                data: (period) => InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => EditCycleDialog(period: period),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_calendar, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Credit: ${DateCycleHelper.formatDayMonth(period.creditDate)} ${period.isCustomized ? "(Custom)" : ""}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

