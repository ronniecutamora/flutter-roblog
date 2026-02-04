import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/di/injection.dart' as di;
import 'config/router/app_router.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application entry point.
void main() async {
  // 1. Mandatory for async work in main
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Load the file FIRST
    await dotenv.load(fileName: ".env");
    
    // 3. Initialize Supabase ONLY after load is done
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );

    // 4. Then do your DI
    await di.init();

    runApp(const MyApp());
  } catch (e) {
    // Innovative tip: Catch the error here so you know WHY it failed
    print("FATAL ERROR during startup: $e");
  }
}

/// Root application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
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
