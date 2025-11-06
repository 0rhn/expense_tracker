import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider((ref) => DatabaseService());

final selectedDateProvider = Provider<DateTime>((ref) => DateTime.now());

final transactionsProvider = FutureProvider<List<FinancialTransaction>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return await databaseService.getTransactions();
});

final budgetsProvider = FutureProvider<List<Budget>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return await databaseService.getBudgets();
});

final categorySpendingProvider = FutureProvider.family<double, TransactionCategory>((ref, category) async {
  final databaseService = ref.watch(databaseServiceProvider);
  final date = ref.watch(selectedDateProvider);
  final startDate = DateTime(date.year, date.month, 1);
  final endDate = DateTime(date.year, date.month + 1, 0);
  
  final spending = await databaseService.getSpendingByCategory(startDate, endDate);
  return spending[category] ?? 0.0;
});

final budgetProgressProvider = FutureProvider.family<double, TransactionCategory>((ref, category) async {
  final databaseService = ref.watch(databaseServiceProvider);
  final date = ref.watch(selectedDateProvider);
  final spending = await ref.watch(categorySpendingProvider(category).future);
  final budget = await databaseService.getBudgetByCategory(category, date);
  
  if (budget == null || budget.amount == 0) return 0.0;
  return (spending / budget.amount).clamp(0.0, 1.0);
});

final balanceProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.when(
    data: (transactions) => transactions.fold(
      0.0,
      (total, transaction) => total +
          (transaction.type == TransactionType.income
              ? transaction.amount
              : -transaction.amount),
    ),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.when(
    data: (transactions) => transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (total, t) => total + t.amount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

final totalExpensesProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.when(
    data: (transactions) => transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (total, t) => total + t.amount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});