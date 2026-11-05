import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/transaction_model.dart';
import 'date_cycle_helper.dart';

class ExportService {
  /// Converts transactions into CSV format and shares/exports the file
  static Future<String> exportTransactionsToCsv(List<TransactionModel> transactions) async {
    final List<List<dynamic>> rows = [
      [
        'ID',
        'Date',
        'Type',
        'Category',
        'Subcategory',
        'Amount (INR)',
        'Account ID',
        'Destination Account ID',
        'Description',
        'Merchant',
        'Tags',
        'Payment App',
      ],
    ];

    for (final tx in transactions) {
      rows.add([
        tx.id,
        DateCycleHelper.formatShortDate(tx.date),
        tx.type.name,
        tx.categoryName,
        tx.subcategory ?? '',
        tx.amount,
        tx.accountId,
        tx.destinationAccountId ?? '',
        tx.description,
        tx.merchant ?? '',
        tx.tags.join('; '),
        tx.paymentApp ?? '',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/SalaryFlow_Transactions_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    await file.writeAsString(csvString);

    await Share.shareXFiles([XFile(path)], text: 'SalaryFlow Transactions Export');
    return path;
  }
}

