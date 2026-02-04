import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';

/// App router configuration using go_router.
///
/// For now, only auth routes are configured.
/// Posts, comments, and profile routes will be added later.
class AppRouter {
  AppRouter._();

  /// Global navigator key.
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Returns the configured [GoRouter] instance.
  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
      final currentPath = state.matchedLocation;

      // Allow splash to load
      if (currentPath == '/splash') return null;

      // Auth routes
      final isAuthRoute = currentPath == '/login' || currentPath == '/register';

      // Not logged in and trying to access protected route
      if (!isLoggedIn && !isAuthRoute) return '/login';

      // Logged in but on auth route - redirect to home
      // For now, redirect back to login since home doesn't exist yet
      if (isLoggedIn && isAuthRoute) return '/home';

      return null;
    },
    routes: [
      // Splash - initial route
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      // Register
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Temporary home route for testing
      GoRoute(
        path: '/home',
        builder: (context, state) => const _TempHomePage(),
      ),
    ],
  );
}

/// Temporary home page for testing auth flow.
///
/// Will be replaced with actual HomePage in Step 7.
class _TempHomePage extends StatelessWidget {
  const _TempHomePage();

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Home (Temp)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text('Auth works!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text('Logged in as: ${user?.email ?? 'Unknown'}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  GoRouter.of(context).go('/login');
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
