import '../../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';

/// Contract for authentication operations.
///
/// This is an **abstract class** (interface) that defines WHAT the auth
/// system can do, without specifying HOW it does it.
///
/// The data layer implements this with [AuthRepositoryImpl].
///
/// ## Return Type Pattern
///
/// Uses Dart 3 records `(Success?, Failure?)` instead of `Either`:
/// - First element: success value (null if failed)
/// - Second element: failure (null if succeeded)
///
/// ```dart
/// final (user, failure) = await authRepository.login(email, password);
/// if (failure != null) {
///   // Handle error
/// } else {
///   // Use user
/// }
/// ```
abstract class AuthRepository {
  /// Authenticates a user with email and password.
  ///
  /// Returns:
  /// - `(AppUser, null)` on success
  /// - `(null, AuthFailure)` on invalid credentials
  /// - `(null, ServerFailure)` on network/server error
  Future<(AppUser?, Failure?)> login(String email, String password);

  /// Creates a new user account.
  ///
  /// Returns:
  /// - `(AppUser, null)` on success
  /// - `(null, AuthFailure)` if email already exists
  /// - `(null, ServerFailure)` on network/server error
  Future<(AppUser?, Failure?)> register(String email, String password);

  /// Signs out the current user.
  ///
  /// Returns:
  /// - `null` on success
  /// - `Failure` if logout fails
  Future<Failure?> logout();

  /// Returns the currently authenticated user, or `null` if not logged in.
  AppUser? get currentUser;

  /// Stream of authentication state changes.
  ///
  /// Emits:
  /// - [AppUser] when user logs in
  /// - `null` when user logs out
  ///
  /// Useful for listening to auth changes app-wide.
  Stream<AppUser?> get authStateChanges;
}
