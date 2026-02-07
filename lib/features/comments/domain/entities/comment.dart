import 'package:equatable/equatable.dart';

/// Represents a comment on a blog post.
class Comment extends Equatable {
  final String id;
  final String blogId;
  final String authorId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Comment({
    required this.id,
    required this.blogId,
    required this.authorId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, blogId, authorId, content, imageUrl, createdAt];
}