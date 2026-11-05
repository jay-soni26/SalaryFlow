import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_cycle_helper.dart';
import '../../../models/salary_period.dart';
import '../../../providers/salary_cycle_provider.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/transactions_provider.dart';

class EditCycleDialog extends ConsumerStatefulWidget {
  final SalaryPeriod period;

  const EditCycleDialog({super.key, required this.period});

  @override
  ConsumerState<EditCycleDialog> createState() => _EditCycleDialogState();
}

class _EditCycleDialogState extends ConsumerState<EditCycleDialog> {
  late DateTime _creditDate;
  late DateTime _startDate;
  late DateTime _endDate;
  late TextEditingController _netSalaryCtrl;
  late TextEditingController _carryForwardCtrl;
  late TextEditingController _notesCtrl;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _creditDate = widget.period.creditDate;
    _startDate = widget.period.startDate;
    _endDate = widget.period.endDate;
    _netSalaryCtrl = TextEditingController(
      text: widget.period.netSalary > 0
          ? widget.period.netSalary.toStringAsFixed(0)
          : '',
    );
    _carryForwardCtrl =
        TextEditingController(text: widget.period.carryForwardBalance.toStringAsFixed(0));
    _notesCtrl = TextEditingController(text: widget.period.notes ?? '');
    _selectedAccountId = widget.period.salaryAccountId;
  }

  @override
  void dispose() {
    _netSalaryCtrl.dispose();
    _carryForwardCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final monthTitle = DateCycleHelper.formatMonthYear(
      DateTime(widget.period.year, widget.period.month),
    );

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.tune, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Salary & Cycle: $monthTitle',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customize in-hand salary, credit account, and date range for this month.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Take-Home Salary
            TextField(
              controller: _netSalaryCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'Take-Home Salary (₹)',
                prefixText: '₹ ',
                prefixIcon: Icon(Icons.payments),
              ),
            ),
            const SizedBox(height: 12),

            // Preferred Bank Account
            accountsAsync.when(
              data: (accounts) {
                if (_selectedAccountId == null && accounts.isNotEmpty) {
                  final def = accounts.firstWhere(
                    (a) => a.isSalaryDefault,
                    orElse: () => accounts.first,
                  );
                  _selectedAccountId = def.id;
                }
                return DropdownButtonFormField<String>(
                  value: _selectedAccountId,
                  decoration: const InputDecoration(
                    labelText: 'Deposit Bank Account',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: accounts.map((acc) {
                    return DropdownMenuItem(
                      value: acc.id,
                      child: Text(acc.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedAccountId = val);
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),

            // Credit Date Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_available, color: AppColors.primary),
              title: const Text('Salary Credit Date', style: TextStyle(fontSize: 13)),
              subtitle: Text(
                DateCycleHelper.formatShortDate(_creditDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.calendar_month, size: 20),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _creditDate,
                  firstDate: DateTime(widget.period.year, widget.period.month, 1),
                  lastDate: DateTime(
                    widget.period.year,
                    widget.period.month,
                    DateCycleHelper.getDaysInMonth(widget.period.year, widget.period.month),
                  ),
                );
                if (picked != null) {
                  setState(() => _creditDate = picked);
                }
              },
            ),

            const Divider(),

            // Start Date Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.start, color: AppColors.secondary),
              title: const Text('Period Start Date', style: TextStyle(fontSize: 13)),
              subtitle: Text(
                DateCycleHelper.formatShortDate(_startDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit, size: 18),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  setState(() => _startDate = picked);
                }
              },
            ),

            // End Date Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.arrow_circle_right, color: AppColors.expense),
              title: const Text('Period End Date', style: TextStyle(fontSize: 13)),
              subtitle: Text(
                DateCycleHelper.formatShortDate(_endDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit, size: 18),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate,
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  setState(() => _endDate = picked);
                }
              },
            ),

            const Divider(),
            const SizedBox(height: 8),

            // Carry Forward Balance
            TextField(
              controller: _carryForwardCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Carry Forward Balance (₹)',
                prefixIcon: Icon(Icons.trending_flat),
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
            final salary = double.tryParse(_netSalaryCtrl.text.trim()) ?? 0.0;
            final carry = double.tryParse(_carryForwardCtrl.text.trim()) ?? 0.0;

            if (salary > 0 && _selectedAccountId != null) {
              await ref.read(activeSalaryPeriodProvider.notifier).creditSalaryForMonth(
                    amount: salary,
                    accountId: _selectedAccountId!,
                    creditDate: _creditDate,
                    notes: _notesCtrl.text.trim(),
                  );
            }

            await ref.read(activeSalaryPeriodProvider.notifier).updatePeriodDetails(
                  creditDate: _creditDate,
                  startDate: _startDate,
                  endDate: _endDate,
                  grossSalary: salary,
                  deductions: 0.0,
                  netSalary: salary,
                  carryForwardBalance: carry,
                  salaryAccountId: _selectedAccountId,
                  notes: _notesCtrl.text.trim(),
                );

            ref.read(accountsProvider.notifier).loadAccounts();
            ref.read(allTransactionsProvider.notifier).loadTransactions();

            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Salary period updated')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
