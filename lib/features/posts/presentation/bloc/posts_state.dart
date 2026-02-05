import 'package:equatable/equatable.dart';

import '../../domain/entities/post.dart';

/// Base class for all posts states.
abstract class PostsState extends Equatable {
  const PostsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before posts are loaded.
class PostsInitial extends PostsState {
  const PostsInitial();
}

/// State while posts are being loaded.
class PostsLoading extends PostsState {
  const PostsLoading();
}

/// State when posts are successfully loaded.
class PostsLoaded extends PostsState {
  /// List of loaded posts.
  final List<Post> posts;

  const PostsLoaded({required this.posts});

  @override
  List<Object?> get props => [posts];
}

/// State when a post operation fails.
class PostsError extends PostsState {
  /// Error message.
  final String message;

  const PostsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when a post is successfully created.
///
/// Used to trigger navigation back and show success message.
class PostCreated extends PostsState {
  /// The newly created post.
  final Post post;

  const PostCreated({required this.post});

  @override
  List<Object?> get props => [post];
}

/// State when a post is successfully updated.
class PostUpdated extends PostsState {
  /// The updated post.
  final Post post;

  const PostUpdated({required this.post});

  @override
  List<Object?> get props => [post];
}

/// State when a post is successfully deleted.
class PostDeleted extends PostsState {
  const PostDeleted();
}
