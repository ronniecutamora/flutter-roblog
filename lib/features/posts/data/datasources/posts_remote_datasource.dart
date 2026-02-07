import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/post_model.dart';

/// Contract for posts data operations.
abstract class PostsRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<PostModel> getPostById(String id);
  Future<PostModel> createPost({
    required String title,
    required String content,
    String? imagePath,
  });
  Future<PostModel> updatePost({
    required String id,
    required String title,
    required String content,
    String? imagePath,
  });
  Future<void> deletePost(String id);
}

/// Implementation of [PostsRemoteDataSource] using Supabase.
class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final SupabaseClient _client;

  PostsRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  String get _currentUserId {
    final user = _client.auth.currentUser;
    if (user == null) throw AppAuthException('Not authenticated');
    return user.id;
  }

  /// Select query with joined profiles data for author info.
  static const String _selectWithProfiles =
      '*, profiles!author_id(display_name, avatar_url)';

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _client
          .from(ApiEndpoints.blogsTable)
          .select(_selectWithProfiles)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch posts: $e');
    }
  }

  @override
  Future<PostModel> getPostById(String id) async {
    try {
      final response = await _client
          .from(ApiEndpoints.blogsTable)
          .select(_selectWithProfiles)
          .eq('id', id)
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to fetch post: $e');
    }
  }

  @override
  Future<PostModel> createPost({
    required String title,
    required String content,
    String? imagePath,
  }) async {
    try {
      final userId = _currentUserId;
      String? imageUrl;

      if (imagePath != null) {
        imageUrl = await _uploadImage(imagePath, userId);
      }

      final response = await _client
          .from(ApiEndpoints.blogsTable)
          .insert({
            'title': title,
            'content': content,
            'author_id': userId,
            'image_url': imageUrl,
          })
          .select(_selectWithProfiles)
          .single();

      return PostModel.fromJson(response);
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to create post: $e');
    }
  }

  @override
  Future<PostModel> updatePost({
    required String id,
    required String title,
    required String content,
    String? imagePath,
  }) async {
    try {
      final userId = _currentUserId;
      String? imageUrl;

      if (imagePath != null) {
        // Fetch existing post to delete old image before uploading new one
        final existingPost = await getPostById(id);
        if (existingPost.imageUrl != null) {
          await _deleteImage(existingPost.imageUrl!);
        }
        imageUrl = await _uploadImage(imagePath, userId);
      }

      final updateData = <String, dynamic>{
        'title': title,
        'content': content,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (imageUrl != null) {
        updateData['image_url'] = imageUrl;
      }

      final response = await _client
          .from(ApiEndpoints.blogsTable)
          .update(updateData)
          .eq('id', id)
          .select(_selectWithProfiles)
          .single();

      return PostModel.fromJson(response);
    } on AppAuthException {
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(String id) async {
    try {
      // Fetch post to get image URL before deleting
      final post = await getPostById(id);

      // Delete image from storage if exists
      if (post.imageUrl != null) {
        await _deleteImage(post.imageUrl!);
      }

      await _client.from(ApiEndpoints.blogsTable).delete().eq('id', id);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to delete post: $e');
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
      // URL format: .../storage/v1/object/public/blog-images/posts/userId/filename.jpg
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