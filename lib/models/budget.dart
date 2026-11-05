class Budget {
  final String id;
  final String categoryId;
  final String categoryName;
  final double limitAmount;
  final String? salaryPeriodId; // If null, applies as default monthly budget

  Budget({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.limitAmount,
    this.salaryPeriodId,
  });

  Budget copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    double? limitAmount,
    String? salaryPeriodId,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      limitAmount: limitAmount ?? this.limitAmount,
      salaryPeriodId: salaryPeriodId ?? this.salaryPeriodId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'category_name': categoryName,
      'limit_amount': limitAmount,
      'salary_period_id': salaryPeriodId,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      categoryName: map['category_name'] as String,
      limitAmount: (map['limit_amount'] as num).toDouble(),
      salaryPeriodId: map['salary_period_id'] as String?,
    );
  }
}

