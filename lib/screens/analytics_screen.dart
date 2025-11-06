import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/providers.dart';
import '../models/transaction.dart';
import '../widgets/charts/spending_pie_chart.dart';
import '../widgets/charts/spending_trend_chart.dart';
import '../widgets/date_range_selector.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  late DateTimeRange _dateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DateRangeSelector(
              startDate: _dateRange.start,
              endDate: _dateRange.end,
              onDateRangeSelected: (start, end) {
                setState(() {
                  _dateRange = DateTimeRange(start: start, end: end);
                });
              },
            ),
          ),
          Expanded(
            child: transactions.when(
              data: (transactionList) => ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Spending by Category',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SpendingPieChart(
                            transactions: transactionList,
                            type: TransactionType.expense,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Income by Category',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SpendingPieChart(
                            transactions: transactionList,
                            type: TransactionType.income,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Income vs Expenses Trend',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SpendingTrendChart(
                            transactions: transactionList,
                            startDate: _dateRange.start,
                            endDate: _dateRange.end,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Add summary statistics
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summary Statistics',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryStatistics(transactionList),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatistics(List<FinancialTransaction> transactions) {
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .map((t) => t.amount)
        .toList();
    final incomes = transactions
        .where((t) => t.type == TransactionType.income)
        .map((t) => t.amount)
        .toList();

    final totalExpenses = expenses.fold(0.0, (a, b) => a + b);
    final totalIncomes = incomes.fold(0.0, (a, b) => a + b);
    final avgExpense =
        expenses.isEmpty ? 0.0 : expenses.reduce((a, b) => a + b) / expenses.length;
    final avgIncome =
        incomes.isEmpty ? 0.0 : incomes.reduce((a, b) => a + b) / incomes.length;

    return Column(
      children: [
        _buildStatisticRow('Total Expenses', '\$${totalExpenses.toStringAsFixed(2)}'),
        _buildStatisticRow('Total Income', '\$${totalIncomes.toStringAsFixed(2)}'),
        _buildStatisticRow('Average Expense', '\$${avgExpense.toStringAsFixed(2)}'),
        _buildStatisticRow('Average Income', '\$${avgIncome.toStringAsFixed(2)}'),
        _buildStatisticRow('Net Savings', '\$${(totalIncomes - totalExpenses).toStringAsFixed(2)}'),
        _buildStatisticRow(
          'Savings Rate',
          totalIncomes > 0
              ? '${((totalIncomes - totalExpenses) / totalIncomes * 100).toStringAsFixed(1)}%'
              : 'N/A',
        ),
      ],
    );
  }

  Widget _buildStatisticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}