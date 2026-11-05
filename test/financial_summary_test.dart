import 'package:flutter_test/flutter_test.dart';
import 'package:salaryflow/models/salary_config.dart';
import 'package:salaryflow/models/transaction_model.dart';

void main() {
  group('Financial Summary & Calculations Tests', () {
    test('Calculates Net Salary and total deductions accurately', () {
      const config = SalaryConfig(
        defaultSalaryAmount: 100000.0,
        defaultPfDeduction: 6000.0,
        defaultTaxDeduction: 12000.0,
        defaultInsuranceDeduction: 2000.0,
      );

      expect(config.defaultTotalDeductions, equals(20000.0));
      expect(config.defaultNetSalary, equals(80000.0));
    });

    test('Available spending balance isolates protected savings and handles refunds', () {
      const netSalary = 80000.0;
      const carryForward = 5000.0;
      const otherIncome = 10000.0;
      const totalIncome = netSalary + otherIncome; // 90000

      final transactions = [
        TransactionModel(
          id: '1',
          amount: 25000.0,
          date: DateTime(2026, 11, 2),
          type: TransactionType.expense,
          categoryId: 'cat_rent',
          categoryName: 'Rent',
          accountId: 'acc_1',
        ),
        TransactionModel(
          id: '2',
          amount: 5000.0,
          date: DateTime(2026, 11, 3),
          type: TransactionType.expense,
          categoryId: 'cat_groceries',
          categoryName: 'Groceries',
          accountId: 'acc_1',
        ),
        // Refund of 1000 on groceries
        TransactionModel(
          id: '3',
          amount: 1000.0,
          date: DateTime(2026, 11, 4),
          type: TransactionType.refund,
          categoryId: 'cat_groceries',
          categoryName: 'Groceries',
          accountId: 'acc_1',
        ),
        // Deposit into savings account
        TransactionModel(
          id: '4',
          amount: 20000.0,
          date: DateTime(2026, 11, 5),
          type: TransactionType.savingsContribution,
          categoryId: 'cat_savings',
          categoryName: 'Savings Vault',
          accountId: 'acc_1',
        ),
      ];

      double periodExpenses = 0.0;
      double savingsDeposits = 0.0;

      for (final tx in transactions) {
        if (tx.type == TransactionType.expense) {
          periodExpenses += tx.amount;
        } else if (tx.type == TransactionType.refund) {
          periodExpenses -= tx.amount; // offsets expenses
        } else if (tx.type == TransactionType.savingsContribution) {
          savingsDeposits += tx.amount;
        }
      }

      // Expenses: 25000 + 5000 - 1000 = 29000
      expect(periodExpenses, equals(29000.0));
      expect(savingsDeposits, equals(20000.0));

      // Available Spending = (carryForward + totalIncome) - expenses - savingsDeposits
      // = (5000 + 90000) - 29000 - 20000 = 95000 - 49000 = 46000
      final availableSpending = (carryForward + totalIncome) - periodExpenses - savingsDeposits;
      expect(availableSpending, equals(46000.0));
    });

    test('Savings rate percentage calculation', () {
      const totalIncome = 100000.0;
      const totalExpenses = 60000.0;

      final netSaved = (totalIncome - totalExpenses).clamp(0.0, totalIncome);
      final savingsRate = (netSaved / totalIncome) * 100;

      expect(savingsRate, equals(40.0));
    });
  });
}

