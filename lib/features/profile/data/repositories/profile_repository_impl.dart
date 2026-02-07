import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<(AppUser?, Failure?)> getProfile() async {
    try {
      final user = await remoteDataSource.getProfile();
      return (user as AppUser, null);
    } on AppAuthException catch (e) {
      return (null, AuthFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<(AppUser?, Failure?)> updateProfile({
    String? displayName,
    String? avatarPath,
  }) async {
    try {
      final user = await remoteDataSource.updateProfile(
        displayName: displayName,
        avatarPath: avatarPath,
      );
      return (user as AppUser, null);
    } on AppAuthException catch (e) {
      return (null, AuthFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }
}