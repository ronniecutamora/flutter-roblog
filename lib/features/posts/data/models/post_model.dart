import '../../domain/entities/content_block.dart';
import '../../domain/entities/post.dart';
import 'content_block_model.dart';

/// Data model for [Post] with JSON serialization.
class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.title,
    required super.authorId,
    required super.createdAt,
    required super.updatedAt,
    super.contentBlocks = const [],
    super.authorName,
    super.authorAvatarUrl,
  });

  /// Creates a [PostModel] from JSON.
  ///
  /// Handles both new format (content_blocks) and legacy format (content + image_url).
  /// Legacy posts are automatically converted to block format.
  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Parse joined profiles data
    final profiles = json['profiles'] as Map<String, dynamic>?;

    // Parse content blocks
    List<ContentBlock> blocks;
    final contentBlocksJson = json['content_blocks'] as List<dynamic>?;

    if (contentBlocksJson != null && contentBlocksJson.isNotEmpty) {
      // New format: parse content_blocks
      blocks = ContentBlockModel.fromJsonList(contentBlocksJson);
    } else {
      // Legacy format: convert content + image_url to blocks
      blocks = _convertLegacyContent(
        content: json['content'] as String?,
        imageUrl: json['image_url'] as String?,
      );
    }

    return PostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      authorId: json['author_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      contentBlocks: blocks,
      authorName: profiles?['display_name'] as String?,
      authorAvatarUrl: profiles?['avatar_url'] as String?,
    );
  }

  /// Converts legacy content + image_url to content blocks.
  static List<ContentBlock> _convertLegacyContent({
    String? content,
    String? imageUrl,
  }) {
    final blocks = <ContentBlock>[];
    int order = 0;

    // Add image block first if exists (like the old layout)
    if (imageUrl != null && imageUrl.isNotEmpty) {
      blocks.add(ImageBlock(
        id: 'legacy_image',
        order: order++,
        imageUrl: imageUrl,
      ));
    }

    // Add text block if content exists
    if (content != null && content.isNotEmpty) {
      blocks.add(TextBlock(
        id: 'legacy_text',
        order: order++,
        text: content,
      ));
    }

    return blocks;
  }

  /// Converts content blocks to JSON for database insert.
  Map<String, dynamic> toInsertJson(String authorId) {
    return {
      'title': title,
      'author_id': authorId,
      'content_blocks': ContentBlockModel.toJsonList(contentBlocks),
    };
  }

  /// Converts content blocks to JSON for database update.
  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'content_blocks': ContentBlockModel.toJsonList(contentBlocks),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Creates a new PostModel with updated content blocks.
  PostModel copyWith({
    String? title,
    List<ContentBlock>? contentBlocks,
  }) {
    return PostModel(
      id: id,
      title: title ?? this.title,
      authorId: authorId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      contentBlocks: contentBlocks ?? this.contentBlocks,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
    );
  }
}