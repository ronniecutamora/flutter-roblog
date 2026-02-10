import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_roblog/core/utils/helpers.dart';
import 'package:flutter_roblog/features/comments/domain/entities/comment.dart';
import 'package:flutter_roblog/features/comments/presentation/widgets/comment_image_preview.dart';

/// Widget displaying a single comment.
///
/// Shows:
/// - Author avatar and name
/// - Comment content
/// - Optional attached images (up to 5, with +N overflow)
/// - Timestamp
/// - Long press to delete (for owner)
class CommentItem extends StatelessWidget {
  /// The comment to display.
  final Comment comment;

  /// Whether the current user owns this comment.
  final bool isOwner;

  /// Callback when delete is pressed.
  final VoidCallback? onDelete;

  const CommentItem({
    super.key,
    required this.comment,
    this.isOwner = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: isOwner ? () => _showDeleteOption(context) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author avatar
            _buildAvatar(),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author name and date row
                  Row(
                    children: [
                      if (comment.authorName != null)
                        Text(
                          comment.authorName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        Helpers.formatDate(comment.createdAt),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Comment content
                  Text(
                    comment.content,
                    style: const TextStyle(fontSize: 14),
                  ),
                  // Attached images
                  if (comment.hasImages) ...[
                    const SizedBox(height: 8),
                    CommentImagesPreview(
                      imageUrls: comment.imageUrls,
                      imageHeight: 80,
                      onImageTap: (index) {
                        ImageGalleryViewer.show(
                          context,
                          imageUrls: comment.imageUrls,
                          initialIndex: index,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete Comment',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (comment.authorAvatarUrl != null) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: CachedNetworkImageProvider(comment.authorAvatarUrl!),
      );
    }
    return const CircleAvatar(
      radius: 18,
      child: Icon(Icons.person, size: 20),
    );
  }
}