import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/currency_format.dart';
import '../../core/utils/date_cycle_helper.dart';
import '../../models/savings_goal.dart';
import '../../providers/savings_goals_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/transactions_provider.dart';
import 'add_savings_goal_dialog.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final summary = ref.watch(periodFinancialSummaryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalSavingsInBank = accountsAsync.when(
      data: (accs) => ref.read(accountsProvider.notifier).getSavingsBalance(accs),
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings & Wealth Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Goal',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddSavingsGoalDialog(),
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
            // Savings Overview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.savings.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Protected Savings Vault',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormat.format(totalSavingsInBank),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Period Savings Rate', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Text(
                            '${summary.savingsRate.toStringAsFixed(1)}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Available to Spend', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Text(
                            CurrencyFormat.format(summary.availableSpendingBalance, showDecimals: false),
                            style: const TextStyle(color: Color(0xFFFDE047), fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Active Savings Goals',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            goalsAsync.when(
              data: (goals) {
                if (goals.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.savings_outlined,
                            size: 48,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(height: 12),
                          const Text('No savings goals added yet'),
                          const SizedBox(height: 8),
                          FilledButton.tonal(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const AddSavingsGoalDialog(),
                              );
                            },
                            child: const Text('Create a Goal'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    return _buildGoalCard(context, ref, goal, isDark);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Text(
                goal.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 18),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddSavingsGoalDialog(existingGoal: goal),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CurrencyFormat.format(goal.currentAmount, showDecimals: false)} of ${CurrencyFormat.format(goal.targetAmount, showDecimals: false)}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                '${(goal.progressPercentage * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.savings,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal.progressPercentage,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.savings),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (goal.targetDate != null)
                Text(
                  'Target: ${DateCycleHelper.formatShortDate(goal.targetDate!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                )
              else
                const SizedBox.shrink(),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () => _showContributeDialog(context, ref, goal),
                child: const Text('Add Money', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showContributeDialog(BuildContext context, WidgetRef ref, SavingsGoal goal) {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Contribute to ${goal.name}'),
        content: TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Contribution Amount (₹)',
            prefixIcon: Icon(Icons.savings),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
              if (amt > 0) {
                await ref.read(savingsGoalsProvider.notifier).contributeToGoal(goal.id, amt);
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added ${CurrencyFormat.format(amt)} to ${goal.name}')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

