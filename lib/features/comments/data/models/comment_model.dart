import '../../domain/entities/comment.dart';

/// Data model for [Comment] with JSON serialization.
class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.blogId,
    required super.authorId,
    required super.content,
    required super.createdAt,
    super.updatedAt,
    super.imageUrls,
    super.authorName,
    super.authorAvatarUrl,
  });

  /// Creates a [CommentModel] from JSON.
  ///
  /// Supports both new format (image_urls array) and legacy (image_url string).
  /// Expects joined data from profiles table:
  /// ```json
  /// {
  ///   "id": "...",
  ///   "image_urls": ["url1", "url2"],
  ///   "profiles": { "display_name": "...", "avatar_url": "..." }
  /// }
  /// ```
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Parse joined profiles data
    final profiles = json['profiles'] as Map<String, dynamic>?;

    // Parse image URLs - support both new array and legacy single URL
    List<String> imageUrls = [];
    final imageUrlsJson = json['image_urls'];
    final legacyImageUrl = json['image_url'] as String?;

    if (imageUrlsJson != null && imageUrlsJson is List) {
      imageUrls = (imageUrlsJson).cast<String>();
    } else if (legacyImageUrl != null && legacyImageUrl.isNotEmpty) {
      // Fallback to legacy single image
      imageUrls = [legacyImageUrl];
    }

    return CommentModel(
      id: json['id'] as String,
      blogId: json['blog_id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      imageUrls: imageUrls,
      authorName: profiles?['display_name'] as String?,
      authorAvatarUrl: profiles?['avatar_url'] as String?,
    );
  }
}