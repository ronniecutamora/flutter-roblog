import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';
import '../repositories/storage_repository.dart';

/// Supabase implementation of [StorageRepository].
///
/// Handles all image storage operations with:
/// - Cross-platform support (web and mobile)
/// - Proper MIME type specification
/// - Consistent naming pattern: {userId}/{userId}_{timestamp}.{ext}
class StorageRepositoryImpl implements StorageRepository {
  final SupabaseClient _client;

  StorageRepositoryImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<String> uploadImage({
    required String filePath,
    required String userId,
  }) async {
    try {
      final fileExt = filePath.split('.').last.toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.$fileExt';
      final storagePath = '$userId/$fileName';
      final contentType = _getMimeType(fileExt);

      if (kIsWeb) {
        // Web: read bytes from XFile
        final xFile = XFile(filePath);
        final bytes = await xFile.readAsBytes();

        await _client.storage.from(ApiEndpoints.blogImagesBucket).uploadBinary(
              storagePath,
              bytes,
              fileOptions: FileOptions(contentType: contentType),
            );
      } else {
        // Mobile: upload file directly
        final file = File(filePath);
        await _client.storage.from(ApiEndpoints.blogImagesBucket).upload(
              storagePath,
              file,
              fileOptions: FileOptions(contentType: contentType),
            );
      }

      return _client.storage
          .from(ApiEndpoints.blogImagesBucket)
          .getPublicUrl(storagePath);
    } catch (e) {
      throw ServerException('Failed to upload image: $e');
    }
  }

  @override
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract storage path from public URL
      // URL format: .../storage/v1/object/public/blog-images/{userId}/{filename}
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find the bucket name in the path and get everything after it
      final bucketIndex = pathSegments.indexOf(ApiEndpoints.blogImagesBucket);
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _client.storage
            .from(ApiEndpoints.blogImagesBucket)
            .remove([storagePath]);
      }
    } catch (e) {
      // Log but don't fail - image deletion is not critical
      debugPrint('Failed to delete image from storage: $e');
    }
  }

  @override
  Future<String> replaceImage({
    required String filePath,
    required String userId,
    String? oldImageUrl,
  }) async {
    // Delete old image if exists
    if (oldImageUrl != null) {
      await deleteImage(oldImageUrl);
    }

    // Upload new image
    return uploadImage(filePath: filePath, userId: userId);
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