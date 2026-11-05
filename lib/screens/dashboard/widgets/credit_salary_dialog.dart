import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_cycle_helper.dart';
import '../../../models/salary_period.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/salary_cycle_provider.dart';
import '../../../providers/transactions_provider.dart';

class CreditSalaryDialog extends ConsumerStatefulWidget {
  final SalaryPeriod period;

  const CreditSalaryDialog({super.key, required this.period});

  @override
  ConsumerState<CreditSalaryDialog> createState() => _CreditSalaryDialogState();
}

class _CreditSalaryDialogState extends ConsumerState<CreditSalaryDialog> {
  late TextEditingController _amountCtrl;
  late TextEditingController _notesCtrl;
  late DateTime _creditDate;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.period.netSalary > 0
          ? widget.period.netSalary.toStringAsFixed(0)
          : '',
    );
    _notesCtrl = TextEditingController(text: widget.period.notes ?? '');
    _creditDate = widget.period.creditDate;
    _selectedAccountId = widget.period.salaryAccountId;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final isEditing = widget.period.netSalary > 0;
    final monthName = DateCycleHelper.formatMonthYear(
      DateTime(widget.period.year, widget.period.month),
    );

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.income.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.payments, color: AppColors.income, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isEditing ? 'Edit $monthName Salary' : 'Credit $monthName Salary',
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
              'Enter your net in-hand salary. It will be credited directly into your selected bank account.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // In-Hand Amount
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'Take-Home Salary (₹)',
                prefixText: '₹ ',
                prefixStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

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
                    labelText: 'Deposit to Bank Account',
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
            const SizedBox(height: 14),

            // Salary Credit Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: AppColors.primary),
              title: const Text('Salary Credit Date', style: TextStyle(fontSize: 13)),
              subtitle: Text(
                DateCycleHelper.formatShortDate(_creditDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit, size: 18),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.income,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
            if (amt <= 0 || _selectedAccountId == null) return;

            await ref.read(activeSalaryPeriodProvider.notifier).creditSalaryForMonth(
                  amount: amt,
                  accountId: _selectedAccountId!,
                  creditDate: _creditDate,
                  notes: _notesCtrl.text.trim(),
                );

            // Reload accounts and transactions so balances reflect immediately
            ref.read(accountsProvider.notifier).loadAccounts();
            ref.read(allTransactionsProvider.notifier).loadTransactions();

            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Credited ₹${amt.toStringAsFixed(0)} salary into selected bank account!',
                  ),
                ),
              );
            }
          },
          child: Text(isEditing ? 'Update Salary' : 'Credit to Bank'),
        ),
      ],
    );
  }
}

