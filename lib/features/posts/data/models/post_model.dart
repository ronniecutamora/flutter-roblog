import '../../domain/entities/post.dart';

/// Data model for [Post] with JSON serialization.
class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorId,
    super.imageUrl,
    required super.createdAt,
    required super.updatedAt,
    super.authorName,
    super.authorAvatarUrl,
  });

  /// Creates a [PostModel] from JSON.
  ///
  /// Expects joined data from profiles table:
  /// ```json
  /// {
  ///   "id": "...",
  ///   "profiles": { "display_name": "...", "avatar_url": "..." }
  /// }
  /// ```
  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Parse joined profiles data
    final profiles = json['profiles'] as Map<String, dynamic>?;

    return PostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['author_id'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      authorName: profiles?['display_name'] as String?,
      authorAvatarUrl: profiles?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'title': title,
      'content': content,
      'author_id': authorId,
      'image_url': imageUrl,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}