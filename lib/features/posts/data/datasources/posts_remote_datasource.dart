import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/post_model.dart';

/// Contract for posts data operations.
///
/// Defines methods that interact with Supabase database and storage.
abstract class PostsRemoteDataSource {
  /// Fetches all posts ordered by creation date (newest first).
  Future<List<PostModel>> getPosts();

  /// Fetches a single post by ID.
  Future<PostModel> getPostById(String id);

  /// Creates a new post with optional image upload.
  Future<PostModel> createPost({
    required String title,
    required String content,
    String? imagePath,
  });

  /// Updates an existing post with optional new image.
  Future<PostModel> updatePost({
    required String id,
    required String title,
    required String content,
    String? imagePath,
  });

  /// Deletes a post by ID.
  Future<void> deletePost(String id);
}

/// Implementation of [PostsRemoteDataSource] using Supabase.
///
/// Handles:
/// - CRUD operations on the `blogs` table
/// - Image uploads to the `blog-images` storage bucket
class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final SupabaseClient _client;

  /// Creates a [PostsRemoteDataSourceImpl] with the given Supabase [client].
  PostsRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  /// Gets the current user ID or throws if not authenticated.
  String get _currentUserId {
    final user = _client.auth.currentUser;
    if (user == null) throw AppAuthException('Not authenticated');
    return user.id;
  }

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _client
          .from(ApiEndpoints.blogsTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PostModel.fromJson(json))
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
          .select()
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

      // Upload image if provided
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
          .select()
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

      // Upload new image if provided
      if (imagePath != null) {
        imageUrl = await _uploadImage(imagePath, userId);
      }

      final updateData = {
        'title': title,
        'content': content,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Only update image_url if a new image was uploaded
      if (imageUrl != null) {
        updateData['image_url'] = imageUrl;
      }

      final response = await _client
          .from(ApiEndpoints.blogsTable)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return PostModel.fromJson(response);
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(String id) async {
    try {
      await _client
          .from(ApiEndpoints.blogsTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete post: $e');
    }
  }

  /// Uploads an image to Supabase Storage and returns the public URL.
  ///
  /// [localPath] - Path to the local image file
  /// [userId] - User ID for organizing uploads
  ///
  /// Returns the public URL of the uploaded image.
  Future<String> _uploadImage(String localPath, String userId) async {
    try {
      final file = File(localPath);
      final fileExt = localPath.split('.').last;
      final fileName = '${const Uuid().v4()}.$fileExt';
      final storagePath = 'posts/$userId/$fileName';

      await _client.storage
          .from(ApiEndpoints.blogImagesBucket)
          .upload(storagePath, file);

      final imageUrl = _client.storage
          .from(ApiEndpoints.blogImagesBucket)
          .getPublicUrl(storagePath);

      return imageUrl;
    } catch (e) {
      throw ServerException('Failed to upload image: $e');
    }
  }
}
