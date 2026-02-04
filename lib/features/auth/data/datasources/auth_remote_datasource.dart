import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';
/// Contract for authentication data operations.
///
/// Defines methods that interact with Supabase Auth.
/// Implemented by [AuthRemoteDataSourceImpl].
abstract class AuthRemoteDataSource {
  /// Signs in a user with email and password.
  ///
  /// Throws [AppAuthException] if credentials are invalid.
  /// Throws [ServerException] on network/server errors.
  Future<UserModel> login(String email, String password);

  /// Creates a new user account.
  ///
  /// Throws [AppAuthException] if email already exists.
  /// Throws [ServerException] on network/server errors.
  Future<UserModel> register(String email, String password);

  /// Signs out the current user.
  ///
  /// Throws [AppAuthException] on failure.
  Future<void> logout();

  /// Returns the currently signed-in user, or `null` if not authenticated.
  UserModel? get currentUser;

  /// Stream that emits user changes (login/logout events).
  Stream<UserModel?> get authStateChanges;
}

/// Implementation of [AuthRemoteDataSource] using Supabase Auth.
///
/// Handles all direct communication with Supabase authentication services.
///
/// ## Error Handling
///
/// - Catches [AuthException] from Supabase and rethrows as [AppAuthException]
/// - Catches other exceptions and throws [ServerException]
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Supabase client for authentication operations.
  final SupabaseClient _client;

  /// Creates an [AuthRemoteDataSourceImpl] with the given Supabase [client].
  AuthRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AppAuthException('Login failed: No user returned');
      }

      return UserModel.fromAuthUser(
        user.id,
        user.email ?? '',
        user.userMetadata,
      );
    } on AuthException catch (e) {
      // Supabase auth error (invalid credentials, etc.)
      throw AppAuthException(e.message);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw ServerException('Login failed: $e');
    }
  }

  @override
  Future<UserModel> register(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AppAuthException('Registration failed: No user returned');
      }

      return UserModel.fromAuthUser(
        user.id,
        user.email ?? '',
        user.userMetadata,
      );
    } on AuthException catch (e) {
      // Supabase auth error (email exists, weak password, etc.)
      throw AppAuthException(e.message);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw ServerException('Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AppAuthException('Logout failed: $e');
    }
  }

  @override
  UserModel? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return UserModel.fromAuthUser(
      user.id,
      user.email ?? '',
      user.userMetadata,
    );
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;

      return UserModel.fromAuthUser(
        user.id,
        user.email ?? '',
        user.userMetadata,
      );
    });
  }
}
