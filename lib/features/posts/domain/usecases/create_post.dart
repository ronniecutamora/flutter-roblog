import '../../../../core/errors/failures.dart';
import '../entities/content_block.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

/// Use case for creating a new post with block-based content.
///
/// ## Usage
///
/// ```dart
/// final createPost = CreatePost(postsRepository);
/// final (post, failure) = await createPost(
///   title: 'My Post',
///   contentBlocks: [
///     TextBlock(id: '1', order: 0, text: 'Hello world'),
///     ImageBlock(id: '2', order: 1, localPath: '/path/to/image.jpg'),
///   ],
/// );
/// ```
class CreatePost {
  final PostsRepository _repository;

  /// Creates a [CreatePost] use case.
  CreatePost(this._repository);

  /// Executes the use case.
  ///
  /// [title] - Post title
  /// [contentBlocks] - List of content blocks (text/image)
  Future<(Post?, Failure?)> call({
    required String title,
    required List<ContentBlock> contentBlocks,
  }) async {
    return await _repository.createPost(
      title: title,
      contentBlocks: contentBlocks,
    );
  }
}