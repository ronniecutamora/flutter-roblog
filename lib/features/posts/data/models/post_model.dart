import '../../domain/entities/post.dart';

/// Data model for [Post] with JSON serialization.
///
/// Extends the domain entity and adds methods to:
/// - Create from Supabase row (JSON map)
/// - Convert to JSON for API requests
///
/// Maps to the `blogs` table in Supabase.
class PostModel extends Post {
  /// Creates a [PostModel] instance.
  const PostModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorId,
    super.imageUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [PostModel] from a Supabase row (JSON map).
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "id": "uuid",
  ///   "title": "Post Title",
  ///   "content": "Post content...",
  ///   "author_id": "user-uuid",
  ///   "image_url": "https://...",
  ///   "created_at": "2024-01-01T00:00:00Z",
  ///   "updated_at": "2024-01-01T00:00:00Z"
  /// }
  /// ```
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['author_id'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this [PostModel] to a JSON map for API requests.
  ///
  /// Note: `id`, `created_at`, `updated_at` are excluded as they
  /// are managed by Supabase.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'author_id': authorId,
      'image_url': imageUrl,
    };
  }

  /// Creates a copy of this [PostModel] with updated fields.
  PostModel copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
