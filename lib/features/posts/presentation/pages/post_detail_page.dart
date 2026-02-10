import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_roblog/features/comments/presentation/widgets/comments_section.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/content_block.dart';
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
              // ─── Header ─────────────────────────────────────────────────
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

                    // Author info row
                    Row(
                      children: [
                        // Author avatar
                        if (_post.authorAvatarUrl != null)
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: CachedNetworkImageProvider(
                              _post.authorAvatarUrl!,
                            ),
                          )
                        else
                          const CircleAvatar(
                            radius: 16,
                            child: Icon(Icons.person, size: 18),
                          ),
                        const SizedBox(width: 10),
                        // Author name and date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_post.authorName != null)
                              Text(
                                _post.authorName!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            Text(
                              Helpers.formatDate(_post.createdAt),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ─── Content Blocks ─────────────────────────────────────────
              ..._post.contentBlocks.map((block) => _buildContentBlock(block)),

              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CommentsSection(blogId: _post.id),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a widget for a content block.
  Widget _buildContentBlock(ContentBlock block) {
    switch (block) {
      case TextBlock():
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            block.text,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        );
      case ImageBlock():
        if (block.imageUrl == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: block.imageUrl!,
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
              if (block.caption != null && block.caption!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    block.caption!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        );
    }
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