import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/budget.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        notes TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE budgets(
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  // Transaction Methods
  Future<void> insertTransaction(FinancialTransaction transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FinancialTransaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) => FinancialTransaction.fromMap(maps[i]));
  }

  Future<List<FinancialTransaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return List.generate(maps.length, (i) => FinancialTransaction.fromMap(maps[i]));
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTransaction(FinancialTransaction transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Budget Methods
  Future<void> insertBudget(Budget budget) async {
    final db = await database;
    await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Budget>> getBudgets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('budgets');
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  Future<Budget?> getBudgetByCategory(TransactionCategory category, DateTime date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'category = ? AND startDate <= ? AND endDate >= ?',
      whereArgs: [category.toString(), date.toIso8601String(), date.toIso8601String()],
    );
    if (maps.isEmpty) return null;
    return Budget.fromMap(maps.first);
  }

  Future<Map<TransactionCategory, double>> getSpendingByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE date BETWEEN ? AND ?
      AND type = ?
      GROUP BY category
    ''', [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
      TransactionType.expense.toString(),
    ]);

    final spending = <TransactionCategory, double>{};
    for (final row in results) {
      final category = TransactionCategory.values.firstWhere(
        (e) => e.toString() == row['category'] as String,
      );
      spending[category] = row['total'] as double;
    }
    return spending;
  }

  Future<void> updateBudget(Budget budget) async {
    final db = await database;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}