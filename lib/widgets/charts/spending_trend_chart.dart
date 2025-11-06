import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/transaction.dart';
import 'package:intl/intl.dart';

class SpendingTrendChart extends StatelessWidget {
  final List<FinancialTransaction> transactions;
  final DateTime startDate;
  final DateTime endDate;

  const SpendingTrendChart({
    Key? key,
    required this.transactions,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  List<FlSpot> _generateSpots(TransactionType type) {
    final Map<DateTime, double> dailyTotals = {};
    final filteredTransactions = transactions.where((t) => t.type == type);

    // Initialize all days with 0
    for (var d = startDate;
        d.isBefore(endDate.add(const Duration(days: 1)));
        d = d.add(const Duration(days: 1))) {
      dailyTotals[DateTime(d.year, d.month, d.day)] = 0;
    }

    // Sum transactions by day
    for (var transaction in filteredTransactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      dailyTotals[date] = (dailyTotals[date] ?? 0) + transaction.amount;
    }

    // Convert to spots
    final spots = dailyTotals.entries.map((entry) {
      final days = entry.key.difference(startDate).inDays.toDouble();
      return FlSpot(days, entry.value);
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final expenseSpots = _generateSpots(TransactionType.expense);
    final incomeSpots = _generateSpots(TransactionType.income);

    if (expenseSpots.isEmpty && incomeSpots.isEmpty) {
      return const Center(
        child: Text('No data available for the selected period'),
      );
    }

    final maxY = [
      ...expenseSpots.map((s) => s.y),
      ...incomeSpots.map((s) => s.y),
    ].reduce((max, value) => value > max ? value : max);

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 7,
                    getTitlesWidget: (value, meta) {
                      final date = startDate.add(Duration(days: value.toInt()));
                      return Text(
                        DateFormat('MMM d').format(date),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: maxY / 5,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${value.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: expenseSpots,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.red.withOpacity(0.1),
                  ),
                ),
                LineChartBarData(
                  spots: incomeSpots,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.withOpacity(0.1),
                  ),
                ),
              ],
              minX: 0,
              maxX: endDate.difference(startDate).inDays.toDouble(),
              minY: 0,
              maxY: maxY * 1.1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('Expenses'),
              ],
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('Income'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}