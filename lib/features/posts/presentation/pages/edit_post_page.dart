import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/post.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import '../widgets/post_form.dart';

/// Page for editing an existing blog post.
class EditPostPage extends StatelessWidget {
  /// The post to edit.
  final Post post;

  const EditPostPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editPost),
      ),
      body: BlocConsumer<PostsBloc, PostsState>(
        listener: (context, state) {
          if (state is PostUpdated) {
            Helpers.showSnackBar(context, 'Post updated!');
            // Reload posts and go back
            context.read<PostsBloc>().add(const LoadPostsEvent());
            context.pop();
          } else if (state is PostsError) {
            Helpers.showSnackBar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is PostsLoading;

          return PostForm(
            initialTitle: post.title,
            initialContent: post.content,
            initialImageUrl: post.imageUrl,
            submitLabel: AppStrings.save,
            isLoading: isLoading,
            onSubmit: (title, content, imagePath) {
              context.read<PostsBloc>().add(
                    UpdatePostEvent(
                      id: post.id,
                      title: title,
                      content: content,
                      imagePath: imagePath,
                    ),
                  );
            },
          );
        },
      ),
    );
  }
}
