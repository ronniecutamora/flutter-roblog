import 'package:equatable/equatable.dart';

/// Represents a blog post in the Roblog application.
///
/// This is a **domain entity** - a pure Dart class defining
/// what a post IS in business terms.
///
/// Maps to the `blogs` table in Supabase.
class Post extends Equatable {
  /// Unique identifier (UUID from Supabase).
  final String id;

  /// Post title.
  final String title;

  /// Post content/body.
  final String content;

  /// ID of the user who created the post.
  final String authorId;

  /// Optional image URL for the post.
  final String? imageUrl;

  /// When the post was created.
  final DateTime createdAt;

  /// When the post was last updated.
  final DateTime updatedAt;

  /// Creates a [Post] instance.
  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        authorId,
        imageUrl,
        createdAt,
        updatedAt,
      ];
}
