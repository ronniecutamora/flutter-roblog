import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for user registration.
///
/// Creates a new user account with the provided credentials.
///
/// ## Usage
///
/// ```dart
/// final register = Register(authRepository);
/// final (user, failure) = await register(
///   email: 'new@example.com',
///   password: 'securePassword123',
/// );
/// ```
class Register {
  /// The repository that handles actual registration.
  final AuthRepository _repository;

  /// Creates a [Register] use case with the given [repository].
  Register(this._repository);

  /// Executes the registration operation.
  ///
  /// [email] - Email for the new account
  /// [password] - Password for the new account
  ///
  /// Returns a record with either the new [AppUser] or a [Failure].
  Future<(AppUser?, Failure?)> call({
    required String email,
    required String password,
  }) async {
    return await _repository.register(email, password);
  }
}
