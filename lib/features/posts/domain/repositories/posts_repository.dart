import '../../../../core/errors/failures.dart';
import '../entities/content_block.dart';
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

  /// Creates a new post with block-based content.
  ///
  /// [title] - Post title
  /// [contentBlocks] - List of content blocks (text/image)
  ///
  /// Returns:
  /// - `(Post, null)` on success with the created post
  /// - `(null, ServerFailure)` on error
  Future<(Post?, Failure?)> createPost({
    required String title,
    required List<ContentBlock> contentBlocks,
  });

  /// Updates an existing post with block-based content.
  ///
  /// [id] - Post ID to update
  /// [title] - New title
  /// [contentBlocks] - Updated content blocks
  ///
  /// Returns:
  /// - `(Post, null)` on success with the updated post
  /// - `(null, ServerFailure)` on error
  Future<(Post?, Failure?)> updatePost({
    required String id,
    required String title,
    required List<ContentBlock> contentBlocks,
  });

  /// Deletes a post by ID.
  ///
  /// Returns:
  /// - `null` on success
  /// - `Failure` on error
  Future<Failure?> deletePost(String id);
}