import '../../../../core/errors/failures.dart';
import '../entities/content_block.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

/// Use case for updating an existing post with block-based content.
///
/// ## Usage
///
/// ```dart
/// final updatePost = UpdatePost(postsRepository);
/// final (post, failure) = await updatePost(
///   id: 'abc-123',
///   title: 'Updated Title',
///   contentBlocks: [
///     TextBlock(id: '1', order: 0, text: 'Updated text'),
///   ],
/// );
/// ```
class UpdatePost {
  final PostsRepository _repository;

  /// Creates an [UpdatePost] use case.
  UpdatePost(this._repository);

  /// Executes the use case.
  ///
  /// [id] - Post ID to update
  /// [title] - New title
  /// [contentBlocks] - Updated content blocks
  Future<(Post?, Failure?)> call({
    required String id,
    required String title,
    required List<ContentBlock> contentBlocks,
  }) async {
    return await _repository.updatePost(
      id: id,
      title: title,
      contentBlocks: contentBlocks,
    );
  }
}