import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/di/injection.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers.dart';
import '../bloc/comments_bloc.dart';
import '../bloc/comments_event.dart';
import '../bloc/comments_state.dart';

class CommentsSection extends StatelessWidget {
  final String blogId;

  const CommentsSection({super.key, required this.blogId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CommentsBloc>()..add(LoadCommentsEvent(blogId: blogId)),
      child: _CommentsSectionBody(blogId: blogId),
    );
  }
}

class _CommentsSectionBody extends StatefulWidget {
  final String blogId;

  const _CommentsSectionBody({required this.blogId});

  @override
  State<_CommentsSectionBody> createState() => _CommentsSectionBodyState();
}

class _CommentsSectionBodyState extends State<_CommentsSectionBody> {
  final _controller = TextEditingController();
  String? _imagePath;
  Uint8List? _imageBytes; // For web preview

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imagePath = picked.path;
          _imageBytes = bytes;
        });
      } else {
        setState(() => _imagePath = picked.path);
      }
    }
  }

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<CommentsBloc>().add(
          AddCommentEvent(
            blogId: widget.blogId,
            content: text,
            imagePath: _imagePath,
          ),
        );
    _controller.clear();
    setState(() {
      _imagePath = null;
      _imageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            AppStrings.comments,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Comment input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              if (_imagePath != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.memory(
                              _imageBytes!,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_imagePath!),
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _imagePath = null;
                          _imageBytes = null;
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: AppStrings.addComment,
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _submitComment,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Comments list
        BlocConsumer<CommentsBloc, CommentsState>(
          listener: (context, state) {
            if (state is CommentAdded) {
              Helpers.showSnackBar(context, 'Comment added!');
            } else if (state is CommentsError) {
              Helpers.showSnackBar(context, state.message, isError: true);
            }
          },
          builder: (context, state) {
            if (state is CommentsLoading) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is CommentsLoaded) {
              if (state.comments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text(AppStrings.noComments)),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.comments.length,
                itemBuilder: (context, index) {
                  final comment = state.comments[index];
                  final isOwner = comment.authorId == currentUserId;

                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(comment.content),
                        if (comment.imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: comment.imageUrl!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(Helpers.formatDate(comment.createdAt)),
                    trailing: isOwner
                        ? IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () {
                              context.read<CommentsBloc>().add(
                                    DeleteCommentEvent(
                                      id: comment.id,
                                      blogId: widget.blogId,
                                    ),
                                  );
                            },
                          )
                        : null,
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