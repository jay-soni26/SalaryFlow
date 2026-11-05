import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';
import '../models/recurring_transaction.dart';

final recurringProvider =
    StateNotifierProvider<RecurringNotifier, AsyncValue<List<RecurringTransaction>>>((ref) {
  return RecurringNotifier();
});

class RecurringNotifier extends StateNotifier<AsyncValue<List<RecurringTransaction>>> {
  RecurringNotifier() : super(const AsyncValue.loading()) {
    loadRecurring();
  }

  Future<void> loadRecurring() async {
    try {
      final list = await AppDatabase.instance.getAllRecurring();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveRecurring(RecurringTransaction rec) async {
    await AppDatabase.instance.saveRecurring(rec);
    await loadRecurring();
  }

  Future<void> skipOccurrence(String id, DateTime date) async {
    if (state.value == null) return;
    final item = state.value!.firstWhere((r) => r.id == id);
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final updatedSkipped = List<String>.from(item.skippedOccurrences)..add(dateKey);
    final updated = item.copyWith(skippedOccurrences: updatedSkipped);
    await saveRecurring(updated);
  }

  Future<void> deleteRecurring(String id) async {
    await AppDatabase.instance.deleteRecurring(id);
    await loadRecurring();
  }
}

