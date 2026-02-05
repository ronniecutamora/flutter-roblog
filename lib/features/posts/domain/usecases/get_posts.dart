import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

/// Use case for fetching all posts.
///
/// Retrieves the list of blog posts from the repository.
///
/// ## Usage
///
/// ```dart
/// final getPosts = GetPosts(postsRepository);
/// final (posts, failure) = await getPosts();
/// ```
class GetPosts {
  final PostsRepository _repository;

  /// Creates a [GetPosts] use case.
  GetPosts(this._repository);

  /// Executes the use case.
  ///
  /// Returns a list of [Post] or a [Failure].
  Future<(List<Post>?, Failure?)> call() async {
    return await _repository.getPosts();
  }
}
