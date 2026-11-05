import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/currency_format.dart';
import '../../models/account.dart';
import '../../models/transaction_model.dart';
import '../../providers/accounts_provider.dart';
import 'add_edit_account_dialog.dart';
import '../transactions/add_edit_transaction_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts & Wallets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Account',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddEditAccountDialog(),
              );
            },
          ),
        ],
      ),
      body: accountsAsync.when(
        data: (accounts) {
          final totalBalance = ref.read(accountsProvider.notifier).getTotalBalance(accounts);
          final totalSavings = ref.read(accountsProvider.notifier).getSavingsBalance(accounts);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Net Worth Banner
                Container(
                  width: double.infinity,
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
                      Text(
                        'Total Combined Balance',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        CurrencyFormat.format(totalBalance),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.savings.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Savings: ${CurrencyFormat.format(totalSavings, showDecimals: false)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.savings,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          FilledButton.tonalIcon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AddEditTransactionScreen(
                                    initialType: TransactionType.transfer,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.swap_horiz, size: 16),
                            label: const Text('Transfer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Your Accounts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final acc = accounts[index];
                    return _buildAccountTile(context, ref, acc, isDark);
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildAccountTile(
    BuildContext context,
    WidgetRef ref,
    Account acc,
    bool isDark,
  ) {
    IconData icon;
    Color color;

    switch (acc.type) {
      case AccountType.salaryBank:
        icon = Icons.account_balance;
        color = AppColors.primary;
        break;
      case AccountType.savingsBank:
        icon = Icons.savings;
        color = AppColors.savings;
        break;
      case AccountType.cashWallet:
        icon = Icons.wallet;
        color = AppColors.accent;
        break;
      case AccountType.otherBank:
        icon = Icons.credit_card;
        color = AppColors.secondary;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Row(
          children: [
            Text(
              acc.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            if (acc.isSalaryDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Salary',
                  style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          acc.typeDisplayName,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormat.format(acc.currentBalance),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Opening: ${CurrencyFormat.format(acc.openingBalance, showDecimals: false)}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AddEditAccountDialog(existingAccount: acc),
          );
        },
      ),
    );
  }
}

