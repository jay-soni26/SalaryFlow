class SalaryConfig {
  final double defaultSalaryAmount;
  final String defaultIncomeSource;
  final int defaultSalaryDay;
  final String? defaultSalaryAccountId;
  final double defaultPfDeduction;
  final double defaultTaxDeduction;
  final double defaultInsuranceDeduction;

  const SalaryConfig({
    this.defaultSalaryAmount = 85000.0,
    this.defaultIncomeSource = 'Primary Employer',
    this.defaultSalaryDay = 1,
    this.defaultSalaryAccountId,
    this.defaultPfDeduction = 4500.0,
    this.defaultTaxDeduction = 8000.0,
    this.defaultInsuranceDeduction = 1500.0,
  });

  double get defaultTotalDeductions =>
      defaultPfDeduction + defaultTaxDeduction + defaultInsuranceDeduction;

  double get defaultNetSalary =>
      (defaultSalaryAmount - defaultTotalDeductions).clamp(0, double.infinity);

  SalaryConfig copyWith({
    double? defaultSalaryAmount,
    String? defaultIncomeSource,
    int? defaultSalaryDay,
    String? defaultSalaryAccountId,
    double? defaultPfDeduction,
    double? defaultTaxDeduction,
    double? defaultInsuranceDeduction,
  }) {
    return SalaryConfig(
      defaultSalaryAmount: defaultSalaryAmount ?? this.defaultSalaryAmount,
      defaultIncomeSource: defaultIncomeSource ?? this.defaultIncomeSource,
      defaultSalaryDay: defaultSalaryDay ?? this.defaultSalaryDay,
      defaultSalaryAccountId: defaultSalaryAccountId ?? this.defaultSalaryAccountId,
      defaultPfDeduction: defaultPfDeduction ?? this.defaultPfDeduction,
      defaultTaxDeduction: defaultTaxDeduction ?? this.defaultTaxDeduction,
      defaultInsuranceDeduction:
          defaultInsuranceDeduction ?? this.defaultInsuranceDeduction,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'default_salary_amount': defaultSalaryAmount,
      'default_income_source': defaultIncomeSource,
      'default_salary_day': defaultSalaryDay,
      'default_salary_account_id': defaultSalaryAccountId,
      'default_pf_deduction': defaultPfDeduction,
      'default_tax_deduction': defaultTaxDeduction,
      'default_insurance_deduction': defaultInsuranceDeduction,
    };
  }

  factory SalaryConfig.fromMap(Map<String, dynamic> map) {
    return SalaryConfig(
      defaultSalaryAmount: (map['default_salary_amount'] as num?)?.toDouble() ?? 85000.0,
      defaultIncomeSource: map['default_income_source'] as String? ?? 'Primary Employer',
      defaultSalaryDay: map['default_salary_day'] as int? ?? 1,
      defaultSalaryAccountId: map['default_salary_account_id'] as String?,
      defaultPfDeduction: (map['default_pf_deduction'] as num?)?.toDouble() ?? 4500.0,
      defaultTaxDeduction: (map['default_tax_deduction'] as num?)?.toDouble() ?? 8000.0,
      defaultInsuranceDeduction:
          (map['default_insurance_deduction'] as num?)?.toDouble() ?? 1500.0,
    );
  }
}

