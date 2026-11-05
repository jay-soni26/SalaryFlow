import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/currency_format.dart';
import '../../../core/utils/date_cycle_helper.dart';
import '../../../models/transaction_model.dart';
import '../../../models/category.dart';
import '../../../models/account.dart';
import '../../../providers/transactions_provider.dart';
import '../../../providers/accounts_provider.dart';
import '../../../core/database/sample_data.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? existingTransaction;
  final TransactionType initialType;

  const AddEditTransactionScreen({
    super.key,
    this.existingTransaction,
    this.initialType = TransactionType.expense,
  });

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends ConsumerState<AddEditTransactionScreen> {
  late TransactionType _selectedType;
  late DateTime _selectedDate;
  late TextEditingController _amountCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _merchantCtrl;
  late TextEditingController _tagsCtrl;
  late TextEditingController _subcategoryCtrl;

  String? _selectedAccountId;
  String? _selectedDestinationAccountId;
  String? _selectedCategoryId;
  String _selectedCategoryName = 'General';
  String? _selectedPaymentApp;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final tx = widget.existingTransaction;

    _selectedType = tx?.type ?? widget.initialType;
    _selectedDate = tx?.date ?? DateTime.now();
    _amountCtrl = TextEditingController(text: tx != null ? tx.amount.toStringAsFixed(0) : '');
    _descCtrl = TextEditingController(text: tx?.description ?? '');
    _merchantCtrl = TextEditingController(text: tx?.merchant ?? '');
    _tagsCtrl = TextEditingController(text: tx != null ? tx.tags.join(', ') : '');
    _subcategoryCtrl = TextEditingController(text: tx?.subcategory ?? '');

    _selectedAccountId = tx?.accountId;
    _selectedDestinationAccountId = tx?.destinationAccountId;
    _selectedCategoryId = tx?.categoryId;
    _selectedCategoryName = tx?.categoryName ?? 'General';
    _selectedPaymentApp = tx?.paymentApp ?? 'gpay';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _merchantCtrl.dispose();
    _tagsCtrl.dispose();
    _subcategoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingTransaction != null;

    final categories = SampleData.defaultCategories;
    final filteredCategories = categories.where((c) {
      if (_selectedType == TransactionType.income) return c.isIncome;
      if (_selectedType == TransactionType.salaryDeduction) return c.isDeduction;
      return c.isExpense;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'New Transaction'),
        actions: [
          TextButton.icon(
            onPressed: _saveTransaction,
            icon: const Icon(Icons.check, color: AppColors.primary),
            label: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (_selectedAccountId == null && accounts.isNotEmpty) {
            _selectedAccountId = accounts.first.id;
          }
          if (_selectedDestinationAccountId == null && accounts.length > 1) {
            _selectedDestinationAccountId = accounts[1].id;
          }
          if (_selectedCategoryId == null && filteredCategories.isNotEmpty) {
            _selectedCategoryId = filteredCategories.first.id;
            _selectedCategoryName = filteredCategories.first.name;
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Type Selector Chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildTypeChip(TransactionType.expense, 'Expense', AppColors.expense),
                        _buildTypeChip(TransactionType.income, 'Income', AppColors.income),
                        _buildTypeChip(TransactionType.transfer, 'Transfer', AppColors.transfer),
                        _buildTypeChip(TransactionType.salaryDeduction, 'Deduction', AppColors.deduction),
                        _buildTypeChip(TransactionType.savingsContribution, 'To Savings', AppColors.savings),
                        _buildTypeChip(TransactionType.refund, 'Refund', AppColors.refund),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Amount Field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                            autofocus: !isEditing,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              fillColor: Colors.transparent,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Enter amount';
                              }
                              final num = double.tryParse(val);
                              if (num == null || num <= 0) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date & Account Selector in a clean Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Date picker
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                          title: const Text('Date', style: TextStyle(fontSize: 14)),
                          subtitle: Text(
                            DateCycleHelper.formatShortDate(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                        ),
                        const Divider(),

                        // Account Picker
                        DropdownButtonFormField<String>(
                          value: _selectedAccountId,
                          decoration: InputDecoration(
                            labelText: _selectedType == TransactionType.transfer
                                ? 'From Account'
                                : 'Account',
                            prefixIcon: const Icon(Icons.account_balance),
                          ),
                          items: accounts.map((acc) {
                            return DropdownMenuItem(
                              value: acc.id,
                              child: Text('${acc.name} (${CurrencyFormat.format(acc.currentBalance)})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedAccountId = val);
                          },
                        ),

                        // If Transfer, show Destination Account
                        if (_selectedType == TransactionType.transfer) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedDestinationAccountId,
                            decoration: const InputDecoration(
                              labelText: 'To Account',
                              prefixIcon: Icon(Icons.input, color: AppColors.income),
                            ),
                            items: accounts
                                .where((a) => a.id != _selectedAccountId)
                                .map((acc) {
                              return DropdownMenuItem(
                                value: acc.id,
                                child: Text('${acc.name} (${CurrencyFormat.format(acc.currentBalance)})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedDestinationAccountId = val);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category Selector (if not transfer)
                  if (_selectedType != TransactionType.transfer) ...[
                    const Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filteredCategories.map((cat) {
                        final isSelected = _selectedCategoryId == cat.id;
                        return ChoiceChip(
                          label: Text(cat.name),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategoryId = cat.id;
                                _selectedCategoryName = cat.name;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Details: Description, Merchant, Tags
                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description / Note',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _merchantCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Payee / Merchant',
                            prefixIcon: Icon(Icons.store),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _subcategoryCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Subcategory',
                            prefixIcon: Icon(Icons.folder_open),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _tagsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma separated e.g. food, office)',
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment method tag
                  const Text(
                    'Payment Mode',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPaymentModeChip('gpay', 'Google Pay', Icons.payment),
                      const SizedBox(width: 8),
                      _buildPaymentModeChip('phonepe', 'PhonePe', Icons.phone_android),
                      const SizedBox(width: 8),
                      _buildPaymentModeChip('bank_transfer', 'Net Banking', Icons.account_balance),
                      const SizedBox(width: 8),
                      _buildPaymentModeChip('cash', 'Cash', Icons.money),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTypeChip(TransactionType type, String label, Color color) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        backgroundColor: color.withOpacity(0.08),
        selectedColor: color,
        checkmarkColor: Colors.white,
        side: BorderSide(color: color.withOpacity(0.3)),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedType = type;
            });
          }
        },
      ),
    );
  }

  Widget _buildPaymentModeChip(String id, String label, IconData icon) {
    final isSelected = _selectedPaymentApp == id;
    return ChoiceChip(
      selected: isSelected,
      avatar: Icon(icon, size: 16, color: isSelected ? AppColors.primary : null),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onSelected: (selected) {
        if (selected) setState(() => _selectedPaymentApp = id);
      },
    );
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) return;

    final amount = double.parse(_amountCtrl.text.trim());
    final tagList = _tagsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final tx = TransactionModel(
      id: widget.existingTransaction?.id ?? const Uuid().v4(),
      amount: amount,
      date: _selectedDate,
      type: _selectedType,
      categoryId: _selectedCategoryId ?? 'cat_other',
      categoryName: _selectedType == TransactionType.transfer
          ? 'Transfer'
          : _selectedCategoryName,
      subcategory: _subcategoryCtrl.text.trim().isNotEmpty ? _subcategoryCtrl.text.trim() : null,
      accountId: _selectedAccountId!,
      destinationAccountId: _selectedType == TransactionType.transfer
          ? _selectedDestinationAccountId
          : null,
      description: _descCtrl.text.trim(),
      merchant: _merchantCtrl.text.trim().isNotEmpty ? _merchantCtrl.text.trim() : null,
      tags: tagList,
      paymentApp: _selectedPaymentApp,
      salaryPeriodId: '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}',
    );

    if (widget.existingTransaction != null) {
      await ref
          .read(allTransactionsProvider.notifier)
          .updateTransaction(widget.existingTransaction!, tx);
    } else {
      await ref.read(allTransactionsProvider.notifier).addTransaction(tx);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingTransaction != null
                ? 'Transaction updated'
                : 'Transaction recorded successfully',
          ),
        ),
      );
    }
  }
}

