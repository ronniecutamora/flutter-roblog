import 'package:equatable/equatable.dart';

import '../../domain/entities/comment.dart';

/// Base class for all comments states.
abstract class CommentsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state before any action.
class CommentsInitial extends CommentsState {}

/// Loading state while fetching or modifying comments.
class CommentsLoading extends CommentsState {}

/// State when comments are successfully loaded.
class CommentsLoaded extends CommentsState {
  final List<Comment> comments;

  CommentsLoaded({required this.comments});

  @override
  List<Object?> get props => [comments];
}

/// Error state when an operation fails.
class CommentsError extends CommentsState {
  final String message;

  CommentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when a comment is successfully added.
class CommentAdded extends CommentsState {}

/// State when a comment is successfully deleted.
class CommentDeleted extends CommentsState {}