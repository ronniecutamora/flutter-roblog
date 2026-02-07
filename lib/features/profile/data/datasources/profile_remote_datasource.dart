import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/repositories/storage_repository.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({String? displayName, String? avatarPath});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient client;
  final StorageRepository _storage;

  ProfileRemoteDataSourceImpl({
    required this.client,
    required StorageRepository storage,
  }) : _storage = storage;

  @override
  Future<UserModel> getProfile() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw AppAuthException('Not authenticated');

      return UserModel.fromAuthUser(
        user.id,
        user.email ?? '',
        user.userMetadata,
      );
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw ServerException('Failed to get profile: $e');
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? displayName,
    String? avatarPath,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) throw AppAuthException('Not authenticated');

      String? avatarUrl;

      if (avatarPath != null) {
        // Get old avatar URL for cleanup
        final oldAvatarUrl = currentUser.userMetadata?['avatar_url'] as String?;

        // Replace old avatar with new one (deletes old if exists)
        avatarUrl = await _storage.replaceImage(
          filePath: avatarPath,
          userId: currentUser.id,
          oldImageUrl: oldAvatarUrl,
        );
      }

      final metadata = <String, dynamic>{};
      if (displayName != null) metadata['display_name'] = displayName;
      if (avatarUrl != null) metadata['avatar_url'] = avatarUrl;

      final response = await client.auth.updateUser(
        UserAttributes(data: metadata),
      );

      final user = response.user;
      if (user == null) throw ServerException('Failed to update profile');

      return UserModel.fromAuthUser(
        user.id,
        user.email ?? '',
        user.userMetadata,
      );
    } catch (e) {
      if (e is ServerException || e is AppAuthException) rethrow;
      throw ServerException('Failed to update profile: $e');
    }
  }
}