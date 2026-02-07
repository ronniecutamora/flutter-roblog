import 'package:flutter_roblog/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:flutter_roblog/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_roblog/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_roblog/features/profile/domain/usecases/get_profile.dart';
import 'package:flutter_roblog/features/profile/domain/usecases/update_profile.dart';
import 'package:flutter_roblog/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Core ─────────────────────────────────────────────────────────────────────
import '../../core/data/storage_repository_impl.dart';
import '../../core/repositories/storage_repository.dart';

// ─── Auth ─────────────────────────────────────────────────────────────────────
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// ─── Posts ────────────────────────────────────────────────────────────────────
import '../../features/posts/data/datasources/posts_remote_datasource.dart';
import '../../features/posts/data/repositories/posts_repository_impl.dart';
import '../../features/posts/domain/repositories/posts_repository.dart';
import '../../features/posts/domain/usecases/create_post.dart';
import '../../features/posts/domain/usecases/delete_post.dart';
import '../../features/posts/domain/usecases/get_posts.dart';
import '../../features/posts/domain/usecases/update_post.dart';
import '../../features/posts/presentation/bloc/posts_bloc.dart';

// ─── Comments ────────────────────────────────────────────────────────────────────
import '../../features/comments/data/repositories/comments_repository_impl.dart';
import '../../features/comments/data/datasources/comments_remote_datasource.dart';
import '../../features/comments/domain/repositories/comments_repository.dart';
import '../../features/comments/domain/usecases/create_comment.dart';
import '../../features/comments/domain/usecases/delete_comment.dart';
import '../../features/comments/domain/usecases/get_comments.dart';
import '../../features/comments/presentation/bloc/comments_bloc.dart';


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

  // ─── Posts Feature ──────────────────────────────────────────────────────────

  // BLoC
  sl.registerFactory(
    () => PostsBloc(
      getPosts: sl(),
      createPost: sl(),
      updatePost: sl(),
      deletePost: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetPosts(sl()));
  sl.registerLazySingleton(() => CreatePost(sl()));
  sl.registerLazySingleton(() => UpdatePost(sl()));
  sl.registerLazySingleton(() => DeletePost(sl()));

  // Repository
  sl.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<PostsRemoteDataSource>(
    () => PostsRemoteDataSourceImpl(client: sl(), storage: sl()),
  );

  // ─── Comments Feature ──────────────────────────────────────────────────────────

  // BLoC
  sl.registerFactory(
    () => CommentsBloc(
      getComments: sl(),
      createComment: sl(),
      deleteComment: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetComments(sl()));
  sl.registerLazySingleton(() => CreateComment(sl()));
  sl.registerLazySingleton(() => DeleteComment(sl()));

  // Repository
  sl.registerLazySingleton<CommentsRepository>(
    () => CommentsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<CommentsRemoteDataSource>(
    () => CommentsRemoteDataSourceImpl(client: sl(), storage: sl()),
  );

  // ─── Profile Feature ──────────────────────────────────────────────────────────

  // BLoC
  sl.registerFactory(
    () => ProfileBloc(
      getProfile: sl(), 
      updateProfile: sl(),
 
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(client: sl(), storage: sl()),
  );

  // ─── External ───────────────────────────────────────────────────────────────

  sl.registerLazySingleton(() => Supabase.instance.client);

  // ─── Core Services ─────────────────────────────────────────────────────────

  sl.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(client: sl()),
  );
}