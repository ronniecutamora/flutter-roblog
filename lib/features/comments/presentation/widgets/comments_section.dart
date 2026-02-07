import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/di/injection.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers.dart';
import '../bloc/comments_bloc.dart';
import '../bloc/comments_event.dart';
import '../bloc/comments_state.dart';
// Format: import 'package:your_project_name/path/to/file.dart';
import 'package:flutter_roblog/features/comments/presentation/widgets/comment_section/comment_input.dart';
import 'package:flutter_roblog/features/comments/presentation/widgets/comment_section/comments_list.dart';

/// Section widget for displaying and managing comments on a blog post.
///
/// Provides:
/// - Comments header
/// - Input field for adding new comments
/// - List of existing comments
/// - Loading and error states
class CommentsSection extends StatelessWidget {
  /// The blog post ID to load comments for.
  final String blogId;

  const CommentsSection({super.key, required this.blogId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CommentsBloc>()..add(LoadCommentsEvent(blogId: blogId)),
      child: _CommentsSectionContent(blogId: blogId),
    );
  }
}

class _CommentsSectionContent extends StatelessWidget {
  final String blogId;

  const _CommentsSectionContent({required this.blogId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            AppStrings.comments,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CommentInput(
            onSubmit: (content, imagePath) {
              context.read<CommentsBloc>().add(
                    CreateCommentEvent(
                      blogId: blogId,
                      content: content,
                      imagePath: imagePath,
                    ),
                  );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Comments list with states
        BlocConsumer<CommentsBloc, CommentsState>(
          listener: (context, state) {
            if (state is CommentAdded) {
              Helpers.showSnackBar(context, 'Comment added!');
            } else if (state is CommentDeleted) {
              Helpers.showSnackBar(context, 'Comment deleted');
            } else if (state is CommentsError) {
              Helpers.showSnackBar(context, state.message, isError: true);
            }
          },
          builder: (context, state) {
            if (state is CommentsLoading) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is CommentsLoaded) {
              return CommentsList(
                comments: state.comments,
                currentUserId: currentUserId,
                onDelete: (comment) {
                  context.read<CommentsBloc>().add(
                        DeleteCommentEvent(
                          id: comment.id,
                          blogId: blogId,
                        ),
                      );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}