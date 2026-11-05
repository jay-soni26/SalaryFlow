import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';
import '../models/savings_goal.dart';

final savingsGoalsProvider =
    StateNotifierProvider<SavingsGoalsNotifier, AsyncValue<List<SavingsGoal>>>((ref) {
  return SavingsGoalsNotifier();
});

class SavingsGoalsNotifier extends StateNotifier<AsyncValue<List<SavingsGoal>>> {
  SavingsGoalsNotifier() : super(const AsyncValue.loading()) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    try {
      final goals = await AppDatabase.instance.getAllSavingsGoals();
      state = AsyncValue.data(goals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveGoal(SavingsGoal goal) async {
    await AppDatabase.instance.saveSavingsGoal(goal);
    await loadGoals();
  }

  Future<void> contributeToGoal(String goalId, double amount) async {
    if (state.value == null) return;
    final goal = state.value!.firstWhere((g) => g.id == goalId);
    final updated = goal.copyWith(currentAmount: goal.currentAmount + amount);
    await saveGoal(updated);
  }

  Future<void> deleteGoal(String id) async {
    await AppDatabase.instance.deleteSavingsGoal(id);
    await loadGoals();
  }
}

