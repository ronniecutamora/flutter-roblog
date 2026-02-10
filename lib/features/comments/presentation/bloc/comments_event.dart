import 'package:equatable/equatable.dart';

abstract class CommentsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCommentsEvent extends CommentsEvent {
  final String blogId;
  LoadCommentsEvent({required this.blogId});

  @override
  List<Object?> get props => [blogId];
}

class CreateCommentEvent extends CommentsEvent {
  final String blogId;
  final String content;
  final List<String> imagePaths;

  CreateCommentEvent({
    required this.blogId,
    required this.content,
    this.imagePaths = const [],
  });

  @override
  List<Object?> get props => [blogId, content, imagePaths];
}

class DeleteCommentEvent extends CommentsEvent {
  final String id;
  final String blogId;

  DeleteCommentEvent({required this.id, required this.blogId});

  @override
  List<Object?> get props => [id, blogId];
}