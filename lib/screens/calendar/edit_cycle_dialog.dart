import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/currency_format.dart';
import '../../../core/utils/date_cycle_helper.dart';
import '../../../models/salary_period.dart';
import '../../../providers/salary_cycle_provider.dart';

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
  late TextEditingController _grossSalaryCtrl;
  late TextEditingController _deductionsCtrl;
  late TextEditingController _carryForwardCtrl;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _creditDate = widget.period.creditDate;
    _startDate = widget.period.startDate;
    _endDate = widget.period.endDate;
    _grossSalaryCtrl =
        TextEditingController(text: widget.period.grossSalary.toStringAsFixed(0));
    _deductionsCtrl =
        TextEditingController(text: widget.period.deductions.toStringAsFixed(0));
    _carryForwardCtrl =
        TextEditingController(text: widget.period.carryForwardBalance.toStringAsFixed(0));
    _notesCtrl = TextEditingController(text: widget.period.notes ?? '');
  }

  @override
  void dispose() {
    _grossSalaryCtrl.dispose();
    _deductionsCtrl.dispose();
    _carryForwardCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _netSalary {
    final gross = double.tryParse(_grossSalaryCtrl.text) ?? 0.0;
    final ded = double.tryParse(_deductionsCtrl.text) ?? 0.0;
    return (gross - ded).clamp(0.0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.tune, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Edit Cycle: ${DateCycleHelper.formatMonthYear(DateTime(widget.period.year, widget.period.month))}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              'Customize this salary cycle independently. Changes apply only to this period.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Credit Date Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_available, color: AppColors.primary),
              title: const Text('Salary Credit Date', style: TextStyle(fontSize: 14)),
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
              title: const Text('Period Start Date', style: TextStyle(fontSize: 14)),
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
              title: const Text('Period End Date', style: TextStyle(fontSize: 14)),
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

            // Gross Salary
            TextField(
              controller: _grossSalaryCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Gross Salary (₹)',
                prefixIcon: Icon(Icons.payments),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Deductions (PF, Tax, etc.)
            TextField(
              controller: _deductionsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Deductions (PF, Tax) (₹)',
                prefixIcon: Icon(Icons.receipt_long),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Net Salary Indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.income.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Net Salary Credited:'),
                  Text(
                    CurrencyFormat.format(_netSalary),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.income,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Carry Forward Balance
            TextField(
              controller: _carryForwardCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Carry Forward Balance (₹)',
                prefixIcon: Icon(Icons.trending_flat),
              ),
            ),
            const SizedBox(height: 12),

            // Notes
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes for this cycle (optional)',
                prefixIcon: Icon(Icons.notes),
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
            final gross = double.tryParse(_grossSalaryCtrl.text) ?? widget.period.grossSalary;
            final ded = double.tryParse(_deductionsCtrl.text) ?? widget.period.deductions;
            final carry = double.tryParse(_carryForwardCtrl.text) ?? 0.0;
            final net = (gross - ded).clamp(0.0, double.infinity);

            await ref.read(activeSalaryPeriodProvider.notifier).updatePeriodDetails(
                  creditDate: _creditDate,
                  startDate: _startDate,
                  endDate: _endDate,
                  grossSalary: gross,
                  deductions: ded,
                  netSalary: net,
                  carryForwardBalance: carry,
                  notes: _notesCtrl.text.trim(),
                );

            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Salary period updated successfully')),
              );
            }
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}

