import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import '../widgets/post_form.dart';

/// Page for creating a new blog post.
class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createPost),
      ),
      body: BlocConsumer<PostsBloc, PostsState>(
        listener: (context, state) {
          if (state is PostCreated) {
            Helpers.showSnackBar(context, 'Post created!');
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
            submitLabel: AppStrings.createPost,
            isLoading: isLoading,
            onSubmit: (title, content, imagePath) {
              context.read<PostsBloc>().add(
                    CreatePostEvent(
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
