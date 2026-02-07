import 'package:flutter/material.dart';
import 'package:flutter_roblog/core/constants/app_strings.dart';
import 'package:flutter_roblog/features/comments/domain/entities/comment.dart';
import 'comment_item.dart';

/// Widget displaying a list of comments.
///
/// Shows:
/// - Empty state when no comments
/// - List of [CommentItem] widgets
class CommentsList extends StatelessWidget {
  /// List of comments to display.
  final List<Comment> comments;

  /// ID of the current user (to show delete button for owned comments).
  final String? currentUserId;

  /// Callback when a comment's delete button is pressed.
  final void Function(Comment comment)? onDelete;

  const CommentsList({
    super.key,
    required this.comments,
    this.currentUserId,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            AppStrings.noComments,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final comment = comments[index];
        final isOwner = comment.authorId == currentUserId;

        return CommentItem(
          comment: comment,
          isOwner: isOwner,
          onDelete: isOwner ? () => onDelete?.call(comment) : null,
        );
      },
    );
  }
}