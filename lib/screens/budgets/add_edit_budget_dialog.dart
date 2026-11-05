import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/sample_data.dart';
import '../../../models/budget.dart';
import '../../../providers/budgets_provider.dart';

class AddEditBudgetDialog extends ConsumerStatefulWidget {
  final Budget? existingBudget;

  const AddEditBudgetDialog({super.key, this.existingBudget});

  @override
  ConsumerState<AddEditBudgetDialog> createState() => _AddEditBudgetDialogState();
}

class _AddEditBudgetDialogState extends ConsumerState<AddEditBudgetDialog> {
  late String _selectedCategoryId;
  late String _selectedCategoryName;
  late TextEditingController _limitCtrl;

  @override
  void initState() {
    super.initState();
    final b = widget.existingBudget;
    final defaultCat = SampleData.defaultCategories.firstWhere((c) => c.isExpense);
    _selectedCategoryId = b?.categoryId ?? defaultCat.id;
    _selectedCategoryName = b?.categoryName ?? defaultCat.name;
    _limitCtrl = TextEditingController(text: b != null ? b.limitAmount.toStringAsFixed(0) : '');
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories =
        SampleData.defaultCategories.where((c) => c.isExpense).toList();
    final isEditing = widget.existingBudget != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Budget' : 'Set Category Budget'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: expenseCategories.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Text(cat.name),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  final cat = expenseCategories.firstWhere((c) => c.id == val);
                  setState(() {
                    _selectedCategoryId = cat.id;
                    _selectedCategoryName = cat.name;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _limitCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly Limit Amount (₹)',
                prefixIcon: Icon(Icons.speed),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (isEditing)
          TextButton(
            onPressed: () async {
              await ref.read(budgetsProvider.notifier).deleteBudget(widget.existingBudget!.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget deleted')),
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
            final limit = double.tryParse(_limitCtrl.text) ?? 0.0;
            if (limit <= 0) return;

            final budget = Budget(
              id: widget.existingBudget?.id ?? const Uuid().v4(),
              categoryId: _selectedCategoryId,
              categoryName: _selectedCategoryName,
              limitAmount: limit,
            );

            await ref.read(budgetsProvider.notifier).saveBudget(budget);
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isEditing ? 'Budget updated' : 'Budget saved')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

