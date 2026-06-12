import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/saving_goal_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'savora.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE saving_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL DEFAULT 0,
        deadline TEXT NOT NULL,
        emoji TEXT,
        colorHex TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          passwordHash TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');

      final existingUsers = await db.query('users', limit: 1);
      if (existingUsers.isEmpty) {
        await db.insert('users', {
          'id': 1,
          'name': 'Demo User',
          'email': 'demo@savora.local',
          'passwordHash': 'legacy-local-account',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      await _addColumnIfMissing(db, 'transactions', 'userId', 'INTEGER NOT NULL DEFAULT 1');
      await _addColumnIfMissing(db, 'saving_goals', 'userId', 'INTEGER NOT NULL DEFAULT 1');
    }
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  // Users

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  // Transactions

  Future<int> insertTransaction(TransactionModel transaction, int userId) async {
    final db = await database;
    return db.insert('transactions', {
      ...transaction.toMap(),
      'userId': userId,
    });
  }

  Future<List<TransactionModel>> getAllTransactions(int userId) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return maps.map(TransactionModel.fromMap).toList();
  }

  Future<List<TransactionModel>> getRecentTransactions(
    int userId, {
    int limit = 10,
  }) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map(TransactionModel.fromMap).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction, int userId) async {
    final db = await database;
    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [transaction.id, userId],
    );
  }

  Future<int> deleteTransaction(int id, int userId) async {
    final db = await database;
    return db.delete(
      'transactions',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  Future<double> getTotalByType(String type, int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ? AND userId = ?',
      [type, userId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getExpenseByCategory(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE type = "expense" AND userId = ?
      GROUP BY category
      ''',
      [userId],
    );

    final map = <String, double>{};
    for (final row in result) {
      map[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> getWeeklyExpenses(int userId) async {
    final db = await database;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return db.rawQuery(
      '''
      SELECT date, SUM(amount) as total
      FROM transactions
      WHERE type = "expense" AND userId = ? AND date >= ?
      GROUP BY substr(date, 1, 10)
      ORDER BY date ASC
      ''',
      [userId, weekStart.toIso8601String()],
    );
  }

  Future<List<Map<String, dynamic>>> getMonthlyExpenses(int userId) async {
    final db = await database;
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

    return db.rawQuery(
      '''
      SELECT substr(date, 1, 7) as month, SUM(amount) as total
      FROM transactions
      WHERE type = "expense" AND userId = ? AND date >= ?
      GROUP BY month
      ORDER BY month ASC
      ''',
      [userId, sixMonthsAgo.toIso8601String()],
    );
  }

  // Saving goals

  Future<int> insertSavingGoal(SavingGoalModel goal, int userId) async {
    final db = await database;
    return db.insert('saving_goals', {
      ...goal.toMap(),
      'userId': userId,
    });
  }

  Future<List<SavingGoalModel>> getAllSavingGoals(int userId) async {
    final db = await database;
    final maps = await db.query(
      'saving_goals',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return maps.map(SavingGoalModel.fromMap).toList();
  }

  Future<int> updateSavingGoal(SavingGoalModel goal, int userId) async {
    final db = await database;
    return db.update(
      'saving_goals',
      goal.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [goal.id, userId],
    );
  }

  Future<int> deleteSavingGoal(int id, int userId) async {
    final db = await database;
    return db.delete(
      'saving_goals',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> addToSavingGoal(int id, double amount, int userId) async {
    final db = await database;
    return db.rawUpdate(
      '''
      UPDATE saving_goals
      SET currentAmount = currentAmount + ?
      WHERE id = ? AND userId = ?
      ''',
      [amount, id, userId],
    );
  }
}
