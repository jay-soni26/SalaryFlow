import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import 'schema.dart';
import 'sample_data.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction_model.dart';
import '../../models/salary_config.dart';
import '../../models/salary_period.dart';
import '../../models/budget.dart';
import '../../models/savings_goal.dart';
import '../../models/recurring_transaction.dart';
import '../utils/date_cycle_helper.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(DatabaseSchema.createAccountsTable);
    await db.execute(DatabaseSchema.createCategoriesTable);
    await db.execute(DatabaseSchema.createSalaryConfigTable);
    await db.execute(DatabaseSchema.createSalaryPeriodsTable);
    await db.execute(DatabaseSchema.createTransactionsTable);
    await db.execute(DatabaseSchema.createBudgetsTable);
    await db.execute(DatabaseSchema.createSavingsGoalsTable);
    await db.execute(DatabaseSchema.createRecurringTable);

    for (final indexSql in DatabaseSchema.createIndices) {
      await db.execute(indexSql);
    }

    // Seed default categories
    for (final cat in SampleData.defaultCategories) {
      await db.insert(DatabaseSchema.tableCategories, cat.toMap());
    }

    // Seed default accounts
    for (final acc in SampleData.defaultAccounts) {
      await db.insert(DatabaseSchema.tableAccounts, acc.toMap());
    }

    // Seed default salary config
    const defaultConfig = SalaryConfig(
      defaultSalaryAmount: 85000.0,
      defaultIncomeSource: 'Primary Employer',
      defaultSalaryDay: 1,
      defaultSalaryAccountId: 'acc_hdfc_salary',
      defaultPfDeduction: 4500.0,
      defaultTaxDeduction: 8000.0,
      defaultInsuranceDeduction: 1500.0,
    );
    await db.insert(DatabaseSchema.tableSalaryConfig, {'id': 1, ...defaultConfig.toMap()});
  }

  // ===================== ACCOUNTS =====================
  Future<List<Account>> getAllAccounts() async {
    final db = await database;
    final res = await db.query(DatabaseSchema.tableAccounts, orderBy: 'name ASC');
    return res.map((m) => Account.fromMap(m)).toList();
  }

  Future<Account?> getAccountById(String id) async {
    final db = await database;
    final res = await db.query(
      DatabaseSchema.tableAccounts,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (res.isNotEmpty) return Account.fromMap(res.first);
    return null;
  }

  Future<void> insertAccount(Account account) async {
    final db = await database;
    await db.insert(DatabaseSchema.tableAccounts, account.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateAccount(Account account) async {
    final db = await database;
    await db.update(
      DatabaseSchema.tableAccounts,
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<void> deleteAccount(String id) async {
    final db = await database;
    await db.delete(
      DatabaseSchema.tableAccounts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===================== CATEGORIES =====================
  Future<List<TransactionCategory>> getAllCategories() async {
    final db = await database;
    final res = await db.query(DatabaseSchema.tableCategories, orderBy: 'name ASC');
    return res.map((m) => TransactionCategory.fromMap(m)).toList();
  }

  Future<void> insertCategory(TransactionCategory category) async {
    final db = await database;
    await db.insert(DatabaseSchema.tableCategories, category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ===================== SALARY CONFIG =====================
  Future<SalaryConfig> getSalaryConfig() async {
    final db = await database;
    final res = await db.query(DatabaseSchema.tableSalaryConfig, where: 'id = 1');
    if (res.isNotEmpty) {
      return SalaryConfig.fromMap(res.first);
    }
    return const SalaryConfig();
  }

  Future<void> updateSalaryConfig(SalaryConfig config) async {
    final db = await database;
    await db.insert(
      DatabaseSchema.tableSalaryConfig,
      {'id': 1, ...config.toMap()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ===================== SALARY PERIODS =====================
  Future<SalaryPeriod> getOrCreateSalaryPeriod(int year, int month) async {
    final db = await database;
    final periodId = '$year-${month.toString().padLeft(2, '0')}';
    final res = await db.query(
      DatabaseSchema.tableSalaryPeriods,
      where: 'id = ?',
      whereArgs: [periodId],
    );

    if (res.isNotEmpty) {
      return SalaryPeriod.fromMap(res.first);
    }

    // Auto-create period dates (start/end) without forcing phantom salary on past/future months
    final config = await getSalaryConfig();
    final dates = DateCycleHelper.getDefaultPeriodDates(
      year: year,
      month: month,
      preferredSalaryDay: config.defaultSalaryDay,
    );
    final creditDate = DateCycleHelper.getSalaryCreditDate(
      year,
      month,
      config.defaultSalaryDay,
    );

    // Check if an existing salary transaction already exists for this period
    final txRes = await db.query(
      DatabaseSchema.tableTransactions,
      where: 'salary_period_id = ? AND category_id = ?',
      whereArgs: [periodId, 'cat_salary'],
    );

    double initialNetSalary = 0.0;
    String? accountId = config.defaultSalaryAccountId;
    if (txRes.isNotEmpty) {
      initialNetSalary = (txRes.first['amount'] as num).toDouble();
      accountId = txRes.first['account_id'] as String?;
    }

    final newPeriod = SalaryPeriod(
      id: periodId,
      year: year,
      month: month,
      creditDate: creditDate,
      startDate: dates.startDate,
      endDate: dates.endDate,
      grossSalary: initialNetSalary,
      deductions: 0.0,
      netSalary: initialNetSalary,
      salaryAccountId: accountId,
      isCustomized: false,
    );

    await db.insert(DatabaseSchema.tableSalaryPeriods, newPeriod.toMap());
    return newPeriod;
  }

  Future<void> updateSalaryPeriod(SalaryPeriod period) async {
    final db = await database;
    await db.update(
      DatabaseSchema.tableSalaryPeriods,
      period.toMap(),
      where: 'id = ?',
      whereArgs: [period.id],
    );
  }

  Future<void> creditSalaryForPeriod({
    required int year,
    required int month,
    required double netSalary,
    required String accountId,
    required DateTime creditDate,
    String? notes,
  }) async {
    final periodId = '$year-${month.toString().padLeft(2, '0')}';
    final db = await database;

    // Check if a salary transaction already exists for this period
    final existingTxRes = await db.query(
      DatabaseSchema.tableTransactions,
      where: 'salary_period_id = ? AND category_id = ?',
      whereArgs: [periodId, 'cat_salary'],
    );

    if (existingTxRes.isNotEmpty) {
      final oldTx = TransactionModel.fromMap(existingTxRes.first);
      final newTx = oldTx.copyWith(
        amount: netSalary,
        accountId: accountId,
        date: creditDate,
        description: 'Monthly Salary Credit',
      );
      await updateTransaction(oldTx, newTx);
    } else {
      final tx = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: netSalary,
        date: creditDate,
        type: TransactionType.income,
        categoryId: 'cat_salary',
        categoryName: 'Salary Credit',
        accountId: accountId,
        description: 'Monthly Salary Credit',
        salaryPeriodId: periodId,
        paymentApp: 'bank_transfer',
      );
      await addTransaction(tx);
    }

    final period = await getOrCreateSalaryPeriod(year, month);
    final updatedPeriod = period.copyWith(
      creditDate: creditDate,
      grossSalary: netSalary,
      deductions: 0.0,
      netSalary: netSalary,
      salaryAccountId: accountId,
      isCustomized: true,
      notes: notes,
    );
    await updateSalaryPeriod(updatedPeriod);
  }

  Future<List<SalaryPeriod>> getAllSalaryPeriods() async {
    final db = await database;
    final res = await db.query(
      DatabaseSchema.tableSalaryPeriods,
      orderBy: 'year DESC, month DESC',
    );
    return res.map((m) => SalaryPeriod.fromMap(m)).toList();
  }

  // ===================== TRANSACTIONS =====================
  /// Adds a transaction using atomic database transactions and updates account balances.
  Future<void> addTransaction(TransactionModel tx) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(DatabaseSchema.tableTransactions, tx.toMap());

      // Update source account balance
      final sourceRes = await txn.query(
        DatabaseSchema.tableAccounts,
        where: 'id = ?',
        whereArgs: [tx.accountId],
      );

      if (sourceRes.isNotEmpty) {
        final currentBal = (sourceRes.first['current_balance'] as num).toDouble();
        double newBal = currentBal;

        switch (tx.type) {
          case TransactionType.income:
          case TransactionType.refund:
          case TransactionType.savingsWithdrawal:
            newBal += tx.amount;
            break;
          case TransactionType.expense:
          case TransactionType.salaryDeduction:
          case TransactionType.savingsContribution:
            newBal -= tx.amount;
            break;
          case TransactionType.transfer:
            newBal -= tx.amount;
            break;
        }

        await txn.update(
          DatabaseSchema.tableAccounts,
          {'current_balance': newBal},
          where: 'id = ?',
          whereArgs: [tx.accountId],
        );
      }

      // If transfer, update destination account balance
      if (tx.type == TransactionType.transfer && tx.destinationAccountId != null) {
        final destRes = await txn.query(
          DatabaseSchema.tableAccounts,
          where: 'id = ?',
          whereArgs: [tx.destinationAccountId],
        );
        if (destRes.isNotEmpty) {
          final destBal = (destRes.first['current_balance'] as num).toDouble();
          await txn.update(
            DatabaseSchema.tableAccounts,
            {'current_balance': destBal + tx.amount},
            where: 'id = ?',
            whereArgs: [tx.destinationAccountId],
          );
        }
      }
    });
  }

  /// Deletes a transaction and safely rolls back the account balances
  Future<void> deleteTransaction(TransactionModel tx) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        DatabaseSchema.tableTransactions,
        where: 'id = ?',
        whereArgs: [tx.id],
      );

      // Revert source account
      final sourceRes = await txn.query(
        DatabaseSchema.tableAccounts,
        where: 'id = ?',
        whereArgs: [tx.accountId],
      );

      if (sourceRes.isNotEmpty) {
        final currentBal = (sourceRes.first['current_balance'] as num).toDouble();
        double revertedBal = currentBal;

        switch (tx.type) {
          case TransactionType.income:
          case TransactionType.refund:
          case TransactionType.savingsWithdrawal:
            revertedBal -= tx.amount;
            break;
          case TransactionType.expense:
          case TransactionType.salaryDeduction:
          case TransactionType.savingsContribution:
          case TransactionType.transfer:
            revertedBal += tx.amount;
            break;
        }

        await txn.update(
          DatabaseSchema.tableAccounts,
          {'current_balance': revertedBal},
          where: 'id = ?',
          whereArgs: [tx.accountId],
        );
      }

      // Revert destination account if transfer
      if (tx.type == TransactionType.transfer && tx.destinationAccountId != null) {
        final destRes = await txn.query(
          DatabaseSchema.tableAccounts,
          where: 'id = ?',
          whereArgs: [tx.destinationAccountId],
        );
        if (destRes.isNotEmpty) {
          final destBal = (destRes.first['current_balance'] as num).toDouble();
          await txn.update(
            DatabaseSchema.tableAccounts,
            {'current_balance': destBal - tx.amount},
            where: 'id = ?',
            whereArgs: [tx.destinationAccountId],
          );
        }
      }
    });
  }

  /// Updates a transaction by reverting old balances and applying new balances
  Future<void> updateTransaction(TransactionModel oldTx, TransactionModel newTx) async {
    await deleteTransaction(oldTx);
    await addTransaction(newTx);
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final res = await db.query(DatabaseSchema.tableTransactions, orderBy: 'date DESC, created_at DESC');
    return res.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getTransactionsForPeriod(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final res = await db.query(
      DatabaseSchema.tableTransactions,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    return res.map((m) => TransactionModel.fromMap(m)).toList();
  }

  // ===================== BUDGETS =====================
  Future<List<Budget>> getAllBudgets() async {
    final db = await database;
    final res = await db.query(DatabaseSchema.tableBudgets);
    return res.map((m) => Budget.fromMap(m)).toList();
  }

  Future<void> saveBudget(Budget budget) async {
    final db = await database;
    await db.insert(DatabaseSchema.tableBudgets, budget.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete(DatabaseSchema.tableBudgets, where: 'id = ?', whereArgs: [id]);
  }

  // ===================== SAVINGS GOALS =====================
  Future<List<SavingsGoal>> getAllSavingsGoals() async {
    final db = await database;
    final res = await db.query(DatabaseSchema.tableSavingsGoals);
    return res.map((m) => SavingsGoal.fromMap(m)).toList();
  }

  Future<void> saveSavingsGoal(SavingsGoal goal) async {
    final db = await database;
    await db.insert(DatabaseSchema.tableSavingsGoals, goal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteSavingsGoal(String id) async {
    final db = await database;
    await db.delete(DatabaseSchema.tableSavingsGoals, where: 'id = ?', whereArgs: [id]);
  }

  // ===================== RECURRING =====================
  Future<List<RecurringTransaction>> getAllRecurring() async {
    final db = await database;
    final res = await db.query(DatabaseSchema.tableRecurring);
    return res.map((m) => RecurringTransaction.fromMap(m)).toList();
  }

  Future<void> saveRecurring(RecurringTransaction rec) async {
    final db = await database;
    await db.insert(DatabaseSchema.tableRecurring, rec.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteRecurring(String id) async {
    final db = await database;
    await db.delete(DatabaseSchema.tableRecurring, where: 'id = ?', whereArgs: [id]);
  }

  // ===================== DEMO DATA SEEDER =====================
  Future<void> seedDemoData() async {
    final db = await database;
    final now = DateTime.now();

    // Clear old transactions, budgets, goals, recurring
    await db.delete(DatabaseSchema.tableTransactions);
    await db.delete(DatabaseSchema.tableBudgets);
    await db.delete(DatabaseSchema.tableSavingsGoals);
    await db.delete(DatabaseSchema.tableRecurring);

    // Reset account balances
    for (final acc in SampleData.defaultAccounts) {
      await db.insert(
        DatabaseSchema.tableAccounts,
        acc.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Insert Demo transactions
    final demoTxs = SampleData.generateDemoTransactions(now);
    for (final tx in demoTxs) {
      await addTransaction(tx);
    }

    // Insert Budgets
    for (final b in SampleData.defaultBudgets) {
      await db.insert(DatabaseSchema.tableBudgets, b.toMap());
    }

    // Insert Goals
    for (final g in SampleData.defaultSavingsGoals) {
      await db.insert(DatabaseSchema.tableSavingsGoals, g.toMap());
    }

    // Insert Recurring
    for (final r in SampleData.defaultRecurring) {
      await db.insert(DatabaseSchema.tableRecurring, r.toMap());
    }
  }

  // ===================== CLEAR ALL DATA =====================
  Future<void> resetAllData() async {
    final db = await database;
    await db.delete(DatabaseSchema.tableTransactions);
    await db.delete(DatabaseSchema.tableSalaryPeriods);
    await db.delete(DatabaseSchema.tableBudgets);
    await db.delete(DatabaseSchema.tableSavingsGoals);
    await db.delete(DatabaseSchema.tableRecurring);
  }
}

