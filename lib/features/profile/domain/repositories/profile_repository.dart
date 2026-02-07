import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';

abstract class ProfileRepository {
  Future<(AppUser?, Failure?)> getProfile();
  Future<(AppUser?, Failure?)> updateProfile({
    String? displayName,
    String? avatarPath,
  });
}