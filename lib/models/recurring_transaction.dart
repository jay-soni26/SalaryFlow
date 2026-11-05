import 'transaction_model.dart';

enum RecurringFrequency {
  monthly,
  weekly,
  yearly,
}

class RecurringTransaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final String accountId;
  final RecurringFrequency frequency;
  final int dueDay; // e.g. 5th of each month
  final DateTime nextDueDate;
  final bool isActive;
  final List<String> skippedOccurrences; // ISO dates like '2026-11-05'

  RecurringTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.accountId,
    this.frequency = RecurringFrequency.monthly,
    required this.dueDay,
    required this.nextDueDate,
    this.isActive = true,
    this.skippedOccurrences = const [],
  });

  bool isSkipped(DateTime date) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return skippedOccurrences.contains(dateKey);
  }

  RecurringTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? categoryName,
    String? accountId,
    RecurringFrequency? frequency,
    int? dueDay,
    DateTime? nextDueDate,
    bool? isActive,
    List<String>? skippedOccurrences,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      accountId: accountId ?? this.accountId,
      frequency: frequency ?? this.frequency,
      dueDay: dueDay ?? this.dueDay,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      skippedOccurrences: skippedOccurrences ?? this.skippedOccurrences,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category_id': categoryId,
      'category_name': categoryName,
      'account_id': accountId,
      'frequency': frequency.name,
      'due_day': dueDay,
      'next_due_date': nextDueDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'skipped_occurrences': skippedOccurrences.join(','),
    };
  }

  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    final skippedRaw = map['skipped_occurrences'] as String?;
    final skippedList = (skippedRaw != null && skippedRaw.isNotEmpty)
        ? skippedRaw.split(',').where((e) => e.isNotEmpty).toList()
        : <String>[];

    return RecurringTransaction(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      categoryId: map['category_id'] as String,
      categoryName: map['category_name'] as String,
      accountId: map['account_id'] as String,
      frequency: RecurringFrequency.values.firstWhere(
        (e) => e.name == map['frequency'],
        orElse: () => RecurringFrequency.monthly,
      ),
      dueDay: map['due_day'] as int,
      nextDueDate: DateTime.parse(map['next_due_date'] as String),
      isActive: (map['is_active'] as int) == 1,
      skippedOccurrences: skippedList,
    );
  }
}

