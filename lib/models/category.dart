class TransactionCategory {
  final String id;
  final String name;
  final String icon;
  final int colorValue;
  final bool isExpense;
  final bool isIncome;
  final bool isDeduction;

  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    this.isExpense = true,
    this.isIncome = false,
    this.isDeduction = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color_value': colorValue,
      'is_expense': isExpense ? 1 : 0,
      'is_income': isIncome ? 1 : 0,
      'is_deduction': isDeduction ? 1 : 0,
    };
  }

  factory TransactionCategory.fromMap(Map<String, dynamic> map) {
    return TransactionCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      colorValue: map['color_value'] as int,
      isExpense: (map['is_expense'] as int) == 1,
      isIncome: (map['is_income'] as int) == 1,
      isDeduction: (map['is_deduction'] as int) == 1,
    );
  }
}

