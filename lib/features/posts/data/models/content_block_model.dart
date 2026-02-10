import '../../domain/entities/content_block.dart';

/// Model for serializing/deserializing content blocks to/from JSON.
///
/// JSON format:
/// ```json
/// {
///   "id": "block_1",
///   "type": "text",
///   "order": 0,
///   "text": "Hello world"
/// }
/// ```
/// or
/// ```json
/// {
///   "id": "block_2",
///   "type": "image",
///   "order": 1,
///   "image_url": "https://...",
///   "caption": "My photo"
/// }
/// ```
class ContentBlockModel {
  /// Block type identifiers.
  static const String typeText = 'text';
  static const String typeImage = 'image';

  /// Parses a JSON map into a ContentBlock entity.
  static ContentBlock fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final id = json['id'] as String;
    final order = json['order'] as int;

    switch (type) {
      case typeText:
        return TextBlock(
          id: id,
          order: order,
          text: json['text'] as String? ?? '',
        );
      case typeImage:
        return ImageBlock(
          id: id,
          order: order,
          imageUrl: json['image_url'] as String?,
          caption: json['caption'] as String?,
        );
      default:
        // Unknown type, treat as empty text block
        return TextBlock(id: id, order: order, text: '');
    }
  }

  /// Converts a ContentBlock entity to a JSON map.
  static Map<String, dynamic> toJson(ContentBlock block) {
    final base = {
      'id': block.id,
      'order': block.order,
    };

    switch (block) {
      case TextBlock():
        return {
          ...base,
          'type': typeText,
          'text': block.text,
        };
      case ImageBlock():
        return {
          ...base,
          'type': typeImage,
          'image_url': block.imageUrl,
          'caption': block.caption,
        };
    }
  }

  /// Parses a list of JSON objects into ContentBlock entities.
  static List<ContentBlock> fromJsonList(List<dynamic>? jsonList) {
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }
    return jsonList
        .map((json) => fromJson(json as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Converts a list of ContentBlock entities to JSON.
  static List<Map<String, dynamic>> toJsonList(List<ContentBlock> blocks) {
    return blocks.map(toJson).toList();
  }

  /// Extracts all image URLs from a list of blocks.
  static List<String> extractImageUrls(List<ContentBlock> blocks) {
    return blocks
        .whereType<ImageBlock>()
        .where((block) => block.imageUrl != null)
        .map((block) => block.imageUrl!)
        .toList();
  }

  /// Counts image blocks in a list.
  static int countImages(List<ContentBlock> blocks) {
    return blocks.whereType<ImageBlock>().length;
  }
}