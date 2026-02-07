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

class AddCommentEvent extends CommentsEvent {
  final String blogId;
  final String content;
  final String? imagePath;

  AddCommentEvent({
    required this.blogId,
    required this.content,
    this.imagePath,
  });

  @override
  List<Object?> get props => [blogId, content, imagePath];
}

class DeleteCommentEvent extends CommentsEvent {
  final String id;
  final String blogId;

  DeleteCommentEvent({required this.id, required this.blogId});

  @override
  List<Object?> get props => [id, blogId];
}