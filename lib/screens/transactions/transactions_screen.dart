import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/currency_format.dart';
import '../../core/utils/date_cycle_helper.dart';
import '../../core/utils/export_service.dart';
import '../../models/transaction_model.dart';
import '../../providers/transactions_provider.dart';
import 'add_edit_transaction_screen.dart';
import 'transaction_detail_dialog.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';
  TransactionType? _selectedTypeFilter;
  final String _sortBy = 'date_desc'; // 'date_desc', 'date_asc', 'amount_desc', 'amount_asc'

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          transactionsAsync.when(
            data: (txs) => IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Export CSV',
              onPressed: () async {
                if (txs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No transactions to export')),
                  );
                  return;
                }
                await ExportService.exportTransactionsToCsv(txs);
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search description, merchant, tag...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),

          // Horizontal Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                _buildFilterChip('Expenses', TransactionType.expense),
                const SizedBox(width: 8),
                _buildFilterChip('Income', TransactionType.income),
                const SizedBox(width: 8),
                _buildFilterChip('Transfers', TransactionType.transfer),
                const SizedBox(width: 8),
                _buildFilterChip('Deductions', TransactionType.salaryDeduction),
                const SizedBox(width: 8),
                _buildFilterChip('Savings', TransactionType.savingsContribution),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                var list = transactions.where((tx) {
                  if (_selectedTypeFilter != null && tx.type != _selectedTypeFilter) {
                    return false;
                  }
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    final matchDesc = tx.description.toLowerCase().contains(q);
                    final matchCat = tx.categoryName.toLowerCase().contains(q);
                    final matchMerchant = (tx.merchant ?? '').toLowerCase().contains(q);
                    final matchTags = tx.tags.any((t) => t.toLowerCase().contains(q));
                    return matchDesc || matchCat || matchMerchant || matchTags;
                  }
                  return true;
                }).toList();

                // Sort
                if (_sortBy == 'date_desc') {
                  list.sort((a, b) => b.date.compareTo(a.date));
                } else if (_sortBy == 'date_asc') {
                  list.sort((a, b) => a.date.compareTo(b.date));
                } else if (_sortBy == 'amount_desc') {
                  list.sort((a, b) => b.amount.compareTo(a.amount));
                } else if (_sortBy == 'amount_asc') {
                  list.sort((a, b) => a.amount.compareTo(b.amount));
                }

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: 12),
                        const Text('No transactions found'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: list.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemBuilder: (context, index) {
                    final tx = list[index];
                    return _buildTransactionItem(context, tx, isDark);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionType? type) {
    final isSelected = _selectedTypeFilter == type;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        setState(() => _selectedTypeFilter = selected ? type : null);
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel tx, bool isDark) {
    Color typeColor;
    IconData typeIcon;
    bool isNegative = false;

    switch (tx.type) {
      case TransactionType.income:
        typeColor = AppColors.income;
        typeIcon = Icons.arrow_downward;
        isNegative = false;
        break;
      case TransactionType.expense:
        typeColor = AppColors.expense;
        typeIcon = Icons.arrow_upward;
        isNegative = true;
        break;
      case TransactionType.salaryDeduction:
        typeColor = AppColors.deduction;
        typeIcon = Icons.receipt_long;
        isNegative = true;
        break;
      case TransactionType.transfer:
        typeColor = AppColors.transfer;
        typeIcon = Icons.swap_horiz;
        isNegative = false;
        break;
      case TransactionType.refund:
        typeColor = AppColors.refund;
        typeIcon = Icons.replay;
        isNegative = false;
        break;
      case TransactionType.savingsContribution:
        typeColor = AppColors.savings;
        typeIcon = Icons.savings;
        isNegative = true;
        break;
      case TransactionType.savingsWithdrawal:
        typeColor = AppColors.income;
        typeIcon = Icons.move_to_inbox;
        isNegative = false;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => TransactionDetailDialog(transaction: tx),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(typeIcon, color: typeColor, size: 20),
        ),
        title: Text(
          tx.description.isNotEmpty ? tx.description : tx.categoryName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${DateCycleHelper.formatShortDate(tx.date)} • ${tx.categoryName}',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        trailing: Text(
          '${isNegative ? '-' : '+'}${CurrencyFormat.format(tx.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: typeColor,
          ),
        ),
      ),
    );
  }
}

