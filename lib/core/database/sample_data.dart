import 'package:uuid/uuid.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction_model.dart';
import '../../models/budget.dart';
import '../../models/savings_goal.dart';
import '../../models/recurring_transaction.dart';

class SampleData {
  // Initial Default Categories
  static List<TransactionCategory> get defaultCategories => [
    // Income Categories
    const TransactionCategory(
      id: 'cat_salary',
      name: 'Salary Credit',
      icon: 'account_balance_wallet',
      colorValue: 0xFF10B981,
      isExpense: false,
      isIncome: true,
      isDeduction: false,
    ),
    const TransactionCategory(
      id: 'cat_freelance',
      name: 'Freelance & Bonus',
      icon: 'laptop_mac',
      colorValue: 0xFF0D9488,
      isExpense: false,
      isIncome: true,
      isDeduction: false,
    ),
    const TransactionCategory(
      id: 'cat_invest_return',
      name: 'Dividends & Returns',
      icon: 'trending_up',
      colorValue: 0xFF06B6D4,
      isExpense: false,
      isIncome: true,
      isDeduction: false,
    ),

    // Salary Deductions
    const TransactionCategory(
      id: 'cat_pf',
      name: 'Provident Fund (PF)',
      icon: 'security',
      colorValue: 0xFFF97316,
      isExpense: false,
      isIncome: false,
      isDeduction: true,
    ),
    const TransactionCategory(
      id: 'cat_tax',
      name: 'Income Tax (TDS)',
      icon: 'receipt_long',
      colorValue: 0xFFEF4444,
      isExpense: false,
      isIncome: false,
      isDeduction: true,
    ),
    const TransactionCategory(
      id: 'cat_insurance',
      name: 'Health Insurance',
      icon: 'health_and_safety',
      colorValue: 0xFF8B5CF6,
      isExpense: false,
      isIncome: false,
      isDeduction: true,
    ),

    // Expenses
    const TransactionCategory(
      id: 'cat_rent',
      name: 'Rent & Housing',
      icon: 'home',
      colorValue: 0xFF6366F1,
      isExpense: true,
      isIncome: false,
      isDeduction: false,
    ),
    const TransactionCategory(
      id: 'cat_groceries',
      name: 'Groceries & Household',
      icon: 'shopping_basket',
      colorValue: 0xFF10B981,
      isExpense: true,
      isIncome: false,
      isDeduction: false,
    ),
    const TransactionCategory(
      id: 'cat_dining',
      name: 'Food & Dining',
      icon: 'restaurant',
      colorValue: 0xFFF59E0B,
      isExpense: true,
      isIncome: false,
      isDeduction: false,
    ),
    const TransactionCategory(
      id: 'cat_utilities',
      name: 'Bills & Utilities',
      icon: 'bolt',
      colorValue: 0xFF3B82F6,
      isExpense: true,
      isIncome: false,
      isDeduction: false,
    ),
    const TransactionCategory(
      id: 'cat_commute',
      name: 'Transport & Fuel',
      icon: 'directions_car',
      colorValue: 0xFF64748B,
      isExpense: true,
      isIncome: false,
      isDeduction: false,
    ),
    const TransactionCategory(
      id: 'cat_sip',
      name: 'Mutual Funds / SIP',
      icon: 'savings',
      colorValue: 0xFF8B5CF6,
      isExpense: true,
      isIncome: false,
      isDeduction: false,
    ),
    const TransactionCategory(
      id: 'cat_shopping',
      name: 'Shopping & Lifestyle',
      icon: 'shopping_bag',
      colorValue: 0xFFEC4899,
      isExpense: true,
      isIncome: false,
      isDeduction: false,
    ),
  ];

  // Default Initial Accounts
  static List<Account> get defaultAccounts => [
    Account(
      id: 'acc_hdfc_salary',
      name: 'HDFC Salary Bank',
      type: AccountType.salaryBank,
      openingBalance: 42500.0,
      currentBalance: 42500.0,
      isSalaryDefault: true,
      isSavingsDefault: false,
    ),
    Account(
      id: 'acc_sbi_savings',
      name: 'SBI Wealth Savings',
      type: AccountType.savingsBank,
      openingBalance: 120000.0,
      currentBalance: 120000.0,
      isSalaryDefault: false,
      isSavingsDefault: true,
    ),
    Account(
      id: 'acc_cash_wallet',
      name: 'Cash Wallet',
      type: AccountType.cashWallet,
      openingBalance: 4500.0,
      currentBalance: 4500.0,
      isSalaryDefault: false,
      isSavingsDefault: false,
    ),
  ];

  // Demo Transactions for active month
  static List<TransactionModel> generateDemoTransactions(DateTime now) {
    final year = now.year;
    final month = now.month;

    return [
      // Salary Credit on 1st of current month
      TransactionModel(
        id: const Uuid().v4(),
        amount: 85000.0,
        date: DateTime(year, month, 1, 9, 30),
        type: TransactionType.income,
        categoryId: 'cat_salary',
        categoryName: 'Salary Credit',
        accountId: 'acc_hdfc_salary',
        description: 'Monthly Corporate Salary Credit',
        merchant: 'Employer Inc.',
        tags: ['salary', 'corporate'],
        paymentApp: 'bank_transfer',
      ),
      // Deductions
      TransactionModel(
        id: const Uuid().v4(),
        amount: 4500.0,
        date: DateTime(year, month, 1, 9, 30),
        type: TransactionType.salaryDeduction,
        categoryId: 'cat_pf',
        categoryName: 'Provident Fund (PF)',
        accountId: 'acc_hdfc_salary',
        description: 'Employee Provident Fund auto-debit',
        tags: ['pf', 'deduction'],
      ),
      TransactionModel(
        id: const Uuid().v4(),
        amount: 8000.0,
        date: DateTime(year, month, 1, 9, 30),
        type: TransactionType.salaryDeduction,
        categoryId: 'cat_tax',
        categoryName: 'Income Tax (TDS)',
        accountId: 'acc_hdfc_salary',
        description: 'Tax Deducted at Source (TDS)',
        tags: ['tax', 'tds'],
      ),
      // Transfer to Savings
      TransactionModel(
        id: const Uuid().v4(),
        amount: 20000.0,
        date: DateTime(year, month, 2, 11, 0),
        type: TransactionType.transfer,
        categoryId: 'cat_sip',
        categoryName: 'Savings Transfer',
        accountId: 'acc_hdfc_salary',
        destinationAccountId: 'acc_sbi_savings',
        description: 'Emergency Fund monthly allocation',
        tags: ['savings', 'transfer'],
        paymentApp: 'gpay',
      ),
      // Rent payment
      TransactionModel(
        id: const Uuid().v4(),
        amount: 22000.0,
        date: DateTime(year, month, 2, 14, 0),
        type: TransactionType.expense,
        categoryId: 'cat_rent',
        categoryName: 'Rent & Housing',
        accountId: 'acc_hdfc_salary',
        description: 'Apartment rent transfer',
        merchant: 'Landlord',
        tags: ['rent', 'fixed'],
        paymentApp: 'phonepe',
      ),
      // Groceries
      TransactionModel(
        id: const Uuid().v4(),
        amount: 3450.0,
        date: DateTime(year, month, 3, 17, 45),
        type: TransactionType.expense,
        categoryId: 'cat_groceries',
        categoryName: 'Groceries & Household',
        accountId: 'acc_hdfc_salary',
        description: 'Weekly organic groceries & supplies',
        merchant: 'Nature Basket',
        tags: ['groceries', 'food'],
        paymentApp: 'gpay',
      ),
      // Dining out
      TransactionModel(
        id: const Uuid().v4(),
        amount: 1850.0,
        date: DateTime(year, month, 4, 20, 15),
        type: TransactionType.expense,
        categoryId: 'cat_dining',
        categoryName: 'Food & Dining',
        accountId: 'acc_hdfc_salary',
        description: 'Dinner with colleagues',
        merchant: 'Spice Route',
        tags: ['dining', 'weekend'],
        paymentApp: 'phonepe',
      ),
      // Mutual Fund SIP
      TransactionModel(
        id: const Uuid().v4(),
        amount: 10000.0,
        date: DateTime(year, month, 5, 10, 0),
        type: TransactionType.expense,
        categoryId: 'cat_sip',
        categoryName: 'Mutual Funds / SIP',
        accountId: 'acc_hdfc_salary',
        description: 'Nifty 50 Index Fund SIP auto-debit',
        merchant: 'Groww AMC',
        tags: ['investing', 'sip'],
      ),
    ];
  }

  // Demo Budgets
  static List<Budget> get defaultBudgets => [
    Budget(
      id: 'bgt_rent',
      categoryId: 'cat_rent',
      categoryName: 'Rent & Housing',
      limitAmount: 25000.0,
    ),
    Budget(
      id: 'bgt_groceries',
      categoryId: 'cat_groceries',
      categoryName: 'Groceries & Household',
      limitAmount: 12000.0,
    ),
    Budget(
      id: 'bgt_dining',
      categoryId: 'cat_dining',
      categoryName: 'Food & Dining',
      limitAmount: 8000.0,
    ),
    Budget(
      id: 'bgt_shopping',
      categoryId: 'cat_shopping',
      categoryName: 'Shopping & Lifestyle',
      limitAmount: 10000.0,
    ),
  ];

  // Demo Savings Goals
  static List<SavingsGoal> get defaultSavingsGoals => [
    SavingsGoal(
      id: 'goal_emergency',
      name: '6-Month Emergency Fund',
      targetAmount: 300000.0,
      currentAmount: 120000.0,
      targetDate: DateTime.now().add(const Duration(days: 365)),
      colorValue: 0xFF10B981,
      accountId: 'acc_sbi_savings',
      notes: 'Shield for medical & career emergencies',
    ),
    SavingsGoal(
      id: 'goal_vacation',
      name: 'Japan Autumn Trip',
      targetAmount: 150000.0,
      currentAmount: 65000.0,
      targetDate: DateTime.now().add(const Duration(days: 180)),
      colorValue: 0xFF6366F1,
      notes: 'Flights and hotels savings',
    ),
  ];

  // Demo Recurring Transactions
  static List<RecurringTransaction> get defaultRecurring => [
    RecurringTransaction(
      id: 'rec_rent',
      title: 'Monthly Rent',
      amount: 22000.0,
      type: TransactionType.expense,
      categoryId: 'cat_rent',
      categoryName: 'Rent & Housing',
      accountId: 'acc_hdfc_salary',
      dueDay: 2,
      nextDueDate: DateTime.now().add(const Duration(days: 15)),
    ),
    RecurringTransaction(
      id: 'rec_sip',
      title: 'Mutual Fund SIP',
      amount: 10000.0,
      type: TransactionType.expense,
      categoryId: 'cat_sip',
      categoryName: 'Mutual Funds / SIP',
      accountId: 'acc_hdfc_salary',
      dueDay: 5,
      nextDueDate: DateTime.now().add(const Duration(days: 10)),
    ),
    RecurringTransaction(
      id: 'rec_wifi',
      title: 'Airtel Fiber Broadband',
      amount: 1180.0,
      type: TransactionType.expense,
      categoryId: 'cat_utilities',
      categoryName: 'Bills & Utilities',
      accountId: 'acc_hdfc_salary',
      dueDay: 12,
      nextDueDate: DateTime.now().add(const Duration(days: 7)),
    ),
  ];
}

