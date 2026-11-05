import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/currency_format.dart';
import '../../core/utils/date_cycle_helper.dart';
import '../../models/transaction_model.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/theme_provider.dart';
import 'widgets/cycle_banner.dart';
import 'widgets/balance_card.dart';
import 'widgets/metric_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/upcoming_bills_widget.dart';
import '../transactions/transactions_screen.dart';
import '../transactions/transaction_detail_dialog.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodTransactions = ref.watch(periodTransactionsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.currency_rupee, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('SalaryFlow'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(themeModeProvider.notifier).setThemeMode(
                    themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
                  );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(allTransactionsProvider.notifier).loadTransactions();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CycleBanner(),
              const BalanceCard(),
              const MetricsGrid(),
              const SecondaryMetricsRow(),
              const SizedBox(height: 8),
              const QuickActionsBar(),
              const UpcomingBillsWidget(),
              const SizedBox(height: 8),

              // Recent Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Period Transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),

              // Recent Transactions List
              if (periodTransactions.isEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 44,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No transactions in this period',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to log salary, income, or expenses',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: periodTransactions.length > 5 ? 5 : periodTransactions.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final tx = periodTransactions[index];
                    return _buildTransactionCard(context, ref, tx, isDark);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    WidgetRef ref,
    TransactionModel tx,
    bool isDark,
  ) {
    Color typeColor;
    IconData typeIcon;
    bool isNegative = false;

    switch (tx.type) {
      case TransactionType.income:
        typeColor = AppColors.income;
        typeIcon = Icons.arrow_downward;
        isNegative = false;
        break;
      case TransactionType.expense:
        typeColor = AppColors.expense;
        typeIcon = Icons.arrow_upward;
        isNegative = true;
        break;
      case TransactionType.salaryDeduction:
        typeColor = AppColors.deduction;
        typeIcon = Icons.receipt_long;
        isNegative = true;
        break;
      case TransactionType.transfer:
        typeColor = AppColors.transfer;
        typeIcon = Icons.swap_horiz;
        isNegative = false;
        break;
      case TransactionType.refund:
        typeColor = AppColors.refund;
        typeIcon = Icons.replay;
        isNegative = false;
        break;
      case TransactionType.savingsContribution:
        typeColor = AppColors.savings;
        typeIcon = Icons.savings;
        isNegative = true;
        break;
      case TransactionType.savingsWithdrawal:
        typeColor = AppColors.income;
        typeIcon = Icons.move_to_inbox;
        isNegative = false;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => TransactionDetailDialog(transaction: tx),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(typeIcon, color: typeColor, size: 20),
        ),
        title: Text(
          tx.description.isNotEmpty ? tx.description : tx.categoryName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${DateCycleHelper.formatDayMonth(tx.date)} • ${tx.categoryName}',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        trailing: Text(
          '${isNegative ? '-' : '+'}${CurrencyFormat.format(tx.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: typeColor,
          ),
        ),
      ),
    );
  }
}

