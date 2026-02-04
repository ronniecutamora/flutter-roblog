import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Splash screen shown on app startup.
///
/// Responsibilities:
/// - Display app branding while checking auth status
/// - Redirect to appropriate screen based on auth state
///
/// ## Navigation Flow
///
/// ```
/// SplashPage
///     ↓ (check auth)
/// Authenticated? → HomePage (/)
/// Unauthenticated? → LoginPage (/login)
/// ```
class SplashPage extends StatefulWidget {
  /// Creates a [SplashPage].
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Check authentication status when page loads
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // User is logged in, go to home
          context.go('/');
        } else if (state is Unauthenticated) {
          // User is not logged in, go to login
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo/icon
              const Icon(
                Icons.article_rounded,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              // App name
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              // Loading indicator
              const CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
