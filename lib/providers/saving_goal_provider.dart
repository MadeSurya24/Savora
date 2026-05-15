import 'package:flutter/foundation.dart';
import '../models/saving_goal_model.dart';
import '../database/database_helper.dart';

class SavingGoalProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<SavingGoalModel> _goals = [];
  bool _isLoading = false;

  List<SavingGoalModel> get goals => _goals;
  bool get isLoading => _isLoading;

  double get totalTargetAmount =>
      _goals.fold(0, (sum, g) => sum + g.targetAmount);

  double get totalCurrentAmount =>
      _goals.fold(0, (sum, g) => sum + g.currentAmount);

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _goals = await _db.getAllSavingGoals();
    } catch (e) {
      debugPrint('Error loading goals: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal(SavingGoalModel goal) async {
    await _db.insertSavingGoal(goal);
    await loadGoals();
  }

  Future<void> updateGoal(SavingGoalModel goal) async {
    await _db.updateSavingGoal(goal);
    await loadGoals();
  }

  Future<void> deleteGoal(int id) async {
    await _db.deleteSavingGoal(id);
    await loadGoals();
  }

  Future<void> addToGoal(int id, double amount) async {
    await _db.addToSavingGoal(id, amount);
    await loadGoals();
  }
}