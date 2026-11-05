enum TransactionType {
  income,
  expense,
  salaryDeduction,
  transfer,
  refund,
  savingsContribution,
  savingsWithdrawal,
}

class TransactionModel {
  final String id;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final String? subcategory;
  final String accountId;
  final String? destinationAccountId;
  final String description;
  final String? merchant;
  final List<String> tags;
  final String? recurringId;
  final String? salaryPeriodId;
  final String? externalReference;
  final String? paymentApp; // e.g. 'gpay', 'phonepe', 'bank_transfer', 'cash'
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    this.subcategory,
    required this.accountId,
    this.destinationAccountId,
    this.description = '',
    this.merchant,
    this.tags = const [],
    this.recurringId,
    this.salaryPeriodId,
    this.externalReference,
    this.paymentApp,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TransactionModel copyWith({
    String? id,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? categoryId,
    String? categoryName,
    String? subcategory,
    String? accountId,
    String? destinationAccountId,
    String? description,
    String? merchant,
    List<String>? tags,
    String? recurringId,
    String? salaryPeriodId,
    String? externalReference,
    String? paymentApp,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subcategory: subcategory ?? this.subcategory,
      accountId: accountId ?? this.accountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      tags: tags ?? this.tags,
      recurringId: recurringId ?? this.recurringId,
      salaryPeriodId: salaryPeriodId ?? this.salaryPeriodId,
      externalReference: externalReference ?? this.externalReference,
      paymentApp: paymentApp ?? this.paymentApp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name,
      'category_id': categoryId,
      'category_name': categoryName,
      'subcategory': subcategory,
      'account_id': accountId,
      'destination_account_id': destinationAccountId,
      'description': description,
      'merchant': merchant,
      'tags': tags.join(','),
      'recurring_id': recurringId,
      'salary_period_id': salaryPeriodId,
      'external_reference': externalReference,
      'payment_app': paymentApp,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final tagsRaw = map['tags'] as String?;
    final tagList = (tagsRaw != null && tagsRaw.isNotEmpty)
        ? tagsRaw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    return TransactionModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      categoryId: map['category_id'] as String,
      categoryName: map['category_name'] as String,
      subcategory: map['subcategory'] as String?,
      accountId: map['account_id'] as String,
      destinationAccountId: map['destination_account_id'] as String?,
      description: map['description'] as String? ?? '',
      merchant: map['merchant'] as String?,
      tags: tagList,
      recurringId: map['recurring_id'] as String?,
      salaryPeriodId: map['salary_period_id'] as String?,
      externalReference: map['external_reference'] as String?,
      paymentApp: map['payment_app'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String get typeDisplayName {
    switch (type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.salaryDeduction:
        return 'Salary Deduction';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.savingsContribution:
        return 'Savings Deposit';
      case TransactionType.savingsWithdrawal:
        return 'Savings Withdrawal';
    }
  }
}

