import 'package:equatable/equatable.dart';

/// Represents a content block in a blog post.
///
/// A post is composed of multiple blocks that can be either text or images.
/// This allows for flexible content layout where images can be placed
/// anywhere within the post content.
sealed class ContentBlock extends Equatable {
  /// Unique identifier for the block within the post.
  final String id;

  /// Order/position of this block in the post.
  final int order;

  const ContentBlock({required this.id, required this.order});
}

/// A text content block containing markdown or plain text.
class TextBlock extends ContentBlock {
  /// The text content (can be markdown).
  final String text;

  const TextBlock({
    required super.id,
    required super.order,
    required this.text,
  });

  @override
  List<Object?> get props => [id, order, text];
}

/// An image content block with optional caption.
class ImageBlock extends ContentBlock {
  /// The URL of the uploaded image (null if not yet uploaded).
  final String? imageUrl;

  /// Local file path for images pending upload.
  final String? localPath;

  /// Optional caption for the image.
  final String? caption;

  const ImageBlock({
    required super.id,
    required super.order,
    this.imageUrl,
    this.localPath,
    this.caption,
  });

  /// Whether this block has a pending upload (local file not yet uploaded).
  bool get hasPendingUpload => localPath != null && imageUrl == null;

  /// Whether this block has a valid image (either uploaded or local).
  bool get hasImage => imageUrl != null || localPath != null;

  @override
  List<Object?> get props => [id, order, imageUrl, localPath, caption];
}