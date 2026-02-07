import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating the current user's profile.
class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<(AppUser?, Failure?)> call({
    String? displayName,
    String? avatarPath,
  }) {
    return repository.updateProfile(
      displayName: displayName,
      avatarPath: avatarPath,
    );
  }
}