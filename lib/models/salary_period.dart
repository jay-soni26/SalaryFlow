class SalaryPeriod {
  final String id; // Format: 'YYYY-MM'
  final int year;
  final int month;
  final DateTime creditDate;
  final DateTime startDate;
  final DateTime endDate;
  final double grossSalary;
  final double deductions;
  final double netSalary;
  final double carryForwardBalance;
  final bool isCustomized;
  final String? salaryAccountId;
  final String? notes;

  SalaryPeriod({
    required this.id,
    required this.year,
    required this.month,
    required this.creditDate,
    required this.startDate,
    required this.endDate,
    required this.grossSalary,
    required this.deductions,
    required this.netSalary,
    this.carryForwardBalance = 0.0,
    this.isCustomized = false,
    this.salaryAccountId,
    this.notes,
  });

  SalaryPeriod copyWith({
    String? id,
    int? year,
    int? month,
    DateTime? creditDate,
    DateTime? startDate,
    DateTime? endDate,
    double? grossSalary,
    double? deductions,
    double? netSalary,
    double? carryForwardBalance,
    bool? isCustomized,
    String? salaryAccountId,
    String? notes,
  }) {
    return SalaryPeriod(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      creditDate: creditDate ?? this.creditDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      grossSalary: grossSalary ?? this.grossSalary,
      deductions: deductions ?? this.deductions,
      netSalary: netSalary ?? this.netSalary,
      carryForwardBalance: carryForwardBalance ?? this.carryForwardBalance,
      isCustomized: isCustomized ?? this.isCustomized,
      salaryAccountId: salaryAccountId ?? this.salaryAccountId,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'credit_date': creditDate.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'gross_salary': grossSalary,
      'deductions': deductions,
      'net_salary': netSalary,
      'carry_forward_balance': carryForwardBalance,
      'is_customized': isCustomized ? 1 : 0,
      'salary_account_id': salaryAccountId,
      'notes': notes,
    };
  }

  factory SalaryPeriod.fromMap(Map<String, dynamic> map) {
    return SalaryPeriod(
      id: map['id'] as String,
      year: map['year'] as int,
      month: map['month'] as int,
      creditDate: DateTime.parse(map['credit_date'] as String),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      grossSalary: (map['gross_salary'] as num).toDouble(),
      deductions: (map['deductions'] as num).toDouble(),
      netSalary: (map['net_salary'] as num).toDouble(),
      carryForwardBalance: (map['carry_forward_balance'] as num?)?.toDouble() ?? 0.0,
      isCustomized: (map['is_customized'] as int) == 1,
      salaryAccountId: map['salary_account_id'] as String?,
      notes: map['notes'] as String?,
    );
  }
}

