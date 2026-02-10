import 'package:equatable/equatable.dart';

/// Maximum number of images allowed per comment.
const int maxImagesPerComment = 5;

/// Represents a comment on a blog post.
class Comment extends Equatable {
  final String id;
  final String blogId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// List of image URLs attached to this comment.
  final List<String> imageUrls;

  // Joined fields - from profiles table
  final String? authorName;
  final String? authorAvatarUrl;

  const Comment({
    required this.id,
    required this.blogId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.imageUrls = const [],
    this.authorName,
    this.authorAvatarUrl,
  });

  /// Whether this comment has any images.
  bool get hasImages => imageUrls.isNotEmpty;

  /// Number of images in this comment.
  int get imageCount => imageUrls.length;

  /// First image URL (for backward compatibility/thumbnail).
  String? get thumbnailUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  @override
  List<Object?> get props =>
      [id, blogId, authorId, content, imageUrls, createdAt, authorName];
}