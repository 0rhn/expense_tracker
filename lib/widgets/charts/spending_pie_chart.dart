import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/transaction.dart';

class SpendingPieChart extends StatelessWidget {
  final List<FinancialTransaction> transactions;
  final TransactionType type;

  const SpendingPieChart({
    Key? key,
    required this.transactions,
    this.type = TransactionType.expense,
  }) : super(key: key);

  Map<TransactionCategory, double> _calculateCategoryTotals() {
    final categoryTotals = <TransactionCategory, double>{};
    final filteredTransactions = transactions.where((t) => t.type == type);

    for (var transaction in filteredTransactions) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    return categoryTotals;
  }

  List<Color> get _categoryColors => [
        Colors.blue,
        Colors.red,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.teal,
        Colors.pink,
        Colors.amber,
        Colors.indigo,
        Colors.cyan,
        Colors.brown,
      ];

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _calculateCategoryTotals();
    final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    if (total == 0) {
      return const Center(
        child: Text('No data available for the selected period'),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: categoryTotals.entries.map((entry) {
                final index = TransactionCategory.values.indexOf(entry.key);
                final percentage = (entry.value / total) * 100;
                
                return PieChartSectionData(
                  color: _categoryColors[index % _categoryColors.length],
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: categoryTotals.entries.map((entry) {
            final index = TransactionCategory.values.indexOf(entry.key);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _categoryColors[index % _categoryColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.key.toString().split('.').last}: \$${entry.value.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}