import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/currency_format.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/export_service.dart';
import '../../providers/theme_provider.dart';
import '../../providers/salary_cycle_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/accounts_provider.dart';
import 'salary_settings_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final salaryConfigAsync = ref.watch(salaryConfigProvider);
    final allTransactionsAsync = ref.watch(allTransactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Configuration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Salary Configuration Section
          _buildSectionHeader('Salary & Income Configuration'),
          salaryConfigAsync.when(
            data: (cfg) => Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.payments, color: AppColors.primary),
                ),
                title: const Text('Salary Payday & Receiving Bank', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Default Payday: ${cfg.defaultSalaryDay}th of month • ${cfg.defaultIncomeSource}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => SalarySettingsDialog(currentConfig: cfg),
                  );
                },
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),

          // Appearance
          _buildSectionHeader('Appearance'),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (mode) {
                    if (mode != null) ref.read(themeModeProvider.notifier).setThemeMode(mode);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light Theme'),
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (mode) {
                    if (mode != null) ref.read(themeModeProvider.notifier).setThemeMode(mode);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Theme'),
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (mode) {
                    if (mode != null) ref.read(themeModeProvider.notifier).setThemeMode(mode);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data & Privacy
          _buildSectionHeader('Data Management & Privacy'),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download, color: AppColors.secondary),
                  title: const Text('Export Data to CSV'),
                  subtitle: const Text('Share or save your complete transaction ledger'),
                  onTap: () async {
                    final txs = allTransactionsAsync.value ?? [];
                    if (txs.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No transactions to export')),
                      );
                      return;
                    }
                    await ExportService.exportTransactionsToCsv(txs);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.science_outlined, color: AppColors.accent),
                  title: const Text('Load Realistic Demo Data'),
                  subtitle: const Text('Populates salary, PF, TDS, expenses & savings demo'),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Load Demo Data?'),
                        content: const Text(
                          'This will seed your database with sample salary cycles, accounts, and transactions for demonstration.',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Load Demo')),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await AppDatabase.instance.seedDemoData();
                      ref.read(allTransactionsProvider.notifier).loadTransactions();
                      ref.read(accountsProvider.notifier).loadAccounts();
                      ref.invalidate(activeSalaryPeriodProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Demo data loaded successfully!')),
                        );
                      }
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppColors.expense),
                  title: const Text('Reset All Local Data', style: TextStyle(color: AppColors.expense)),
                  subtitle: const Text('Clears all transactions and cycles from SQLite'),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset Database?'),
                        content: const Text(
                          'Are you sure? All transactions and cycles will be permanently erased.',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await AppDatabase.instance.resetAllData();
                      ref.read(allTransactionsProvider.notifier).loadTransactions();
                      ref.read(accountsProvider.notifier).loadAccounts();
                      ref.invalidate(activeSalaryPeriodProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Database cleared')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Privacy note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Local-First Privacy: All your data is stored encrypted locally in SQLite on your device. SalaryFlow never uploads your financial data to the cloud or requests banking passwords.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
      ),
    );
  }
}

