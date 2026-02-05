import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

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

      if (imagePath != null) {
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
      await _client.from(ApiEndpoints.blogsTable).delete().eq('id', id);
    } catch (e) {
      throw ServerException('Failed to delete post: $e');
    }
  }

  /// Uploads an image to Supabase Storage.
  ///
  /// Handles both web and mobile platforms.
  Future<String> _uploadImage(String path, String userId) async {
    try {
      final fileExt = path.split('.').last;
      final fileName = '${const Uuid().v4()}.$fileExt';
      final storagePath = 'posts/$userId/$fileName';

      if (kIsWeb) {
        // Web: read bytes from XFile
        final xFile = XFile(path);
        final bytes = await xFile.readAsBytes();

        await _client.storage
            .from(ApiEndpoints.blogImagesBucket)
            .uploadBinary(storagePath, bytes);
      } else {
        // Mobile: upload file directly
        final file = File(path);
        await _client.storage
            .from(ApiEndpoints.blogImagesBucket)
            .upload(storagePath, file);
      }

      return _client.storage
          .from(ApiEndpoints.blogImagesBucket)
          .getPublicUrl(storagePath);
    } catch (e) {
      throw ServerException('Failed to upload image: $e');
    }
  }
}
