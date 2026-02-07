import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/comment_model.dart';

/// Contract for comments data operations.
abstract class CommentsRemoteDataSource {
  Future<List<CommentModel>> getComments(String blogId);
  Future<CommentModel> createComment(String blogId, String content, String? imagePath);
  Future<void> deleteComment(String id);
}

/// Implementation of [CommentsRemoteDataSource] using Supabase.
class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  final SupabaseClient _client;

  CommentsRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  String get _currentUserId {
    final user = _client.auth.currentUser;
    if (user == null) throw AppAuthException('Not authenticated');
    return user.id;
  }

  /// Select query with joined profiles data for author info.
  static const String _selectWithProfiles =
      '*, profiles!author_id(display_name, avatar_url)';

  @override
  Future<List<CommentModel>> getComments(String blogId) async {
    try {
      final response = await _client
          .from(ApiEndpoints.commentsTable)
          .select(_selectWithProfiles)
          .eq('blog_id', blogId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to load comments: $e');
    }
  }

  @override
  Future<CommentModel> createComment(
      String blogId, String content, String? imagePath) async {
    try {
      final userId = _currentUserId;
      String? imageUrl;

      if (imagePath != null) {
        imageUrl = await _uploadImage(imagePath, userId);
      }

      final response = await _client.from(ApiEndpoints.commentsTable).insert({
        'blog_id': blogId,
        'author_id': userId,
        'content': content,
        'image_url': imageUrl,
      }).select(_selectWithProfiles).single();

      return CommentModel.fromJson(response);
    } on AppAuthException {
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to add comment: $e');
    }
  }

  @override
  Future<void> deleteComment(String id) async {
    try {
      // Fetch comment to get image URL before deleting
      final response = await _client
          .from(ApiEndpoints.commentsTable)
          .select()
          .eq('id', id)
          .single();

      final comment = CommentModel.fromJson(response);

      // Delete image from storage if exists
      if (comment.imageUrl != null) {
        await _deleteImage(comment.imageUrl!);
      }

      await _client.from(ApiEndpoints.commentsTable).delete().eq('id', id);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to delete comment: $e');
    }
  }

  /// Uploads an image to Supabase Storage.
  ///
  /// Handles both web and mobile platforms with proper MIME type specification.
  /// Path format: {userId}/{userId}_{timestamp}.{ext}
  Future<String> _uploadImage(String path, String userId) async {
    try {
      final fileExt = path.split('.').last.toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.$fileExt';
      final storagePath = '$userId/$fileName';
      final contentType = _getMimeType(fileExt);

      if (kIsWeb) {
        // Web: read bytes from XFile
        final xFile = XFile(path);
        final bytes = await xFile.readAsBytes();

        await _client.storage.from(ApiEndpoints.blogImagesBucket).uploadBinary(
              storagePath,
              bytes,
              fileOptions: FileOptions(contentType: contentType),
            );
      } else {
        // Mobile: upload file directly
        final file = File(path);
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

  /// Deletes an image from Supabase Storage.
  ///
  /// Extracts the storage path from the public URL and removes the file.
  /// Fails silently if the image cannot be deleted to avoid blocking operations.
  Future<void> _deleteImage(String imageUrl) async {
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