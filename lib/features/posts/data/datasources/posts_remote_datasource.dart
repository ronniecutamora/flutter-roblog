import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/repositories/storage_repository.dart';
import '../../domain/entities/content_block.dart';
import '../models/content_block_model.dart';
import '../models/post_model.dart';

/// Contract for posts data operations.
abstract class PostsRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<PostModel> getPostById(String id);
  Future<PostModel> createPost({
    required String title,
    required List<ContentBlock> contentBlocks,
  });
  Future<PostModel> updatePost({
    required String id,
    required String title,
    required List<ContentBlock> contentBlocks,
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

  User get _currentUser {
    final user = _client.auth.currentUser;
    if (user == null) throw AppAuthException('Not authenticated');
    return user;
  }

  String get _currentUserId => _currentUser.id;
  String get _currentUserEmail => _currentUser.email ?? _currentUser.id;

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
    required List<ContentBlock> contentBlocks,
  }) async {
    try {
      // Upload all pending images and get updated blocks
      final uploadedBlocks = await _uploadPendingImages(contentBlocks);

      // Extract plain text and first image for legacy columns
      final plainText = _extractPlainText(uploadedBlocks);
      final firstImageUrl = _extractFirstImageUrl(uploadedBlocks);

      final response = await _client
          .from(ApiEndpoints.blogsTable)
          .insert({
            'title': title,
            'author_id': _currentUserId,
            'content': plainText, // Legacy column (NOT NULL)
            'image_url': firstImageUrl, // Legacy column
            'content_blocks': ContentBlockModel.toJsonList(uploadedBlocks),
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
    required List<ContentBlock> contentBlocks,
  }) async {
    try {
      // Fetch existing post to compare images
      final existingPost = await getPostById(id);
      final existingImageUrls = existingPost.imageUrls.toSet();

      // Upload pending images and get updated blocks
      final uploadedBlocks = await _uploadPendingImages(contentBlocks);

      // Find new image URLs after upload
      final newImageUrls = uploadedBlocks
          .whereType<ImageBlock>()
          .where((b) => b.imageUrl != null)
          .map((b) => b.imageUrl!)
          .toSet();

      // Delete removed images
      final removedUrls = existingImageUrls.difference(newImageUrls);
      for (final url in removedUrls) {
        await _storage.deleteImage(url);
      }

      // Extract plain text and first image for legacy columns
      final plainText = _extractPlainText(uploadedBlocks);
      final firstImageUrl = _extractFirstImageUrl(uploadedBlocks);

      final response = await _client
          .from(ApiEndpoints.blogsTable)
          .update({
            'title': title,
            'content': plainText, // Legacy column (NOT NULL)
            'image_url': firstImageUrl, // Legacy column
            'content_blocks': ContentBlockModel.toJsonList(uploadedBlocks),
            'updated_at': DateTime.now().toIso8601String(),
          })
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
      // Fetch post to get all image URLs before deleting
      final post = await getPostById(id);

      // Delete all images from storage
      for (final imageUrl in post.imageUrls) {
        await _storage.deleteImage(imageUrl);
      }

      await _client.from(ApiEndpoints.blogsTable).delete().eq('id', id);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to delete post: $e');
    }
  }

  /// Uploads pending images in blocks and returns updated blocks with URLs.
  Future<List<ContentBlock>> _uploadPendingImages(
    List<ContentBlock> blocks,
  ) async {
    final result = <ContentBlock>[];

    for (final block in blocks) {
      if (block is ImageBlock && block.hasPendingUpload) {
        // Upload the local file
        final imageUrl = await _storage.uploadImage(
          filePath: block.localPath!,
          userEmail: _currentUserEmail,
        );
        // Replace block with uploaded URL
        result.add(ImageBlock(
          id: block.id,
          order: block.order,
          imageUrl: imageUrl,
          caption: block.caption,
        ));
      } else {
        result.add(block);
      }
    }

    return result;
  }

  /// Extracts plain text content from blocks for legacy `content` column.
  String _extractPlainText(List<ContentBlock> blocks) {
    return blocks
        .whereType<TextBlock>()
        .map((block) => block.text)
        .join('\n\n');
  }

  /// Extracts first image URL from blocks for legacy `image_url` column.
  String? _extractFirstImageUrl(List<ContentBlock> blocks) {
    final imageBlock = blocks
        .whereType<ImageBlock>()
        .where((block) => block.imageUrl != null)
        .firstOrNull;
    return imageBlock?.imageUrl;
  }
}