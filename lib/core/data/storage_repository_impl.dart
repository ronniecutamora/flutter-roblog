import 'dart:io';
import 'dart:typed_data';

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
/// - Email-based paths: {email}/{email}_{timestamp}.{ext}
/// - True upsert for replacements
class StorageRepositoryImpl implements StorageRepository {
  final SupabaseClient _client;

  StorageRepositoryImpl({required SupabaseClient client}) : _client = client;

  /// Sanitizes email for filesystem-safe directory/filename.
  String _sanitizeEmail(String email) {
    return email.replaceAll('@', '_at_').replaceAll('.', '_');
  }

  /// Extracts storage path from a public URL.
  String? _extractStoragePath(String imageUrl) {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(ApiEndpoints.blogImagesBucket);
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        return pathSegments.sublist(bucketIndex + 1).join('/');
      }
    } catch (e) {
      debugPrint('Failed to extract storage path: $e');
    }
    return null;
  }

  /// Gets file extension from XFile, handling web blob URLs properly.
  Future<String> _getFileExtension(XFile xFile, String filePath) async {
    // First try to get extension from XFile name (works on mobile and some web cases)
    final name = xFile.name;
    if (name.contains('.')) {
      final ext = name.split('.').last.toLowerCase();
      if (_isValidImageExtension(ext)) {
        return ext;
      }
    }

    // Try to get from mimeType
    final mimeType = xFile.mimeType;
    if (mimeType != null) {
      final ext = _extensionFromMimeType(mimeType);
      if (ext != null) return ext;
    }

    // Fallback: try path (works on mobile)
    if (!filePath.startsWith('blob:') && filePath.contains('.')) {
      final ext = filePath.split('.').last.toLowerCase();
      if (_isValidImageExtension(ext)) {
        return ext;
      }
    }

    // Default to jpg
    return 'jpg';
  }

  bool _isValidImageExtension(String ext) {
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'].contains(ext);
  }

  String? _extensionFromMimeType(String mimeType) {
    switch (mimeType) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/gif':
        return 'gif';
      case 'image/webp':
        return 'webp';
      case 'image/bmp':
        return 'bmp';
      case 'image/svg+xml':
        return 'svg';
      default:
        return null;
    }
  }

  /// Core upload method with platform handling.
  Future<void> _uploadToStorage({
    required Uint8List bytes,
    required String storagePath,
    required String contentType,
    bool upsert = false,
  }) async {
    await _client.storage.from(ApiEndpoints.blogImagesBucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: upsert),
        );
  }

  @override
  Future<String> uploadImage({
    required String filePath,
    required String userEmail,
  }) async {
    try {
      final xFile = XFile(filePath);
      final bytes = await xFile.readAsBytes();
      final fileExt = await _getFileExtension(xFile, filePath);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedEmail = _sanitizeEmail(userEmail);
      final fileName = '${sanitizedEmail}_$timestamp.$fileExt';
      final storagePath = '$sanitizedEmail/$fileName';
      final contentType = _getMimeType(fileExt);

      await _uploadToStorage(
        bytes: bytes,
        storagePath: storagePath,
        contentType: contentType,
        upsert: false,
      );

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
      final storagePath = _extractStoragePath(imageUrl);
      if (storagePath != null) {
        await _client.storage
            .from(ApiEndpoints.blogImagesBucket)
            .remove([storagePath]);
        debugPrint('Deleted image: $storagePath');
      }
    } catch (e) {
      debugPrint('Failed to delete image from storage: $e');
    }
  }

  @override
  Future<String> replaceImage({
    required String filePath,
    required String userEmail,
    String? oldImageUrl,
  }) async {
    try {
      // Always delete old image first if exists
      if (oldImageUrl != null) {
        await deleteImage(oldImageUrl);
      }

      // Upload new image with fresh path
      return uploadImage(filePath: filePath, userEmail: userEmail);
    } catch (e) {
      throw ServerException('Failed to replace image: $e');
    }
  }

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
        return 'image/jpeg';
    }
  }
}