import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login.
///
/// Encapsulates the login business logic in a single, testable class.
///
/// ## Why Use Cases?
///
/// - **Single Responsibility**: One class = one action
/// - **Testable**: Easy to mock the repository
/// - **Reusable**: Can be called from BLoC, or any other presentation layer
/// - **Clean**: BLoC doesn't know about repository details
///
/// ## Usage
///
/// ```dart
/// final login = Login(authRepository);
/// final (user, failure) = await login(email: 'test@example.com', password: '123456');
/// ```
class Login {
  /// The repository that handles actual authentication.
  final AuthRepository _repository;

  /// Creates a [Login] use case with the given [repository].
  Login(this._repository);

  /// Executes the login operation.
  ///
  /// [email] - User's email address
  /// [password] - User's password
  ///
  /// Returns a record with either the authenticated [AppUser] or a [Failure].
  Future<(AppUser?, Failure?)> call({
    required String email,
    required String password,
  }) async {
    return await _repository.login(email, password);
  }
}
