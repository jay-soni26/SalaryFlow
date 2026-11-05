import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/currency_format.dart';
import '../../core/utils/date_cycle_helper.dart';
import '../../models/transaction_model.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/salary_cycle_provider.dart';
import 'edit_cycle_dialog.dart';
import '../transactions/add_edit_transaction_screen.dart';
import '../transactions/transaction_detail_dialog.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final allTransactionsAsync = ref.watch(allTransactionsProvider);
    final activePeriodAsync = ref.watch(activeSalaryPeriodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Calendar'),
        actions: [
          activePeriodAsync.when(
            data: (period) => IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Edit Cycle Dates',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => EditCycleDialog(period: period),
                );
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditTransactionScreen(
                initialType: TransactionType.expense,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: allTransactionsAsync.when(
        data: (transactions) {
          // Group transactions by date
          final Map<DateTime, List<TransactionModel>> events = {};
          for (final tx in transactions) {
            final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
            events.putIfAbsent(dateKey, () => []).add(tx);
          }

          final selectedDayKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
          final dayTransactions = events[selectedDayKey] ?? [];

          return Column(
            children: [
              // Calendar View
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: TableCalendar(
                  firstDay: DateTime(2020, 1, 1),
                  lastDay: DateTime(2035, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  eventLoader: (day) {
                    final key = DateTime(day.year, day.month, day.day);
                    return events[key] ?? [];
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    // Update the active salary cycle period provider when navigating months
                    ref.read(selectedCycleMonthProvider.notifier).state =
                        SelectedCycleMonth(focusedDay.year, focusedDay.month);
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Selected Day Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateCycleHelper.formatShortDate(_selectedDay),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '${dayTransactions.length} event(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Day transactions list
              Expanded(
                child: dayTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 40,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(height: 8),
                            const Text('No transactions on this date'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: dayTransactions.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemBuilder: (context, index) {
                          final tx = dayTransactions[index];
                          return _buildDayTransactionTile(context, tx, isDark);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDayTransactionTile(BuildContext context, TransactionModel tx, bool isDark) {
    Color typeColor = AppColors.expense;
    if (tx.type == TransactionType.income) typeColor = AppColors.income;
    if (tx.type == TransactionType.salaryDeduction) typeColor = AppColors.deduction;
    if (tx.type == TransactionType.transfer) typeColor = AppColors.transfer;
    if (tx.type == TransactionType.savingsContribution) typeColor = AppColors.savings;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => TransactionDetailDialog(transaction: tx),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt, color: typeColor, size: 18),
        ),
        title: Text(
          tx.description.isNotEmpty ? tx.description : tx.categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          tx.categoryName,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        trailing: Text(
          CurrencyFormat.format(tx.amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: typeColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

