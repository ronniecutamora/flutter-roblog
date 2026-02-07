import 'package:equatable/equatable.dart';

/// Represents a blog post.
class Post extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields - from profiles table
  final String? authorName;
  final String? authorAvatarUrl;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatarUrl,
  });

  @override
  List<Object?> get props =>
      [id, title, content, authorId, imageUrl, createdAt, updatedAt, authorName];
}