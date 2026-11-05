import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';
import '../models/transaction_model.dart';
import 'salary_cycle_provider.dart';
import 'accounts_provider.dart';

// Master transactions list
final allTransactionsProvider =
    StateNotifierProvider<TransactionsNotifier, AsyncValue<List<TransactionModel>>>((ref) {
  return TransactionsNotifier(ref);
});

class TransactionsNotifier extends StateNotifier<AsyncValue<List<TransactionModel>>> {
  final Ref ref;

  TransactionsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      final txs = await AppDatabase.instance.getAllTransactions();
      state = AsyncValue.data(txs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTransaction(TransactionModel tx) async {
    await AppDatabase.instance.addTransaction(tx);
    await loadTransactions();
    ref.read(accountsProvider.notifier).loadAccounts();
  }

  Future<void> updateTransaction(TransactionModel oldTx, TransactionModel newTx) async {
    await AppDatabase.instance.updateTransaction(oldTx, newTx);
    await loadTransactions();
    ref.read(accountsProvider.notifier).loadAccounts();
  }

  Future<void> deleteTransaction(TransactionModel tx) async {
    await AppDatabase.instance.deleteTransaction(tx);
    await loadTransactions();
    ref.read(accountsProvider.notifier).loadAccounts();
  }
}

// Financial summary for active salary cycle period
class PeriodFinancialSummary {
  final double grossSalary;
  final double netSalary;
  final double otherIncome;
  final double totalIncome;
  final double totalExpenses;
  final double totalDeductions;
  final double savingsDeposits;
  final double savingsWithdrawals;
  final double availableSpendingBalance;
  final double savingsRate;
  final double carryForward;
  final int transactionCount;

  PeriodFinancialSummary({
    required this.grossSalary,
    required this.netSalary,
    required this.otherIncome,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalDeductions,
    required this.savingsDeposits,
    required this.savingsWithdrawals,
    required this.availableSpendingBalance,
    required this.savingsRate,
    required this.carryForward,
    required this.transactionCount,
  });

  factory PeriodFinancialSummary.empty() {
    return PeriodFinancialSummary(
      grossSalary: 0,
      netSalary: 0,
      otherIncome: 0,
      totalIncome: 0,
      totalExpenses: 0,
      totalDeductions: 0,
      savingsDeposits: 0,
      savingsWithdrawals: 0,
      availableSpendingBalance: 0,
      savingsRate: 0,
      carryForward: 0,
      transactionCount: 0,
    );
  }
}

// Provider for transactions within active period
final periodTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final allTxAsync = ref.watch(allTransactionsProvider);
  final activePeriodAsync = ref.watch(activeSalaryPeriodProvider);

  return allTxAsync.when(
    data: (transactions) {
      return activePeriodAsync.when(
        data: (period) {
          return transactions.where((tx) {
            return tx.date.isAfter(period.startDate.subtract(const Duration(seconds: 1))) &&
                   tx.date.isBefore(period.endDate.add(const Duration(seconds: 1)));
          }).toList();
        },
        loading: () => [],
        error: (_, __) => [],
      );
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Period Financial Summary Provider
final periodFinancialSummaryProvider = Provider<PeriodFinancialSummary>((ref) {
  final activePeriodAsync = ref.watch(activeSalaryPeriodProvider);
  final transactions = ref.watch(periodTransactionsProvider);

  return activePeriodAsync.when(
    data: (period) {
      double salaryIncome = 0.0;
      double otherIncome = 0.0;
      double totalExpenses = 0.0;
      double totalDeductions = 0.0;
      double savingsDeposits = 0.0;
      double savingsWithdrawals = 0.0;

      for (final tx in transactions) {
        switch (tx.type) {
          case TransactionType.income:
            if (tx.categoryId == 'cat_salary' ||
                tx.categoryName.toLowerCase().contains('salary') ||
                tx.description.toLowerCase().contains('salary')) {
              salaryIncome += tx.amount;
            } else {
              otherIncome += tx.amount;
            }
            break;
          case TransactionType.expense:
            totalExpenses += tx.amount;
            break;
          case TransactionType.salaryDeduction:
            totalDeductions += tx.amount;
            break;
          case TransactionType.refund:
            totalExpenses -= tx.amount; // Refund offsets expenses
            break;
          case TransactionType.savingsContribution:
            savingsDeposits += tx.amount;
            break;
          case TransactionType.savingsWithdrawal:
            savingsWithdrawals += tx.amount;
            break;
          case TransactionType.transfer:
            // Transfers between accounts do NOT count towards income or expense
            break;
        }
      }

      final effectiveSalary = salaryIncome > 0 ? salaryIncome : period.netSalary;
      final totalIncome = effectiveSalary + otherIncome;
      final availableSpending =
          (period.carryForwardBalance + totalIncome) - totalExpenses - savingsDeposits + savingsWithdrawals;

      // Savings rate: ((Total Income - Total Expenses) / Total Income) * 100
      double savingsRate = 0.0;
      if (totalIncome > 0) {
        final netSaved = (totalIncome - totalExpenses).clamp(0.0, totalIncome);
        savingsRate = (netSaved / totalIncome) * 100;
      }

      return PeriodFinancialSummary(
        grossSalary: effectiveSalary,
        netSalary: effectiveSalary,
        otherIncome: otherIncome,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses.clamp(0.0, double.infinity),
        totalDeductions: period.deductions + totalDeductions,
        savingsDeposits: savingsDeposits,
        savingsWithdrawals: savingsWithdrawals,
        availableSpendingBalance: availableSpending,
        savingsRate: savingsRate,
        carryForward: period.carryForwardBalance,
        transactionCount: transactions.length,
      );
    },
    loading: () => PeriodFinancialSummary.empty(),
    error: (_, __) => PeriodFinancialSummary.empty(),
  );
});

