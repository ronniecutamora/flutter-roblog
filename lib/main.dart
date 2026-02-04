import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/di/injection.dart' as di;
import 'config/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/posts/presentation/bloc/posts_bloc.dart';

/// Application entry point.
///
/// Initializes:
/// - Flutter bindings
/// - Supabase client with credentials from `--dart-define`
/// - GetIt dependency injection
///
/// Run with:
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=your_url \
///   --dart-define=SUPABASE_ANON_KEY=your_key
/// ```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with compile-time environment variables
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

/// Root widget of the Roblog application.
///
/// Provides:
/// - Global BLoC providers ([AuthBloc], [PostsBloc])
/// - Material theme configuration
/// - GoRouter navigation
class MyApp extends StatelessWidget {
  /// Creates the root application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        /// Provides authentication state management globally.
        BlocProvider(create: (_) => di.sl<AuthBloc>()),

        /// Provides posts state management globally.
        BlocProvider(create: (_) => di.sl<PostsBloc>()),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
