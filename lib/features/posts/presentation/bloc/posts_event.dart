import 'package:equatable/equatable.dart';

/// Base class for all posts events.
///
/// Events represent user actions that the [PostsBloc] responds to.
abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all posts.
///
/// Typically fired on home page initialization or pull-to-refresh.
class LoadPostsEvent extends PostsEvent {
  const LoadPostsEvent();
}

/// Event to create a new post.
class CreatePostEvent extends PostsEvent {
  /// Post title.
  final String title;

  /// Post content.
  final String content;

  /// Optional local image path.
  final String? imagePath;

  const CreatePostEvent({
    required this.title,
    required this.content,
    this.imagePath,
  });

  @override
  List<Object?> get props => [title, content, imagePath];
}

/// Event to update an existing post.
class UpdatePostEvent extends PostsEvent {
  /// Post ID to update.
  final String id;

  /// New title.
  final String title;

  /// New content.
  final String content;

  /// Optional new image path.
  final String? imagePath;

  const UpdatePostEvent({
    required this.id,
    required this.title,
    required this.content,
    this.imagePath,
  });

  @override
  List<Object?> get props => [id, title, content, imagePath];
}

/// Event to delete a post.
class DeletePostEvent extends PostsEvent {
  /// Post ID to delete.
  final String id;

  const DeletePostEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
