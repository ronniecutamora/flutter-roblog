import '../../../../core/errors/failures.dart';
import '../repositories/posts_repository.dart';

/// Use case for deleting a post.
///
/// ## Usage
///
/// ```dart
/// final deletePost = DeletePost(postsRepository);
/// final failure = await deletePost(id: 'abc-123');
/// ```
class DeletePost {
  final PostsRepository _repository;

  /// Creates a [DeletePost] use case.
  DeletePost(this._repository);

  /// Executes the use case.
  ///
  /// [id] - Post ID to delete.
  ///
  /// Returns `null` on success, or a [Failure] on error.
  Future<Failure?> call({required String id}) async {
    return await _repository.deletePost(id);
  }
}
