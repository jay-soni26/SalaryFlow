enum AccountType {
  salaryBank,
  savingsBank,
  cashWallet,
  otherBank,
}

class Account {
  final String id;
  final String name;
  final AccountType type;
  final double openingBalance;
  final double currentBalance;
  final bool isSalaryDefault;
  final bool isSavingsDefault;

  Account({
    required this.id,
    required this.name,
    required this.type,
    this.openingBalance = 0.0,
    this.currentBalance = 0.0,
    this.isSalaryDefault = false,
    this.isSavingsDefault = false,
  });

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? openingBalance,
    double? currentBalance,
    bool? isSalaryDefault,
    bool? isSavingsDefault,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isSalaryDefault: isSalaryDefault ?? this.isSalaryDefault,
      isSavingsDefault: isSavingsDefault ?? this.isSavingsDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'opening_balance': openingBalance,
      'current_balance': currentBalance,
      'is_salary_default': isSalaryDefault ? 1 : 0,
      'is_savings_default': isSavingsDefault ? 1 : 0,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as String,
      name: map['name'] as String,
      type: AccountType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AccountType.salaryBank,
      ),
      openingBalance: (map['opening_balance'] as num).toDouble(),
      currentBalance: (map['current_balance'] as num).toDouble(),
      isSalaryDefault: (map['is_salary_default'] as int) == 1,
      isSavingsDefault: (map['is_savings_default'] as int) == 1,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case AccountType.salaryBank:
        return 'Salary Bank Account';
      case AccountType.savingsBank:
        return 'Savings Account';
      case AccountType.cashWallet:
        return 'Cash Wallet';
      case AccountType.otherBank:
        return 'Other Account';
    }
  }
}

