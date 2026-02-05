import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/post.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';

/// Page displaying full post details.
///
/// Features:
/// - Full post content with image
/// - Edit and delete actions (for post owner)
/// - Comments section (to be added in Step 8)
class PostDetailPage extends StatelessWidget {
  /// The post to display.
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwner = post.authorId == currentUserId;

    return BlocListener<PostsBloc, PostsState>(
      listener: (context, state) {
        if (state is PostDeleted) {
          Helpers.showSnackBar(context, 'Post deleted');
          context.pop();
        } else if (state is PostsError) {
          Helpers.showSnackBar(context, state.message, isError: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post'),
          actions: [
            if (isOwner) ...[
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push(
                  '/edit-post/${post.id}',
                  extra: post,
                ),
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Image ──────────────────────────────────────────────────
              if (post.imageUrl != null)
                CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error),
                  ),
                ),

              // ─── Content ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Date
                    Text(
                      Helpers.formatDate(post.createdAt),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Content
                    Text(
                      post.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // ─── Comments Section (placeholder for Step 8) ──────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppStrings.comments,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Comments will be added in Step 8'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows delete confirmation dialog.
  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      AppStrings.deletePost,
      AppStrings.deletePostConfirm,
    );

    if (confirm && context.mounted) {
      context.read<PostsBloc>().add(DeletePostEvent(id: post.id));
    }
  }
}
