import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/repositories/storage_repository.dart';
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
  final StorageRepository _storage;

  PostsRemoteDataSourceImpl({
    required SupabaseClient client,
    required StorageRepository storage,
  })  : _client = client,
        _storage = storage;

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
        imageUrl = await _storage.uploadImage(filePath: imagePath, userId: userId);
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
        imageUrl = await _storage.replaceImage(
          filePath: imagePath,
          userId: userId,
          oldImageUrl: existingPost.imageUrl,
        );
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
        await _storage.deleteImage(post.imageUrl!);
      }

      await _client.from(ApiEndpoints.blogsTable).delete().eq('id', id);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to delete post: $e');
    }
  }
}