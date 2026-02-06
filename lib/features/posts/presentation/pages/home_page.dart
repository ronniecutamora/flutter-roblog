import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/helpers.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import '../widgets/post_card.dart';

/// Home page displaying list of blog posts.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    final state = context.read<PostsBloc>().state;
    if (state is! PostsLoaded) {
      context.read<PostsBloc>().add(const LoadPostsEvent());
    }
  }

  Future<void> _onRefresh() async {
    context.read<PostsBloc>().add(const LoadPostsEvent());
    await context.read<PostsBloc>().stream.firstWhere(
          (state) => state is PostsLoaded || state is PostsError,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Navigate to login when logout completes
        if (state is Unauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.appName),
        ),
        drawer: _buildDrawer(context),
        body: BlocConsumer<PostsBloc, PostsState>(
          listener: (context, state) {
            if (state is PostsError) {
              Helpers.showSnackBar(context, state.message, isError: true);
            } else if (state is PostDeleted) {
              Helpers.showSnackBar(context, 'Post deleted');
              context.read<PostsBloc>().add(const LoadPostsEvent());
            } else if (state is PostCreated) {
              context.read<PostsBloc>().add(const LoadPostsEvent());
            } else if (state is PostUpdated) {
              context.read<PostsBloc>().add(const LoadPostsEvent());
            }
          },
          builder: (context, state) {
            if (state is PostsLoading ||
                state is PostsInitial ||
                state is PostCreated ||
                state is PostUpdated ||
                state is PostDeleted) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PostsLoaded) {
              if (state.posts.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3),
                      Icon(Icons.article_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Center(child: Text(AppStrings.noPosts)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 88),
                  itemCount: state.posts.length,
                  itemBuilder: (context, index) {
                    final post = state.posts[index];
                    return PostCard(
                      post: post,
                      onTap: () =>
                          context.push('/post/${post.id}', extra: post),
                    );
                  },
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text(AppStrings.somethingWentWrong)),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/create-post'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.article_rounded, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(AppStrings.profile),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(AppStrings.logout),
            onTap: () async {
              Navigator.pop(context); // Close drawer first
              final confirm = await Helpers.showConfirmDialog(
                context,
                AppStrings.logout,
                'Are you sure you want to logout?',
              );
              if (confirm && context.mounted) {
                // Just fire the event - BlocListener will handle navigation
                context.read<AuthBloc>().add(const LogoutEvent());
              }
            },
          ),
        ],
      ),
    );
  }
}
