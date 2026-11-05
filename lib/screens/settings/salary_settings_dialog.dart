import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
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
  late TextEditingController _salaryAmountCtrl;
  late TextEditingController _sourceCtrl;
  late TextEditingController _dayCtrl;
  late TextEditingController _pfCtrl;
  late TextEditingController _taxCtrl;
  late TextEditingController _insuranceCtrl;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    final cfg = widget.currentConfig;
    _salaryAmountCtrl =
        TextEditingController(text: cfg.defaultSalaryAmount.toStringAsFixed(0));
    _sourceCtrl = TextEditingController(text: cfg.defaultIncomeSource);
    _dayCtrl = TextEditingController(text: cfg.defaultSalaryDay.toString());
    _pfCtrl = TextEditingController(text: cfg.defaultPfDeduction.toStringAsFixed(0));
    _taxCtrl = TextEditingController(text: cfg.defaultTaxDeduction.toStringAsFixed(0));
    _insuranceCtrl =
        TextEditingController(text: cfg.defaultInsuranceDeduction.toStringAsFixed(0));
    _selectedAccountId = cfg.defaultSalaryAccountId;
  }

  @override
  void dispose() {
    _salaryAmountCtrl.dispose();
    _sourceCtrl.dispose();
    _dayCtrl.dispose();
    _pfCtrl.dispose();
    _taxCtrl.dispose();
    _insuranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);

    return AlertDialog(
      title: const Text('Default Salary Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'These defaults apply when generating upcoming salary cycles. Past cycles remain intact.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _salaryAmountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Gross Monthly Salary (₹)',
                prefixIcon: Icon(Icons.payments),
              ),
            ),
            const SizedBox(height: 12),
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
                labelText: 'Default Credit Day of Month (1-31)',
                prefixIcon: Icon(Icons.calendar_today),
                helperText: 'E.g. 1 for 1st of month, 31 for month-end',
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
                    labelText: 'Salary Credit Account',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: accounts.map((a) {
                    return DropdownMenuItem(value: a.id, child: Text(a.name));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedAccountId = val),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Standard Monthly Deductions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pfCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Provident Fund (PF) (₹)',
                prefixIcon: Icon(Icons.security),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _taxCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Income Tax (TDS) (₹)',
                prefixIcon: Icon(Icons.receipt_long),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _insuranceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Health Insurance (₹)',
                prefixIcon: Icon(Icons.health_and_safety),
              ),
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
            final amount = double.tryParse(_salaryAmountCtrl.text) ?? 85000.0;
            final day = (int.tryParse(_dayCtrl.text) ?? 1).clamp(1, 31);
            final pf = double.tryParse(_pfCtrl.text) ?? 0.0;
            final tax = double.tryParse(_taxCtrl.text) ?? 0.0;
            final ins = double.tryParse(_insuranceCtrl.text) ?? 0.0;

            final updated = SalaryConfig(
              defaultSalaryAmount: amount,
              defaultIncomeSource: _sourceCtrl.text.trim(),
              defaultSalaryDay: day,
              defaultSalaryAccountId: _selectedAccountId,
              defaultPfDeduction: pf,
              defaultTaxDeduction: tax,
              defaultInsuranceDeduction: ins,
            );

            await AppDatabase.instance.updateSalaryConfig(updated);
            ref.invalidate(salaryConfigProvider);

            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Salary configuration updated')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

