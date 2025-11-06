import '../models/transaction.dart';

class Budget {
  final String id;
  final TransactionCategory category;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.startDate,
    required this.endDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.toString(),
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: TransactionCategory.values.firstWhere(
        (e) => e.toString() == map['category'],
      ),
      amount: map['amount'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      notes: map['notes'],
    );
  }

  Budget copyWith({
    String? id,
    TransactionCategory? category,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
    );
  }
}