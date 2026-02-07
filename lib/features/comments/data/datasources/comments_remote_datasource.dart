import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/repositories/storage_repository.dart';
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
  final StorageRepository _storage;

  CommentsRemoteDataSourceImpl({
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
        imageUrl = await _storage.uploadImage(filePath: imagePath, userId: userId);
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
        await _storage.deleteImage(comment.imageUrl!);
      }

      await _client.from(ApiEndpoints.commentsTable).delete().eq('id', id);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to delete comment: $e');
    }
  }
}