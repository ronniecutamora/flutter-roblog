import '../../../../core/errors/failures.dart';
import '../entities/post.dart';

/// Contract for blog post operations.
///
/// Defines WHAT the posts system can do.
/// Implemented by [PostsRepositoryImpl] in the data layer.
abstract class PostsRepository {
  /// Fetches all posts, ordered by creation date (newest first).
  ///
  /// Returns:
  /// - `(List<Post>, null)` on success
  /// - `(null, ServerFailure)` on error
  Future<(List<Post>?, Failure?)> getPosts();

  /// Fetches a single post by ID.
  ///
  /// Returns:
  /// - `(Post, null)` on success
  /// - `(null, ServerFailure)` on error
  Future<(Post?, Failure?)> getPostById(String id);

  /// Creates a new post.
  ///
  /// [title] - Post title
  /// [content] - Post body
  /// [imagePath] - Optional local path to image file
  ///
  /// Returns:
  /// - `(Post, null)` on success with the created post
  /// - `(null, ServerFailure)` on error
  Future<(Post?, Failure?)> createPost({
    required String title,
    required String content,
    String? imagePath,
  });

  /// Updates an existing post.
  ///
  /// [id] - Post ID to update
  /// [title] - New title
  /// [content] - New content
  /// [imagePath] - Optional new image (null to keep existing)
  ///
  /// Returns:
  /// - `(Post, null)` on success with the updated post
  /// - `(null, ServerFailure)` on error
  Future<(Post?, Failure?)> updatePost({
    required String id,
    required String title,
    required String content,
    String? imagePath,
  });

  /// Deletes a post by ID.
  ///
  /// Returns:
  /// - `null` on success
  /// - `Failure` on error
  Future<Failure?> deletePost(String id);
}
