import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/currency_format.dart';
import '../../../core/utils/date_cycle_helper.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/transactions_provider.dart';
import 'add_edit_transaction_screen.dart';

class TransactionDetailDialog extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionDetailDialog({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            transaction.typeDisplayName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    CurrencyFormat.format(transaction.amount),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateCycleHelper.formatShortDate(transaction.date),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            _buildDetailRow('Category', transaction.categoryName),
            if (transaction.subcategory != null)
              _buildDetailRow('Subcategory', transaction.subcategory!),
            if (transaction.merchant != null)
              _buildDetailRow('Merchant / Payee', transaction.merchant!),
            if (transaction.description.isNotEmpty)
              _buildDetailRow('Description', transaction.description),
            if (transaction.tags.isNotEmpty)
              _buildDetailRow('Tags', transaction.tags.join(', ')),
            if (transaction.paymentApp != null)
              _buildDetailRow('Payment App', transaction.paymentApp!.toUpperCase()),
          ],
        ),
      ),
      actions: [
        // Duplicate
        IconButton(
          icon: const Icon(Icons.copy, size: 20),
          tooltip: 'Duplicate Transaction',
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditTransactionScreen(
                  existingTransaction: null,
                  initialType: transaction.type,
                ),
              ),
            );
          },
        ),
        // Edit
        IconButton(
          icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
          tooltip: 'Edit',
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditTransactionScreen(
                  existingTransaction: transaction,
                ),
              ),
            );
          },
        ),
        // Delete
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.expense),
          tooltip: 'Delete',
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Transaction?'),
                content: const Text(
                  'This will permanently delete this record and revert the account balances.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await ref.read(allTransactionsProvider.notifier).deleteTransaction(transaction);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction deleted')),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

