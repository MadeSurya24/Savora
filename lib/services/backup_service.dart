import 'dart:convert';

import '../database/database_helper.dart';
import '../models/user_model.dart';

class BackupService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<String> createBackup(UserModel user) async {
    final userId = user.id;
    if (userId == null) {
      throw StateError('User belum siap untuk backup.');
    }

    final transactions = await _db.getTransactionsForBackup(userId);
    final savingGoals = await _db.getSavingGoalsForBackup(userId);

    final payload = {
      'app': 'savora',
      'backupVersion': 1,
      'generatedAt': DateTime.now().toIso8601String(),
      'user': {
        'name': user.name,
        'email': user.email,
      },
      'transactions': transactions,
      'savingGoals': savingGoals,
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<BackupRestoreSummary> restoreBackup({
    required int userId,
    required String backupText,
  }) async {
    final decoded = jsonDecode(backupText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Format backup tidak valid.');
    }

    if (decoded['app'] != 'savora') {
      throw const FormatException('File ini bukan backup Savora.');
    }

    final transactions = _readList(decoded['transactions']);
    final savingGoals = _readList(decoded['savingGoals']);

    await _db.replaceUserDataFromBackup(
      userId: userId,
      transactions: transactions,
      savingGoals: savingGoals,
    );

    return BackupRestoreSummary(
      transactionCount: transactions.length,
      savingGoalCount: savingGoals.length,
    );
  }

  List<Map<String, dynamic>> _readList(Object? value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((item) => item.map(
              (key, value) => MapEntry(key.toString(), value),
            ))
        .toList();
  }
}

class BackupRestoreSummary {
  final int transactionCount;
  final int savingGoalCount;

  const BackupRestoreSummary({
    required this.transactionCount,
    required this.savingGoalCount,
  });
}
