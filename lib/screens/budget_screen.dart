import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../services/providers.dart';
import '../widgets/budget_card.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                setState(() {
                  selectedDate = date;
                });
              }
            },
          ),
        ],
      ),
      body: budgets.when(
        data: (budgetsList) => ListView.builder(
          itemCount: TransactionCategory.values.length,
          itemBuilder: (context, index) {
            final category = TransactionCategory.values[index];
            final budget = budgetsList.firstWhere(
              (b) => b.category == category,
              orElse: () => Budget(
                id: '',
                category: category,
                amount: 0,
                startDate: DateTime(selectedDate.year, selectedDate.month, 1),
                endDate: DateTime(selectedDate.year, selectedDate.month + 1, 0),
              ),
            );
            return BudgetCard(
              budget: budget,
              onEdit: () => _showBudgetDialog(context, ref, budget),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBudgetDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showBudgetDialog(BuildContext context, WidgetRef ref, Budget? budget) async {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(
      text: budget?.amount.toString() ?? '',
    );
    TransactionCategory selectedCategory = budget?.category ?? TransactionCategory.values.first;
    final selectedDate = ref.read(selectedDateProvider);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(budget == null ? 'Add Budget' : 'Edit Budget'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TransactionCategory>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: TransactionCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCategory = value;
                  }
                },
              ),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final databaseService = ref.read(databaseServiceProvider);
                final newBudget = Budget(
                  id: budget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  category: selectedCategory,
                  amount: double.parse(amountController.text),
                  startDate: DateTime(selectedDate.year, selectedDate.month, 1),
                  endDate: DateTime(selectedDate.year, selectedDate.month + 1, 0),
                );

                await databaseService.insertBudget(newBudget);
                // ignore: unused_result
                ref.refresh(budgetsProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}