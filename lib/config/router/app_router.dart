import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/posts/presentation/pages/home_page.dart';
import '../../features/posts/presentation/pages/create_post_page.dart';
import '../../features/posts/presentation/pages/edit_post_page.dart';
import '../../features/posts/presentation/pages/post_detail_page.dart';
import '../../features/posts/domain/entities/post.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

/// Configures the application's routing using [GoRouter].
///
/// Handles:
/// - Authentication-based redirects (login guard)
/// - Route definitions for all app screens
/// - Passing data between routes via [GoRouterState.extra]
///
/// Usage:
/// ```dart
/// MaterialApp.router(
///   routerConfig: AppRouter.router,
/// )
/// ```
class AppRouter {
  /// Global navigator key for accessing navigator state outside of context.
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Returns the configured [GoRouter] instance.
  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',

    /// Handles authentication redirects.
    ///
    /// - Redirects unauthenticated users to `/login`
    /// - Redirects authenticated users away from auth pages to `/`
    /// - Returns `null` to allow the navigation to proceed normally
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Not logged in and trying to access protected route
      if (!isLoggedIn && !isAuthRoute) return '/login';

      // Logged in but trying to access auth routes
      if (isLoggedIn && isAuthRoute) return '/';

      // Allow navigation
      return null;
    },

    routes: [
      /// Login page - entry point for unauthenticated users.
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      /// Registration page - create new account.
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      /// Home page - displays list of blog posts.
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      /// Create post page - form to create a new blog post.
      GoRoute(
        path: '/create-post',
        name: 'createPost',
        builder: (context, state) => const CreatePostPage(),
      ),

      /// Post detail page - displays full post with comments.
      ///
      /// Requires [Post] object passed via [GoRouterState.extra].
      ///
      /// Example:
      /// ```dart
      /// context.push('/post/${post.id}', extra: post);
      /// ```
      GoRoute(
        path: '/post/:id',
        name: 'postDetail',
        builder: (context, state) {
          final post = state.extra as Post;
          return PostDetailPage(post: post);
        },
      ),

      /// Edit post page - form to modify existing post.
      ///
      /// Requires [Post] object passed via [GoRouterState.extra].
      ///
      /// Example:
      /// ```dart
      /// context.push('/edit-post/${post.id}', extra: post);
      /// ```
      GoRoute(
        path: '/edit-post/:id',
        name: 'editPost',
        builder: (context, state) {
          final post = state.extra as Post;
          return EditPostPage(post: post);
        },
      ),

      /// Profile page - view and edit user profile.
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
