import 'package:flutter/material.dart';
import 'package:flutter_roblog/features/profile/presentation/pages/profile_page.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/posts/domain/entities/post.dart';
import '../../features/posts/presentation/pages/home_page.dart';
import '../../features/posts/presentation/pages/create_post_page.dart';
import '../../features/posts/presentation/pages/edit_post_page.dart';
import '../../features/posts/presentation/pages/post_detail_page.dart';

/// App router configuration using go_router.
///
/// ## Routes
///
/// | Path | Page | Auth Required |
/// |------|------|---------------|
/// | /splash | SplashPage | No |
/// | /login | LoginPage | No |
/// | /register | RegisterPage | No |
/// | / | HomePage | Yes |
/// | /create-post | CreatePostPage | Yes |
/// | /post/:id | PostDetailPage | Yes |
/// | /edit-post/:id | EditPostPage | Yes |
/// | /profile | ProfilePage | Yes (Step 9) |
class AppRouter {
  AppRouter._();

  /// Global navigator key.
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Returns the configured [GoRouter] instance.
  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',

    /// Handles authentication redirects.
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
      final currentPath = state.matchedLocation;

      // Allow splash to load
      if (currentPath == '/splash') return null;

      // Auth routes that don't require login
      final isAuthRoute = currentPath == '/login' || currentPath == '/register';

      // Not logged in and trying to access protected route
      if (!isLoggedIn && !isAuthRoute) return '/login';

      // Logged in but on auth route - redirect to home
      if (isLoggedIn && isAuthRoute) return '/';

      return null;
    },

    routes: [
      // ─── Auth Routes ────────────────────────────────────────────────────────

      /// Splash screen - checks auth status on startup.
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      /// Login page.
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      /// Registration page.
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // ─── Posts Routes ───────────────────────────────────────────────────────

      /// Home page - list of posts.
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      /// Create new post.
      GoRoute(
        path: '/create-post',
        name: 'createPost',
        builder: (context, state) => const CreatePostPage(),
      ),

      /// Post detail page.
      ///
      /// Requires [Post] object via `extra`.
      /// Example: `context.push('/post/${post.id}', extra: post)`
      GoRoute(
        path: '/post/:id',
        name: 'postDetail',
        builder: (context, state) {
          final post = state.extra as Post;
          return PostDetailPage(post: post);
        },
      ),

      /// Edit post page.
      ///
      /// Requires [Post] object via `extra`.
      /// Example: `context.push('/edit-post/${post.id}', extra: post)`
      GoRoute(
        path: '/edit-post/:id',
        name: 'editPost',
        builder: (context, state) {
          final post = state.extra as Post;
          return EditPostPage(post: post);
        },
      ),

      // ─── Profile Route (placeholder for Step 9) ─────────────────────────────

      /// Profile page - will be added in Step 9.
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: ProfilePage()),
        ),
      ),
    ],
  );
}
