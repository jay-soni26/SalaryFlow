import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';
import '../models/budget.dart';
import 'transactions_provider.dart';
import '../models/transaction_model.dart';

final budgetsProvider = StateNotifierProvider<BudgetsNotifier, AsyncValue<List<Budget>>>((ref) {
  return BudgetsNotifier();
});

class BudgetsNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  BudgetsNotifier() : super(const AsyncValue.loading()) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    try {
      final budgets = await AppDatabase.instance.getAllBudgets();
      state = AsyncValue.data(budgets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveBudget(Budget budget) async {
    await AppDatabase.instance.saveBudget(budget);
    await loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await AppDatabase.instance.deleteBudget(id);
    await loadBudgets();
  }
}

// Budget progress info model
class BudgetProgress {
  final Budget budget;
  final double spent;
  final double remaining;
  final double percentage;

  BudgetProgress({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentage,
  });
}

final budgetProgressListProvider = Provider<List<BudgetProgress>>((ref) {
  final budgetsAsync = ref.watch(budgetsProvider);
  final transactions = ref.watch(periodTransactionsProvider);

  return budgetsAsync.when(
    data: (budgets) {
      return budgets.map((b) {
        final spent = transactions
            .where((tx) => tx.categoryId == b.categoryId && tx.type == TransactionType.expense)
            .fold(0.0, (sum, tx) => sum + tx.amount);

        final remaining = (b.limitAmount - spent);
        final pct = b.limitAmount > 0 ? (spent / b.limitAmount).clamp(0.0, 1.0) : 0.0;

        return BudgetProgress(
          budget: b,
          spent: spent,
          remaining: remaining,
          percentage: pct,
        );
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

