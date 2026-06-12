import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../database/database_helper.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  UserModel? _currentUser;
  bool _isLoading = true;
  bool _googleInitialized = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _ensureGoogleInitialized();
      final firebaseUser = _firebaseAuth.currentUser;
      _currentUser =
          firebaseUser == null ? null : await _syncLocalUser(firebaseUser);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _friendlyMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      await _ensureGoogleInitialized();
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw StateError('Google tidak mengembalikan ID token.');
      }

      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = result.user;
      if (firebaseUser == null) {
        throw StateError('Akun Google gagal dibaca.');
      }

      _currentUser = await _syncLocalUser(firebaseUser);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _friendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } finally {
      _currentUser = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  Future<UserModel> _syncLocalUser(firebase_auth.User firebaseUser) async {
    final email = firebaseUser.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) {
      throw StateError('Akun Google tidak memiliki email.');
    }

    final existingUser = await _db.getUserByEmail(email);
    if (existingUser != null) return existingUser;

    final fallbackName = email.split('@').first;
    final name = firebaseUser.displayName?.trim();
    final id = await _db.insertUser(
      UserModel(
        name: name == null || name.isEmpty ? fallbackName : name,
        email: email,
        passwordHash: 'google:${firebaseUser.uid}',
        createdAt: DateTime.now(),
      ),
    );

    final createdUser = await _db.getUserById(id);
    if (createdUser == null) {
      throw StateError('Akun lokal gagal dibuat.');
    }
    return createdUser;
  }

  String _friendlyMessage(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('canceled')) {
      return 'Login Google dibatalkan.';
    }
    if (text.contains('network')) {
      return 'Koneksi internet bermasalah. Coba lagi.';
    }
    if (text.contains('clientconfigurationerror') ||
        text.contains('serverclientid') ||
        text.contains('google-services')) {
      return 'Konfigurasi Google Sign-In belum lengkap.';
    }
    return 'Login Google gagal. Coba lagi.';
  }
}
