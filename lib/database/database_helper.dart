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
      version: 3,
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

    await _createUserSettingsTable(db);
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

    if (oldVersion < 3) {
      await _createUserSettingsTable(db);
    }
  }

  Future<void> _createUserSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_settings (
        userId INTEGER PRIMARY KEY,
        languageCode TEXT NOT NULL DEFAULT 'id',
        appLockEnabled INTEGER NOT NULL DEFAULT 0,
        pinHash TEXT,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
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

  Future<int> updateUserName(int id, String name) async {
    final db = await database;
    return db.update(
      'users',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // User settings

  Future<Map<String, dynamic>> getUserSettings(int userId) async {
    final db = await database;
    final maps = await db.query(
      'user_settings',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isNotEmpty) return maps.first;

    final defaults = {
      'userId': userId,
      'languageCode': 'id',
      'appLockEnabled': 0,
      'pinHash': null,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await db.insert('user_settings', defaults);
    return defaults;
  }

  Future<void> saveUserSettings({
    required int userId,
    required String languageCode,
    required bool appLockEnabled,
    String? pinHash,
  }) async {
    final db = await database;
    await db.insert(
      'user_settings',
      {
        'userId': userId,
        'languageCode': languageCode,
        'appLockEnabled': appLockEnabled ? 1 : 0,
        'pinHash': pinHash,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  Future<List<Map<String, dynamic>>> getTransactionsForBackup(int userId) async {
    final db = await database;
    return db.query(
      'transactions',
      columns: ['title', 'amount', 'type', 'category', 'date', 'note'],
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
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

  Future<List<Map<String, dynamic>>> getSavingGoalsForBackup(int userId) async {
    final db = await database;
    return db.query(
      'saving_goals',
      columns: [
        'title',
        'targetAmount',
        'currentAmount',
        'deadline',
        'emoji',
        'colorHex',
      ],
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
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

  Future<void> replaceUserDataFromBackup({
    required int userId,
    required List<Map<String, dynamic>> transactions,
    required List<Map<String, dynamic>> savingGoals,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'transactions',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      await txn.delete(
        'saving_goals',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      for (final transaction in transactions) {
        await txn.insert(
          'transactions',
          _normalizeTransactionBackup(transaction, userId),
        );
      }

      for (final goal in savingGoals) {
        await txn.insert(
          'saving_goals',
          _normalizeSavingGoalBackup(goal, userId),
        );
      }
    });
  }

  Map<String, dynamic> _normalizeTransactionBackup(
    Map<String, dynamic> raw,
    int userId,
  ) {
    final amount = raw['amount'];
    final type = raw['type']?.toString() == 'income' ? 'income' : 'expense';
    final parsedDate = DateTime.tryParse(raw['date']?.toString() ?? '');

    return {
      'userId': userId,
      'title': raw['title']?.toString().trim().isNotEmpty == true
          ? raw['title'].toString().trim()
          : 'Transaksi',
      'amount': amount is num
          ? amount.toDouble()
          : double.tryParse(amount?.toString() ?? '') ?? 0.0,
      'type': type,
      'category': raw['category']?.toString().trim().isNotEmpty == true
          ? raw['category'].toString().trim()
          : (type == 'income' ? 'salary' : 'other'),
      'date': (parsedDate ?? DateTime.now()).toIso8601String(),
      'note': raw['note']?.toString(),
    };
  }

  Map<String, dynamic> _normalizeSavingGoalBackup(
    Map<String, dynamic> raw,
    int userId,
  ) {
    final targetAmount = raw['targetAmount'];
    final currentAmount = raw['currentAmount'];
    final parsedDeadline = DateTime.tryParse(raw['deadline']?.toString() ?? '');

    return {
      'userId': userId,
      'title': raw['title']?.toString().trim().isNotEmpty == true
          ? raw['title'].toString().trim()
          : 'Target Tabungan',
      'targetAmount': targetAmount is num
          ? targetAmount.toDouble()
          : double.tryParse(targetAmount?.toString() ?? '') ?? 0.0,
      'currentAmount': currentAmount is num
          ? currentAmount.toDouble()
          : double.tryParse(currentAmount?.toString() ?? '') ?? 0.0,
      'deadline': (parsedDeadline ?? DateTime.now()).toIso8601String(),
      'emoji': raw['emoji']?.toString(),
      'colorHex': raw['colorHex']?.toString(),
    };
  }
}
