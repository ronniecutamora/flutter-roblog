import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({String? displayName, String? avatarPath});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient client;

  ProfileRemoteDataSourceImpl({required this.client});

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
      String? avatarUrl;

      if (avatarPath != null) {
        avatarUrl = await _uploadAvatar(avatarPath);
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

  /// Uploads an avatar image to Supabase Storage and returns the public URL.
  ///
  /// Handles both web and native platforms with proper MIME type specification.
  /// Path format: {userId}/{userId}_{timestamp}.{ext}
  Future<String> _uploadAvatar(String avatarPath) async {
    final fileExt = avatarPath.split('.').last.toLowerCase();
    final userId = client.auth.currentUser!.id;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${userId}_$timestamp.$fileExt';
    final storagePath = '$userId/$fileName';
    final contentType = _getMimeType(fileExt);

    if (kIsWeb) {
      // Web: Use XFile to read bytes and uploadBinary with content type
      final xFile = XFile(avatarPath);
      final bytes = await xFile.readAsBytes();
      await client.storage.from(ApiEndpoints.blogImagesBucket).uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: contentType),
          );
    } else {
      // Native: Use File with content type
      final file = File(avatarPath);
      await client.storage.from(ApiEndpoints.blogImagesBucket).upload(
            storagePath,
            file,
            fileOptions: FileOptions(contentType: contentType),
          );
    }

    return client.storage
        .from(ApiEndpoints.blogImagesBucket)
        .getPublicUrl(storagePath);
  }

  /// Returns the MIME type for common image extensions.
  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/jpeg'; // Default to JPEG for unknown extensions
    }
  }
}