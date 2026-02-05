import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

/// Use case for creating a new post.
///
/// ## Usage
///
/// ```dart
/// final createPost = CreatePost(postsRepository);
/// final (post, failure) = await createPost(
///   title: 'My Post',
///   content: 'Post content...',
///   imagePath: '/path/to/image.jpg',
/// );
/// ```
class CreatePost {
  final PostsRepository _repository;

  /// Creates a [CreatePost] use case.
  CreatePost(this._repository);

  /// Executes the use case.
  ///
  /// [title] - Post title
  /// [content] - Post body
  /// [imagePath] - Optional local image path
  Future<(Post?, Failure?)> call({
    required String title,
    required String content,
    String? imagePath,
  }) async {
    return await _repository.createPost(
      title: title,
      content: content,
      imagePath: imagePath,
    );
  }
}
