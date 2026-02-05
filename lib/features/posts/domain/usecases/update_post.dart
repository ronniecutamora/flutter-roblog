import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

/// Use case for updating an existing post.
///
/// ## Usage
///
/// ```dart
/// final updatePost = UpdatePost(postsRepository);
/// final (post, failure) = await updatePost(
///   id: 'abc-123',
///   title: 'Updated Title',
///   content: 'Updated content...',
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
  /// [content] - New content
  /// [imagePath] - Optional new image path
  Future<(Post?, Failure?)> call({
    required String id,
    required String title,
    required String content,
    String? imagePath,
  }) async {
    return await _repository.updatePost(
      id: id,
      title: title,
      content: content,
      imagePath: imagePath,
    );
  }
}
