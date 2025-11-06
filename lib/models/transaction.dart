import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

enum TransactionCategory {
  food,
  rent,
  transport,
  shopping,
  entertainment,
  utilities,
  health,
  education,
  salary,
  investment,
  other
}

class FinancialTransaction {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final TransactionType type;
  final TransactionCategory category;
  final String? notes;

  FinancialTransaction({
    String? id,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
    required this.category,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.toString(),
      'category': category.toString(),
      'notes': notes,
    };
  }

  factory FinancialTransaction.fromMap(Map<String, dynamic> map) {
    return FinancialTransaction(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.toString() == map['category'],
      ),
      notes: map['notes'],
    );
  }
}