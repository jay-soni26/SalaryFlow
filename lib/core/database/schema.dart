class DatabaseSchema {
  static const String tableAccounts = 'accounts';
  static const String tableCategories = 'categories';
  static const String tableTransactions = 'transactions';
  static const String tableSalaryPeriods = 'salary_periods';
  static const String tableSalaryConfig = 'salary_config';
  static const String tableBudgets = 'budgets';
  static const String tableSavingsGoals = 'savings_goals';
  static const String tableRecurring = 'recurring_transactions';

  static const String createAccountsTable = '''
    CREATE TABLE $tableAccounts (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      opening_balance REAL NOT NULL DEFAULT 0.0,
      current_balance REAL NOT NULL DEFAULT 0.0,
      is_salary_default INTEGER NOT NULL DEFAULT 0,
      is_savings_default INTEGER NOT NULL DEFAULT 0
    );
  ''';

  static const String createCategoriesTable = '''
    CREATE TABLE $tableCategories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      icon TEXT NOT NULL,
      color_value INTEGER NOT NULL,
      is_expense INTEGER NOT NULL DEFAULT 1,
      is_income INTEGER NOT NULL DEFAULT 0,
      is_deduction INTEGER NOT NULL DEFAULT 0
    );
  ''';

  static const String createSalaryConfigTable = '''
    CREATE TABLE $tableSalaryConfig (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      default_salary_amount REAL NOT NULL DEFAULT 85000.0,
      default_income_source TEXT NOT NULL DEFAULT 'Primary Employer',
      default_salary_day INTEGER NOT NULL DEFAULT 1,
      default_salary_account_id TEXT,
      default_pf_deduction REAL NOT NULL DEFAULT 4500.0,
      default_tax_deduction REAL NOT NULL DEFAULT 8000.0,
      default_insurance_deduction REAL NOT NULL DEFAULT 1500.0
    );
  ''';

  static const String createSalaryPeriodsTable = '''
    CREATE TABLE $tableSalaryPeriods (
      id TEXT PRIMARY KEY,
      year INTEGER NOT NULL,
      month INTEGER NOT NULL,
      credit_date TEXT NOT NULL,
      start_date TEXT NOT NULL,
      end_date TEXT NOT NULL,
      gross_salary REAL NOT NULL,
      deductions REAL NOT NULL,
      net_salary REAL NOT NULL,
      carry_forward_balance REAL NOT NULL DEFAULT 0.0,
      is_customized INTEGER NOT NULL DEFAULT 0,
      salary_account_id TEXT,
      notes TEXT
    );
  ''';

  static const String createTransactionsTable = '''
    CREATE TABLE $tableTransactions (
      id TEXT PRIMARY KEY,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      type TEXT NOT NULL,
      category_id TEXT NOT NULL,
      category_name TEXT NOT NULL,
      subcategory TEXT,
      account_id TEXT NOT NULL,
      destination_account_id TEXT,
      description TEXT,
      merchant TEXT,
      tags TEXT,
      recurring_id TEXT,
      salary_period_id TEXT,
      external_reference TEXT,
      payment_app TEXT,
      created_at TEXT NOT NULL
    );
  ''';

  static const String createBudgetsTable = '''
    CREATE TABLE $tableBudgets (
      id TEXT PRIMARY KEY,
      category_id TEXT NOT NULL,
      category_name TEXT NOT NULL,
      limit_amount REAL NOT NULL,
      salary_period_id TEXT
    );
  ''';

  static const String createSavingsGoalsTable = '''
    CREATE TABLE $tableSavingsGoals (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      target_amount REAL NOT NULL,
      current_amount REAL NOT NULL DEFAULT 0.0,
      target_date TEXT,
      color_value INTEGER NOT NULL,
      account_id TEXT,
      notes TEXT
    );
  ''';

  static const String createRecurringTable = '''
    CREATE TABLE $tableRecurring (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      type TEXT NOT NULL,
      category_id TEXT NOT NULL,
      category_name TEXT NOT NULL,
      account_id TEXT NOT NULL,
      frequency TEXT NOT NULL,
      due_day INTEGER NOT NULL,
      next_due_date TEXT NOT NULL,
      is_active INTEGER NOT NULL DEFAULT 1,
      skipped_occurrences TEXT
    );
  ''';

  // Indexes for high performance
  static const List<String> createIndices = [
    'CREATE INDEX idx_trans_date ON $tableTransactions (date);',
    'CREATE INDEX idx_trans_period ON $tableTransactions (salary_period_id);',
    'CREATE INDEX idx_trans_account ON $tableTransactions (account_id);',
    'CREATE INDEX idx_periods_year_month ON $tableSalaryPeriods (year, month);',
  ];
}

