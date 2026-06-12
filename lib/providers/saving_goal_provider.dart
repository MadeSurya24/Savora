import 'package:flutter/foundation.dart';
import '../models/saving_goal_model.dart';
import '../database/database_helper.dart';

class SavingGoalProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  int? _userId;
  List<SavingGoalModel> _goals = [];
  bool _isLoading = false;

  List<SavingGoalModel> get goals => _goals;
  bool get isLoading => _isLoading;

  double get totalTargetAmount =>
      _goals.fold(0, (sum, g) => sum + g.targetAmount);

  double get totalCurrentAmount =>
      _goals.fold(0, (sum, g) => sum + g.currentAmount);

  void setUserId(int? userId) {
    if (_userId == userId) return;
    _userId = userId;
    if (userId == null) {
      _goals = [];
    }
  }

  Future<void> loadGoals() async {
    final userId = _userId;
    if (userId == null) {
      _goals = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _goals = await _db.getAllSavingGoals(userId);
    } catch (e) {
      debugPrint('Error loading goals: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal(SavingGoalModel goal) async {
    final userId = _userId;
    if (userId == null) return;
    await _db.insertSavingGoal(goal, userId);
    await loadGoals();
  }

  Future<void> updateGoal(SavingGoalModel goal) async {
    final userId = _userId;
    if (userId == null) return;
    await _db.updateSavingGoal(goal, userId);
    await loadGoals();
  }

  Future<void> deleteGoal(int id) async {
    final userId = _userId;
    if (userId == null) return;
    await _db.deleteSavingGoal(id, userId);
    await loadGoals();
  }

  Future<void> addToGoal(int id, double amount) async {
    final userId = _userId;
    if (userId == null) return;
    await _db.addToSavingGoal(id, amount, userId);
    await loadGoals();
  }
}
