import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of [AuthRepository] using [AuthRemoteDataSource].
///
/// This class acts as a bridge between the domain and data layers:
/// - Calls data source methods
/// - Catches exceptions and converts them to failures
/// - Returns clean result tuples to the domain layer
///
/// ## Error Handling Pattern
///
/// ```dart
/// try {
///   final result = await dataSource.someMethod();
///   return (result, null);  // Success
/// } on AppAuthException catch (e) {
///   return (null, AuthFailure(e.message));  // Auth error
/// } catch (e) {
///   return (null, ServerFailure(e.toString()));  // Other error
/// }
/// ```
class AuthRepositoryImpl implements AuthRepository {
  /// The data source for authentication operations.
  final AuthRemoteDataSource _remoteDataSource;

  /// Creates an [AuthRepositoryImpl] with the given [remoteDataSource].
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<(AppUser?, Failure?)> login(String email, String password) async {
    try {
      final user = await _remoteDataSource.login(email, password);
      return (user, null);
    } on AppAuthException catch (e) {
      return (null, AuthFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<(AppUser?, Failure?)> register(String email, String password) async {
    try {
      final user = await _remoteDataSource.register(email, password);
      return (user, null);
    } on AppAuthException catch (e) {
      return (null, AuthFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> logout() async {
    try {
      await _remoteDataSource.logout();
      return null;
    } on AppAuthException catch (e) {
      return AuthFailure(e.message);
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  AppUser? get currentUser => _remoteDataSource.currentUser;

  @override
  Stream<AppUser?> get authStateChanges => _remoteDataSource.authStateChanges;
}
