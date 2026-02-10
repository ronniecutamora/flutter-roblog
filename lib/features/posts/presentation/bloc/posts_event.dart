import 'package:equatable/equatable.dart';

import '../../domain/entities/content_block.dart';

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

/// Event to create a new post with block-based content.
class CreatePostEvent extends PostsEvent {
  /// Post title.
  final String title;

  /// Content blocks (text and images).
  final List<ContentBlock> contentBlocks;

  const CreatePostEvent({
    required this.title,
    required this.contentBlocks,
  });

  @override
  List<Object?> get props => [title, contentBlocks];
}

/// Event to update an existing post with block-based content.
class UpdatePostEvent extends PostsEvent {
  /// Post ID to update.
  final String id;

  /// New title.
  final String title;

  /// Updated content blocks.
  final List<ContentBlock> contentBlocks;

  const UpdatePostEvent({
    required this.id,
    required this.title,
    required this.contentBlocks,
  });

  @override
  List<Object?> get props => [id, title, contentBlocks];
}

/// Event to delete a post.
class DeletePostEvent extends PostsEvent {
  /// Post ID to delete.
  final String id;

  const DeletePostEvent({required this.id});

  @override
  List<Object?> get props => [id];
}