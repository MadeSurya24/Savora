import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../database/database_helper.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  int? _userId;
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterType = 'all'; // 'all', 'income', 'expense'

  List<TransactionModel> get transactions => _filteredTransactions;
  List<TransactionModel> get allTransactions => _transactions;
  bool get isLoading => _isLoading;
  String get filterType => _filterType;

  double _totalIncome = 0;
  double _totalExpense = 0;

  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _totalIncome - _totalExpense;

  Map<String, double> _expenseByCategory = {};
  Map<String, double> get expenseByCategory => _expenseByCategory;

  void setUserId(int? userId) {
    if (_userId == userId) return;
    _userId = userId;
    if (userId == null) {
      _transactions = [];
      _filteredTransactions = [];
      _totalIncome = 0;
      _totalExpense = 0;
      _expenseByCategory = {};
    }
  }

  Future<void> loadTransactions() async {
    final userId = _userId;
    if (userId == null) {
      _transactions = [];
      _filteredTransactions = [];
      _totalIncome = 0;
      _totalExpense = 0;
      _expenseByCategory = {};
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _db.getAllTransactions(userId);
      _totalIncome = await _db.getTotalByType('income', userId);
      _totalExpense = await _db.getTotalByType('expense', userId);
      _expenseByCategory = await _db.getExpenseByCategory(userId);
      _applyFilter();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    final userId = _userId;
    if (userId == null) return [];
    return await _db.getRecentTransactions(userId, limit: limit);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final userId = _userId;
    if (userId == null) return;
    await _db.insertTransaction(transaction, userId);
    await loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final userId = _userId;
    if (userId == null) return;
    await _db.updateTransaction(transaction, userId);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    final userId = _userId;
    if (userId == null) return;
    await _db.deleteTransaction(id, userId);
    await loadTransactions();
  }

  void setFilterType(String type) {
    _filterType = type;
    _applyFilter();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    var result = List<TransactionModel>.from(_transactions);

    if (_filterType != 'all') {
      result = result.where((t) => t.type == _filterType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((t) =>
      t.title.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q))
          .toList();
    }

    _filteredTransactions = result;
  }

  Future<List<Map<String, dynamic>>> getWeeklyExpenses() async {
    final userId = _userId;
    if (userId == null) return [];
    return await _db.getWeeklyExpenses(userId);
  }

  Future<List<Map<String, dynamic>>> getMonthlyExpenses() async {
    final userId = _userId;
    if (userId == null) return [];
    return await _db.getMonthlyExpenses(userId);
  }
}
