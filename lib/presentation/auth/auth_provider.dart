import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Provider managing authentication state for the app.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  // ── Getters ──────────────────────────────────────────────────────────────

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Sets the current user (called from app.dart authStateChanges listener).
  void setUser(UserModel? user) {
    _user = user;
    _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Signs in with email and password.
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading();
    final result = await _repository.signIn(email: email, password: password);
    if (result.error != null) {
      _setError(result.error!);
      return false;
    }
    _user = result.user;
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Registers with email, password, and display name.
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading();
    final result = await _repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    if (result.error != null) {
      _setError(result.error!);
      return false;
    }
    _user = result.user;
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Signs out and clears state.
  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private Helpers ───────────────────────────────────────────────────────

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
