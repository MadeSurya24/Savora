import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';

class AppSettingsProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  int? _userId;
  String _languageCode = 'id';
  bool _appLockEnabled = false;
  String? _pinHash;
  bool _isLocked = false;
  bool _isLoading = false;

  String get languageCode => _languageCode;
  bool get appLockEnabled => _appLockEnabled;
  bool get isLocked => _isLocked;
  bool get isLoading => _isLoading;

  Future<void> setUserId(int? userId) async {
    if (_userId == userId) return;
    _userId = userId;

    if (userId == null) {
      _languageCode = 'id';
      _appLockEnabled = false;
      _pinHash = null;
      _isLocked = false;
      notifyListeners();
      return;
    }

    await loadSettings();
  }

  Future<void> loadSettings() async {
    final userId = _userId;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    final settings = await _db.getUserSettings(userId);
    _languageCode = settings['languageCode'] as String? ?? 'id';
    _appLockEnabled = settings['appLockEnabled'] == 1;
    _pinHash = settings['pinHash'] as String?;
    _isLocked = _appLockEnabled && _pinHash != null;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) async {
    final userId = _userId;
    if (userId == null || _languageCode == code) return;

    _languageCode = code;
    notifyListeners();
    await _save();
  }

  Future<bool> enablePin(String pin) async {
    if (!_isValidPin(pin)) return false;
    _pinHash = _hashPin(pin);
    _appLockEnabled = true;
    _isLocked = false;
    notifyListeners();
    await _save();
    return true;
  }

  Future<bool> disablePin(String pin) async {
    if (!verifyPin(pin)) return false;
    _pinHash = null;
    _appLockEnabled = false;
    _isLocked = false;
    notifyListeners();
    await _save();
    return true;
  }

  bool unlock(String pin) {
    if (!verifyPin(pin)) return false;
    _isLocked = false;
    notifyListeners();
    return true;
  }

  void lock() {
    if (!_appLockEnabled || _pinHash == null) return;
    _isLocked = true;
    notifyListeners();
  }

  bool verifyPin(String pin) {
    final hash = _pinHash;
    return hash != null && hash == _hashPin(pin);
  }

  bool _isValidPin(String pin) {
    final digitsOnly = RegExp(r'^\d{4,6}$');
    return digitsOnly.hasMatch(pin);
  }

  Future<void> _save() async {
    final userId = _userId;
    if (userId == null) return;

    await _db.saveUserSettings(
      userId: userId,
      languageCode: _languageCode,
      appLockEnabled: _appLockEnabled,
      pinHash: _pinHash,
    );
  }

  String _hashPin(String pin) {
    final userId = _userId ?? 0;
    final text = '$userId:$pin:savora-local-lock';
    var hash = 0xcbf29ce484222325;
    const prime = 0x100000001b3;

    for (final codeUnit in text.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * prime) & 0xFFFFFFFFFFFFFFFF;
    }

    return hash.toRadixString(16).padLeft(16, '0');
  }
}
