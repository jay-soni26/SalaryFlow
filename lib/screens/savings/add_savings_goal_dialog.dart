import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_cycle_helper.dart';
import '../../../models/savings_goal.dart';
import '../../../providers/savings_goals_provider.dart';

class AddSavingsGoalDialog extends ConsumerStatefulWidget {
  final SavingsGoal? existingGoal;

  const AddSavingsGoalDialog({super.key, this.existingGoal});

  @override
  ConsumerState<AddSavingsGoalDialog> createState() => _AddSavingsGoalDialogState();
}

class _AddSavingsGoalDialogState extends ConsumerState<AddSavingsGoalDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _targetAmountCtrl;
  late TextEditingController _currentAmountCtrl;
  late TextEditingController _notesCtrl;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    final g = widget.existingGoal;
    _nameCtrl = TextEditingController(text: g?.name ?? '');
    _targetAmountCtrl =
        TextEditingController(text: g != null ? g.targetAmount.toStringAsFixed(0) : '');
    _currentAmountCtrl =
        TextEditingController(text: g != null ? g.currentAmount.toStringAsFixed(0) : '0');
    _notesCtrl = TextEditingController(text: g?.notes ?? '');
    _targetDate = g?.targetDate ?? DateTime.now().add(const Duration(days: 365));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetAmountCtrl.dispose();
    _currentAmountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingGoal != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Savings Goal' : 'New Savings Goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Goal Name',
                hintText: 'e.g. Emergency Fund, House Downpayment',
                prefixIcon: Icon(Icons.flag),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetAmountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Amount (₹)',
                prefixIcon: Icon(Icons.track_changes),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _currentAmountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current Saved Amount (₹)',
                prefixIcon: Icon(Icons.savings),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month, color: AppColors.primary),
              title: const Text('Target Date', style: TextStyle(fontSize: 14)),
              subtitle: Text(
                _targetDate != null
                    ? DateCycleHelper.formatShortDate(_targetDate!)
                    : 'No target date',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit, size: 18),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2040),
                );
                if (picked != null) {
                  setState(() => _targetDate = picked);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (isEditing)
          TextButton(
            onPressed: () async {
              await ref.read(savingsGoalsProvider.notifier).deleteGoal(widget.existingGoal!.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Savings goal deleted')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.expense)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final name = _nameCtrl.text.trim();
            final target = double.tryParse(_targetAmountCtrl.text) ?? 0.0;
            final current = double.tryParse(_currentAmountCtrl.text) ?? 0.0;
            if (name.isEmpty || target <= 0) return;

            final goal = SavingsGoal(
              id: widget.existingGoal?.id ?? const Uuid().v4(),
              name: name,
              targetAmount: target,
              currentAmount: current,
              targetDate: _targetDate,
              colorValue: 0xFF10B981,
              notes: _notesCtrl.text.trim(),
            );

            await ref.read(savingsGoalsProvider.notifier).saveGoal(goal);
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isEditing ? 'Goal updated' : 'Goal created')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

