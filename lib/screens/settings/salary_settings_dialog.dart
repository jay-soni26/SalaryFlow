import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/salary_config.dart';
import '../../../core/database/app_database.dart';
import '../../../providers/salary_cycle_provider.dart';
import '../../../providers/accounts_provider.dart';

class SalarySettingsDialog extends ConsumerStatefulWidget {
  final SalaryConfig currentConfig;

  const SalarySettingsDialog({super.key, required this.currentConfig});

  @override
  ConsumerState<SalarySettingsDialog> createState() => _SalarySettingsDialogState();
}

class _SalarySettingsDialogState extends ConsumerState<SalarySettingsDialog> {
  late TextEditingController _sourceCtrl;
  late TextEditingController _dayCtrl;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    final cfg = widget.currentConfig;
    _sourceCtrl = TextEditingController(text: cfg.defaultIncomeSource);
    _dayCtrl = TextEditingController(text: cfg.defaultSalaryDay.toString());
    _selectedAccountId = cfg.defaultSalaryAccountId;
  }

  @override
  void dispose() {
    _sourceCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);

    return AlertDialog(
      title: const Text('Salary Preferences'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set your default salary payday and default receiving bank account.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sourceCtrl,
              decoration: const InputDecoration(
                labelText: 'Income Source / Company',
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dayCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Default Salary Payday (1-31)',
                prefixIcon: Icon(Icons.calendar_today),
                helperText: 'E.g. 1 for 1st of month, 25 for 25th',
              ),
            ),
            const SizedBox(height: 12),
            accountsAsync.when(
              data: (accounts) {
                if (_selectedAccountId == null && accounts.isNotEmpty) {
                  _selectedAccountId = accounts.first.id;
                }
                return DropdownButtonFormField<String>(
                  value: _selectedAccountId,
                  decoration: const InputDecoration(
                    labelText: 'Default Salary Bank Account',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: accounts.map((a) {
                    return DropdownMenuItem(value: a.id, child: Text(a.name));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedAccountId = val),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final day = (int.tryParse(_dayCtrl.text) ?? 1).clamp(1, 31);

            final updated = widget.currentConfig.copyWith(
              defaultIncomeSource: _sourceCtrl.text.trim(),
              defaultSalaryDay: day,
              defaultSalaryAccountId: _selectedAccountId,
            );

            await AppDatabase.instance.updateSalaryConfig(updated);
            ref.invalidate(salaryConfigProvider);

            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Salary preferences updated')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
