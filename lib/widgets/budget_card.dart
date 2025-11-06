import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget.dart';
import '../services/providers.dart';

class BudgetCard extends ConsumerWidget {
  final Budget budget;
  final VoidCallback onEdit;

  const BudgetCard({
    Key? key,
    required this.budget,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(budgetProgressProvider(budget.category));
    final spending = ref.watch(categorySpendingProvider(budget.category));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    budget.category.toString().split('.').last,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '\$${budget.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              progress.when(
                data: (progressValue) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 8,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation(
                          Color.lerp(
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.error,
                            progressValue,
                          ) ?? Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    spending.when(
                      data: (spendingAmount) => Text(
                        'Spent: \$${spendingAmount.toStringAsFixed(2)} '
                        '(${(progressValue * 100).toStringAsFixed(1)}%)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const Text('Error loading spending'),
                    ),
                  ],
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading progress'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedColorTween extends Tween<Color?> {
  AnimatedColorTween({Color? begin, Color? end}) : super(begin: begin, end: end);

  @override
  Color? lerp(double t) => Color.lerp(begin, end, t);
}