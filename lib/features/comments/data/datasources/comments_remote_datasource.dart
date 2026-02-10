import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/repositories/storage_repository.dart';
import '../models/comment_model.dart';

/// Contract for comments data operations.
abstract class CommentsRemoteDataSource {
  Future<List<CommentModel>> getComments(String blogId);
  Future<CommentModel> createComment({
    required String blogId,
    required String content,
    List<String> imagePaths = const [],
  });
  Future<void> deleteComment(String id);
}

/// Implementation of [CommentsRemoteDataSource] using Supabase.
class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  final SupabaseClient _client;
  final StorageRepository _storage;

  CommentsRemoteDataSourceImpl({
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
  Future<CommentModel> createComment({
    required String blogId,
    required String content,
    List<String> imagePaths = const [],
  }) async {
    try {
      // Upload all images
      final imageUrls = <String>[];
      for (final path in imagePaths) {
        final url = await _storage.uploadImage(
          filePath: path,
          userEmail: _currentUserEmail,
        );
        imageUrls.add(url);
      }

      final response = await _client.from(ApiEndpoints.commentsTable).insert({
        'blog_id': blogId,
        'author_id': _currentUserId,
        'content': content,
        'image_url': imageUrls.isNotEmpty ? imageUrls.first : null, // Legacy
        'image_urls': imageUrls, // New array column
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
      // Fetch comment to get image URLs before deleting
      final response = await _client
          .from(ApiEndpoints.commentsTable)
          .select()
          .eq('id', id)
          .single();

      final comment = CommentModel.fromJson(response);

      // Delete all images from storage
      for (final imageUrl in comment.imageUrls) {
        await _storage.deleteImage(imageUrl);
      }

      await _client.from(ApiEndpoints.commentsTable).delete().eq('id', id);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to delete comment: $e');
    }
  }
}