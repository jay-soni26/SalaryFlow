import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/transaction_model.dart';
import '../../transactions/add_edit_transaction_screen.dart';
import '../../accounts/accounts_screen.dart';
import '../../budgets/budgets_screen.dart';

class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(
            context: context,
            icon: Icons.remove_circle_outline,
            label: 'Expense',
            color: AppColors.expense,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddEditTransactionScreen(
                    initialType: TransactionType.expense,
                  ),
                ),
              );
            },
          ),
          _buildActionItem(
            context: context,
            icon: Icons.add_circle_outline,
            label: 'Income',
            color: AppColors.income,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddEditTransactionScreen(
                    initialType: TransactionType.income,
                  ),
                ),
              );
            },
          ),
          _buildActionItem(
            context: context,
            icon: Icons.swap_horiz,
            label: 'Transfer',
            color: AppColors.transfer,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddEditTransactionScreen(
                    initialType: TransactionType.transfer,
                  ),
                ),
              );
            },
          ),
          _buildActionItem(
            context: context,
            icon: Icons.account_balance,
            label: 'Accounts',
            color: AppColors.secondary,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AccountsScreen()),
              );
            },
          ),
          _buildActionItem(
            context: context,
            icon: Icons.pie_chart_outline,
            label: 'Budgets',
            color: AppColors.accent,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BudgetsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

