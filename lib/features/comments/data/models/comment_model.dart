import '../../domain/entities/comment.dart';

/// Data model for [Comment] with JSON serialization.
class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.blogId,
    required super.authorId,
    required super.content,
    super.imageUrl,
    required super.createdAt,
    super.updatedAt,
    super.authorName,
    super.authorAvatarUrl,
  });

  /// Creates a [CommentModel] from JSON.
  ///
  /// Expects joined data from profiles table:
  /// ```json
  /// {
  ///   "id": "...",
  ///   "profiles": { "display_name": "...", "avatar_url": "..." }
  /// }
  /// ```
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Parse joined profiles data
    final profiles = json['profiles'] as Map<String, dynamic>?;

    return CommentModel(
      id: json['id'] as String,
      blogId: json['blog_id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      authorName: profiles?['display_name'] as String?,
      authorAvatarUrl: profiles?['avatar_url'] as String?,
    );
  }
}