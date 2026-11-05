import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/account.dart';
import '../../../providers/accounts_provider.dart';

class AddEditAccountDialog extends ConsumerStatefulWidget {
  final Account? existingAccount;

  const AddEditAccountDialog({super.key, this.existingAccount});

  @override
  ConsumerState<AddEditAccountDialog> createState() => _AddEditAccountDialogState();
}

class _AddEditAccountDialogState extends ConsumerState<AddEditAccountDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _openingBalCtrl;
  late TextEditingController _currentBalCtrl;
  late AccountType _type;
  bool _isSalaryDefault = false;
  bool _isSavingsDefault = false;

  @override
  void initState() {
    super.initState();
    final acc = widget.existingAccount;
    _nameCtrl = TextEditingController(text: acc?.name ?? '');
    _openingBalCtrl =
        TextEditingController(text: acc != null ? acc.openingBalance.toStringAsFixed(0) : '0');
    _currentBalCtrl =
        TextEditingController(text: acc != null ? acc.currentBalance.toStringAsFixed(0) : '0');
    _type = acc?.type ?? AccountType.salaryBank;
    _isSalaryDefault = acc?.isSalaryDefault ?? false;
    _isSavingsDefault = acc?.isSavingsDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _openingBalCtrl.dispose();
    _currentBalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAccount != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Account' : 'Add New Account'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g. HDFC Salary Account',
                prefixIcon: Icon(Icons.account_balance),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AccountType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Account Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: AccountType.values.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _type = val);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _openingBalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Opening Balance (₹)',
                prefixIcon: Icon(Icons.lock_clock),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _currentBalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Current Balance (₹)',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Default for Salary Credit', style: TextStyle(fontSize: 13)),
              value: _isSalaryDefault,
              onChanged: (val) => setState(() => _isSalaryDefault = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Default for Savings', style: TextStyle(fontSize: 13)),
              value: _isSavingsDefault,
              onChanged: (val) => setState(() => _isSavingsDefault = val),
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
            final name = _nameCtrl.text.trim();
            if (name.isEmpty) return;

            final openBal = double.tryParse(_openingBalCtrl.text) ?? 0.0;
            final curBal = isEditing
                ? (double.tryParse(_currentBalCtrl.text) ?? openBal)
                : openBal;

            final acc = Account(
              id: widget.existingAccount?.id ?? const Uuid().v4(),
              name: name,
              type: _type,
              openingBalance: openBal,
              currentBalance: curBal,
              isSalaryDefault: _isSalaryDefault,
              isSavingsDefault: _isSavingsDefault,
            );

            if (isEditing) {
              await ref.read(accountsProvider.notifier).updateAccount(acc);
            } else {
              await ref.read(accountsProvider.notifier).addAccount(acc);
            }

            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEditing ? 'Account updated' : 'Account created'),
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

