import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for user logout.
///
/// Signs out the currently authenticated user.
///
/// ## Usage
///
/// ```dart
/// final logout = Logout(authRepository);
/// final failure = await logout();
/// if (failure != null) {
///   // Handle error
/// }
/// ```
class Logout {
  /// The repository that handles actual logout.
  final AuthRepository _repository;

  /// Creates a [Logout] use case with the given [repository].
  Logout(this._repository);

  /// Executes the logout operation.
  ///
  /// Returns `null` on success, or a [Failure] if logout fails.
  Future<Failure?> call() async {
    return await _repository.logout();
  }
}
