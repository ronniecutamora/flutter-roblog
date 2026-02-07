import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

/// Use case for fetching the current user's profile.
class GetProfile {
  final ProfileRepository repository;

  GetProfile(this.repository);

  Future<(AppUser?, Failure?)> call() {
    return repository.getProfile();
  }
}