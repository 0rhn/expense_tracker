import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider((ref) => DatabaseService());

final transactionsProvider = FutureProvider<List<FinancialTransaction>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return await databaseService.getTransactions();
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