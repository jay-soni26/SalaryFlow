import 'package:flutter_test/flutter_test.dart';
import 'package:salaryflow/models/account.dart';

void main() {
  group('Account & Transfer Logic Tests', () {
    test('Transfer between accounts decrements source and increments destination', () {
      var sourceAcc = Account(
        id: 'acc_source',
        name: 'Salary Account',
        type: AccountType.salaryBank,
        openingBalance: 50000.0,
        currentBalance: 50000.0,
      );

      var destAcc = Account(
        id: 'acc_dest',
        name: 'Savings Account',
        type: AccountType.savingsBank,
        openingBalance: 20000.0,
        currentBalance: 20000.0,
      );

      const transferAmount = 15000.0;

      // Apply transfer
      sourceAcc = sourceAcc.copyWith(currentBalance: sourceAcc.currentBalance - transferAmount);
      destAcc = destAcc.copyWith(currentBalance: destAcc.currentBalance + transferAmount);

      expect(sourceAcc.currentBalance, equals(35000.0));
      expect(destAcc.currentBalance, equals(35000.0));

      // Combined net balance remains exactly constant
      final totalNetBalance = sourceAcc.currentBalance + destAcc.currentBalance;
      expect(totalNetBalance, equals(70000.0));
    });

    test('Editing opening balance preserves model integrity', () {
      final original = Account(
        id: 'acc_cash',
        name: 'Cash In Hand',
        type: AccountType.cashWallet,
        openingBalance: 1000.0,
        currentBalance: 1000.0,
      );

      final edited = original.copyWith(
        name: 'Physical Cash Wallet',
        openingBalance: 2500.0,
        currentBalance: 2500.0,
      );

      expect(edited.name, equals('Physical Cash Wallet'));
      expect(edited.openingBalance, equals(2500.0));
      expect(edited.currentBalance, equals(2500.0));
      expect(edited.type, equals(AccountType.cashWallet));
    });
  });
}

