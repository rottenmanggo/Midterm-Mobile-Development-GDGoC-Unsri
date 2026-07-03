import 'package:firebase_auth/firebase_auth.dart';

/// Thin model wrapping Firebase [User] into a plain Dart class.
class UserModel {
  final String uid;
  final String email;
  final String displayName;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  /// Creates a [UserModel] from a Firebase [User].
  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? user.email?.split('@').first ?? 'User',
    );
  }

  /// Returns the first name or username portion for greeting display.
  String get firstName {
    final parts = displayName.split(' ');
    return parts.isNotEmpty ? parts.first : displayName;
  }

  @override
  String toString() => 'UserModel(uid: $uid, email: $email)';
}
