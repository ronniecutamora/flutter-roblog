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
/// Listens for [PostUpdated] state to refresh the displayed post
/// after editing.
class PostDetailPage extends StatefulWidget {
  /// The initial post to display.
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  /// Current post data (may be updated after edit).
  late Post _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwner = _post.authorId == currentUserId;

    return BlocListener<PostsBloc, PostsState>(
      listener: (context, state) {
        if (state is PostDeleted) {
          Helpers.showSnackBar(context, 'Post deleted');
          context.pop();
        } else if (state is PostUpdated) {
          // Update displayed post when edited
          if (state.post.id == _post.id) {
            setState(() {
              _post = state.post;
            });
            Helpers.showSnackBar(context, 'Post updated!');
          }
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
                  '/edit-post/${_post.id}',
                  extra: _post,
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
              if (_post.imageUrl != null)
                CachedNetworkImage(
                  imageUrl: _post.imageUrl!,
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
                      _post.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Date
                    Text(
                      Helpers.formatDate(_post.createdAt),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Content
                    Text(
                      _post.content,
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
      context.read<PostsBloc>().add(DeletePostEvent(id: _post.id));
    }
  }
}
