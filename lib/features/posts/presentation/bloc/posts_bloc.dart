import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_post.dart';
import '../../domain/usecases/delete_post.dart';
import '../../domain/usecases/get_posts.dart';
import '../../domain/usecases/update_post.dart';
import 'posts_event.dart';
import 'posts_state.dart';

/// BLoC for managing posts state.
///
/// Handles:
/// - Loading posts list
/// - Creating new posts
/// - Updating existing posts
/// - Deleting posts
///
/// ## Event → State Flow
///
/// | Event | Success State | Error State |
/// |-------|---------------|-------------|
/// | [LoadPostsEvent] | [PostsLoaded] | [PostsError] |
/// | [CreatePostEvent] | [PostCreated] | [PostsError] |
/// | [UpdatePostEvent] | [PostUpdated] | [PostsError] |
/// | [DeletePostEvent] | [PostDeleted] | [PostsError] |
class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final GetPosts _getPosts;
  final CreatePost _createPost;
  final UpdatePost _updatePost;
  final DeletePost _deletePost;

  /// Creates a [PostsBloc] with the required use cases.
  PostsBloc({
    required GetPosts getPosts,
    required CreatePost createPost,
    required UpdatePost updatePost,
    required DeletePost deletePost,
  })  : _getPosts = getPosts,
        _createPost = createPost,
        _updatePost = updatePost,
        _deletePost = deletePost,
        super(const PostsInitial()) {
    on<LoadPostsEvent>(_onLoadPosts);
    on<CreatePostEvent>(_onCreatePost);
    on<UpdatePostEvent>(_onUpdatePost);
    on<DeletePostEvent>(_onDeletePost);
  }

  /// Handles [LoadPostsEvent].
  Future<void> _onLoadPosts(
    LoadPostsEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsLoading());

    final (posts, failure) = await _getPosts();

    if (failure != null) {
      emit(PostsError(message: failure.message));
    } else {
      emit(PostsLoaded(posts: posts!));
    }
  }

  /// Handles [CreatePostEvent].
  Future<void> _onCreatePost(
    CreatePostEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsLoading());

    final (post, failure) = await _createPost(
      title: event.title,
      content: event.content,
      imagePath: event.imagePath,
    );

    if (failure != null) {
      emit(PostsError(message: failure.message));
    } else {
      emit(PostCreated(post: post!));
    }
  }

  /// Handles [UpdatePostEvent].
  Future<void> _onUpdatePost(
    UpdatePostEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsLoading());

    final (post, failure) = await _updatePost(
      id: event.id,
      title: event.title,
      content: event.content,
      imagePath: event.imagePath,
    );

    if (failure != null) {
      emit(PostsError(message: failure.message));
    } else {
      emit(PostUpdated(post: post!));
    }
  }

  /// Handles [DeletePostEvent].
  Future<void> _onDeletePost(
    DeletePostEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsLoading());

    final failure = await _deletePost(id: event.id);

    if (failure != null) {
      emit(PostsError(message: failure.message));
    } else {
      emit(const PostDeleted());
    }
  }
}
