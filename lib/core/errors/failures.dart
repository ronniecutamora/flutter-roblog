import 'package:equatable/equatable.dart';

/// Base class for all failure types in the domain layer.
///
/// Failures represent errors that can be shown to users.
/// They are returned from repositories instead of throwing exceptions.
///
/// Uses [Equatable] for easy comparison in tests and BLoC states.
///
/// Pattern: Repository catches exceptions and returns failures:
/// ```dart
/// try {
///   final data = await dataSource.getData();
///   return (data, null);
/// } on ServerException catch (e) {
///   return (null, ServerFailure(e.message));
/// }
/// ```
abstract class Failure extends Equatable {
  /// User-friendly error message.
  final String message;

  /// Creates a [Failure] with the given [message].
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure representing server/network errors.
class ServerFailure extends Failure {
  /// Creates a [ServerFailure] with an optional [message].
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Failure representing authentication errors.
class AuthFailure extends Failure {
  /// Creates an [AuthFailure] with an optional [message].
  const AuthFailure([super.message = 'Authentication failed']);
}

/// Failure representing validation errors.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure] with the given [message].
  const ValidationFailure(super.message);
}
