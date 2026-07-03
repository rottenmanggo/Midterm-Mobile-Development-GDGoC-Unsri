import 'package:firebase_auth/firebase_auth.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/user_model.dart';

/// Repository wrapping [FirebaseAuthDatasource] for auth operations.
class AuthRepository {
  final FirebaseAuthDatasource _datasource;

  AuthRepository({FirebaseAuthDatasource? datasource})
      : _datasource = datasource ?? FirebaseAuthDatasource();

  /// Returns the currently signed-in [UserModel], or null.
  UserModel? get currentUser {
    final user = _datasource.currentUser;
    return user != null ? UserModel.fromFirebase(user) : null;
  }

  /// Stream of [UserModel] changes (null when signed out).
  Stream<UserModel?> get authStateChanges {
    return _datasource.authStateChanges.map(
      (user) => user != null ? UserModel.fromFirebase(user) : null,
    );
  }

  /// Signs in and returns the [UserModel] on success.
  /// Returns an error string on failure.
  Future<({UserModel? user, String? error})> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _datasource.signIn(email: email, password: password);
      final user = credential.user;
      if (user == null) return (user: null, error: 'Sign in failed.');
      return (user: UserModel.fromFirebase(user), error: null);
    } on FirebaseAuthException catch (e) {
      return (user: null, error: FirebaseAuthDatasource.errorMessage(e));
    } catch (e) {
      return (user: null, error: 'An unexpected error occurred.');
    }
  }

  /// Registers a new user and returns the [UserModel] on success.
  Future<({UserModel? user, String? error})> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _datasource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      final user = credential.user;
      if (user == null) return (user: null, error: 'Registration failed.');
      // Reload to get updated displayName
      await user.reload();
      final refreshed = _datasource.currentUser;
      return (
        user: refreshed != null ? UserModel.fromFirebase(refreshed) : null,
        error: null
      );
    } on FirebaseAuthException catch (e) {
      return (user: null, error: FirebaseAuthDatasource.errorMessage(e));
    } catch (e) {
      return (user: null, error: 'An unexpected error occurred.');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _datasource.signOut();
  }
}
