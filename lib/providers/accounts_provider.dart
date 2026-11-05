import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';
import '../models/account.dart';

final accountsProvider = StateNotifierProvider<AccountsNotifier, AsyncValue<List<Account>>>((ref) {
  return AccountsNotifier();
});

class AccountsNotifier extends StateNotifier<AsyncValue<List<Account>>> {
  AccountsNotifier() : super(const AsyncValue.loading()) {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    try {
      final accounts = await AppDatabase.instance.getAllAccounts();
      state = AsyncValue.data(accounts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAccount(Account account) async {
    await AppDatabase.instance.insertAccount(account);
    await loadAccounts();
  }

  Future<void> updateAccount(Account account) async {
    await AppDatabase.instance.updateAccount(account);
    await loadAccounts();
  }

  Future<void> deleteAccount(String id) async {
    await AppDatabase.instance.deleteAccount(id);
    await loadAccounts();
  }

  double getTotalBalance(List<Account> accounts) {
    return accounts.fold(0.0, (sum, acc) => sum + acc.currentBalance);
  }

  double getSavingsBalance(List<Account> accounts) {
    return accounts
        .where((acc) => acc.type == AccountType.savingsBank)
        .fold(0.0, (sum, acc) => sum + acc.currentBalance);
  }

  double getSpendingBalance(List<Account> accounts) {
    return accounts
        .where((acc) => acc.type != AccountType.savingsBank)
        .fold(0.0, (sum, acc) => sum + acc.currentBalance);
  }
}

