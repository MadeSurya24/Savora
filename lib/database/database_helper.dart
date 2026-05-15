import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/saving_goal_model.dart';

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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE saving_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL DEFAULT 0,
        deadline TEXT NOT NULL,
        emoji TEXT,
        colorHex TEXT
      )
    ''');

    await _insertDummyData(db);
  }

  Future<void> _insertDummyData(Database db) async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> dummyTransactions = [
      {
        'title': 'Gaji Bulanan',
        'amount': 8500000.0,
        'type': 'income',
        'category': 'salary',
        'date': DateTime(now.year, now.month, 1).toIso8601String(),
        'note': 'Gaji bulan ini',
      },
      {
        'title': 'Freelance Design',
        'amount': 1500000.0,
        'type': 'income',
        'category': 'freelance',
        'date': DateTime(now.year, now.month, 5).toIso8601String(),
        'note': 'Project logo branding',
      },
      {
        'title': 'Makan Siang',
        'amount': 45000.0,
        'type': 'expense',
        'category': 'food',
        'date': DateTime(now.year, now.month, now.day).toIso8601String(),
        'note': 'Nasi padang',
      },
      {
        'title': 'Grab ke Kantor',
        'amount': 28000.0,
        'type': 'expense',
        'category': 'transport',
        'date': DateTime(now.year, now.month, now.day).toIso8601String(),
        'note': null,
      },
      {
        'title': 'Kopi Kekinian',
        'amount': 35000.0,
        'type': 'expense',
        'category': 'lifestyle',
        'date': DateTime(now.year, now.month, now.day - 1).toIso8601String(),
        'note': 'Iced latte',
      },
      {
        'title': 'Belanja Groceries',
        'amount': 320000.0,
        'type': 'expense',
        'category': 'shopping',
        'date': DateTime(now.year, now.month, now.day - 1).toIso8601String(),
        'note': 'Kebutuhan bulanan',
      },
      {
        'title': 'Netflix',
        'amount': 54000.0,
        'type': 'expense',
        'category': 'entertainment',
        'date': DateTime(now.year, now.month, now.day - 2).toIso8601String(),
        'note': 'Langganan streaming',
      },
      {
        'title': 'Nonton Bioskop',
        'amount': 75000.0,
        'type': 'expense',
        'category': 'entertainment',
        'date': DateTime(now.year, now.month, now.day - 2).toIso8601String(),
        'note': null,
      },
      {
        'title': 'Vitamin & Suplemen',
        'amount': 150000.0,
        'type': 'expense',
        'category': 'health',
        'date': DateTime(now.year, now.month, now.day - 3).toIso8601String(),
        'note': 'Vitamin C & Omega 3',
      },
      {
        'title': 'Makan Malam',
        'amount': 85000.0,
        'type': 'expense',
        'category': 'food',
        'date': DateTime(now.year, now.month, now.day - 3).toIso8601String(),
        'note': 'Restoran bersama teman',
      },
      {
        'title': 'Buku Flutter Dev',
        'amount': 120000.0,
        'type': 'expense',
        'category': 'education',
        'date': DateTime(now.year, now.month, now.day - 4).toIso8601String(),
        'note': null,
      },
      {
        'title': 'Bensin Motor',
        'amount': 50000.0,
        'type': 'expense',
        'category': 'transport',
        'date': DateTime(now.year, now.month, now.day - 4).toIso8601String(),
        'note': null,
      },
      {
        'title': 'Investasi Reksadana',
        'amount': 500000.0,
        'type': 'income',
        'category': 'investment',
        'date': DateTime(now.year, now.month, now.day - 5).toIso8601String(),
        'note': 'Return investasi',
      },
      {
        'title': 'Makan Siang Kantor',
        'amount': 38000.0,
        'type': 'expense',
        'category': 'food',
        'date': DateTime(now.year, now.month, now.day - 5).toIso8601String(),
        'note': null,
      },
      {
        'title': 'Baju Baru',
        'amount': 280000.0,
        'type': 'expense',
        'category': 'shopping',
        'date': DateTime(now.year, now.month, now.day - 6).toIso8601String(),
        'note': 'Baju kantor',
      },
    ];

    for (final t in dummyTransactions) {
      await db.insert('transactions', t);
    }

    final List<Map<String, dynamic>> dummyGoals = [
      {
        'title': 'Laptop Baru',
        'targetAmount': 15000000.0,
        'currentAmount': 7500000.0,
        'deadline': DateTime(now.year + 1, 3, 1).toIso8601String(),
        'emoji': '💻',
        'colorHex': '#3B82F6',
      },
      {
        'title': 'Dana Darurat',
        'targetAmount': 30000000.0,
        'currentAmount': 18000000.0,
        'deadline': DateTime(now.year + 1, 12, 31).toIso8601String(),
        'emoji': '🛡️',
        'colorHex': '#0FA968',
      },
      {
        'title': 'Liburan Bali',
        'targetAmount': 5000000.0,
        'currentAmount': 3200000.0,
        'deadline': DateTime(now.year, now.month + 3, 1).toIso8601String(),
        'emoji': '🏖️',
        'colorHex': '#F59E0B',
      },
      {
        'title': 'Motor Baru',
        'targetAmount': 25000000.0,
        'currentAmount': 5000000.0,
        'deadline': DateTime(now.year + 2, 6, 1).toIso8601String(),
        'emoji': '🏍️',
        'colorHex': '#8B5CF6',
      },
    ];

    for (final g in dummyGoals) {
      await db.insert('saving_goals', g);
    }
  }

  // ── TRANSACTIONS ──────────────────────────────────────────────

  Future<int> insertTransaction(TransactionModel t) async {
    final db = await database;
    return await db.insert('transactions', t.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map(TransactionModel.fromMap).toList();
  }

  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    final db = await database;
    final maps = await db.query('transactions',
        orderBy: 'date DESC', limit: limit);
    return maps.map(TransactionModel.fromMap).toList();
  }

  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return maps.map(TransactionModel.fromMap).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map(TransactionModel.fromMap).toList();
  }

  Future<List<TransactionModel>> searchTransactions(String query) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'title LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return maps.map(TransactionModel.fromMap).toList();
  }

  Future<int> updateTransaction(TransactionModel t) async {
    final db = await database;
    return await db.update(
      'transactions',
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalByType(String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      [type],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getExpenseByCategory() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM transactions WHERE type = "expense" GROUP BY category',
    );
    final Map<String, double> map = {};
    for (final row in result) {
      map[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> getWeeklyExpenses() async {
    final db = await database;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final result = await db.rawQuery(
      '''SELECT date, SUM(amount) as total 
         FROM transactions 
         WHERE type = "expense" AND date >= ? 
         GROUP BY substr(date, 1, 10)
         ORDER BY date ASC''',
      [weekStart.toIso8601String()],
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getMonthlyExpenses() async {
    final db = await database;
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
    final result = await db.rawQuery(
      '''SELECT substr(date, 1, 7) as month, SUM(amount) as total 
         FROM transactions 
         WHERE type = "expense" AND date >= ?
         GROUP BY month
         ORDER BY month ASC''',
      [sixMonthsAgo.toIso8601String()],
    );
    return result;
  }

  // ── SAVING GOALS ──────────────────────────────────────────────

  Future<int> insertSavingGoal(SavingGoalModel goal) async {
    final db = await database;
    return await db.insert('saving_goals', goal.toMap());
  }

  Future<List<SavingGoalModel>> getAllSavingGoals() async {
    final db = await database;
    final maps = await db.query('saving_goals', orderBy: 'id DESC');
    return maps.map(SavingGoalModel.fromMap).toList();
  }

  Future<int> updateSavingGoal(SavingGoalModel goal) async {
    final db = await database;
    return await db.update(
      'saving_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteSavingGoal(int id) async {
    final db = await database;
    return await db.delete('saving_goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> addToSavingGoal(int id, double amount) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE saving_goals SET currentAmount = currentAmount + ? WHERE id = ?',
      [amount, id],
    );
  }
}