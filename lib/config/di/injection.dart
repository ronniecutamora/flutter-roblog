import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes all dependencies.
///
/// Call this in main() before runApp().
Future<void> init() async {
  // ─── Auth Feature ───────────────────────────────────────────────────────────

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      login: sl(),
      register: sl(),
      logout: sl(),
      authRepository: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => Logout(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  // ─── External ───────────────────────────────────────────────────────────────

  sl.registerLazySingleton(() => Supabase.instance.client);
}
