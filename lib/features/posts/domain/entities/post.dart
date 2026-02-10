import 'package:equatable/equatable.dart';

import 'content_block.dart';

/// Represents a blog post with block-based content.
///
/// Content is stored as a list of [ContentBlock] which can be
/// text blocks or image blocks, allowing flexible content layout.
class Post extends Equatable {
  final String id;
  final String title;
  final String authorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Block-based content (text and images).
  final List<ContentBlock> contentBlocks;

  // Joined fields - from profiles table
  final String? authorName;
  final String? authorAvatarUrl;

  const Post({
    required this.id,
    required this.title,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
    this.contentBlocks = const [],
    this.authorName,
    this.authorAvatarUrl,
  });

  /// Extracts all text content as a single string (for preview/search).
  String get plainTextContent {
    return contentBlocks
        .whereType<TextBlock>()
        .map((block) => block.text)
        .join('\n\n');
  }

  /// Gets the first image URL (for thumbnail/card preview).
  String? get thumbnailUrl {
    final imageBlock = contentBlocks
        .whereType<ImageBlock>()
        .where((block) => block.imageUrl != null)
        .firstOrNull;
    return imageBlock?.imageUrl;
  }

  /// Extracts all image URLs from content blocks.
  List<String> get imageUrls {
    return contentBlocks
        .whereType<ImageBlock>()
        .where((block) => block.imageUrl != null)
        .map((block) => block.imageUrl!)
        .toList();
  }

  /// Number of images in the post.
  int get imageCount {
    return contentBlocks.whereType<ImageBlock>().length;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        authorId,
        createdAt,
        updatedAt,
        contentBlocks,
        authorName,
        authorAvatarUrl,
      ];
}