import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_comment.dart';
import '../../domain/usecases/delete_comment.dart';
import '../../domain/usecases/get_comments.dart';
import 'comments_event.dart';
import 'comments_state.dart';

/// BLoC for managing comments state.
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final GetComments getComments;
  final AddComment addComment;
  final DeleteComment deleteComment;

  CommentsBloc({
    required this.getComments,
    required this.addComment,
    required this.deleteComment,
  }) : super(CommentsInitial()) {
    on<LoadCommentsEvent>(_onLoadComments);
    on<AddCommentEvent>(_onAddComment);
    on<DeleteCommentEvent>(_onDeleteComment);
  }

  Future<void> _onLoadComments(
      LoadCommentsEvent event, Emitter<CommentsState> emit) async {
    emit(CommentsLoading());
    final (comments, failure) = await getComments(event.blogId);
    if (failure != null) {
      emit(CommentsError(message: failure.message));
    } else {
      emit(CommentsLoaded(comments: comments!));
    }
  }

  Future<void> _onAddComment(
      AddCommentEvent event, Emitter<CommentsState> emit) async {
    emit(CommentsLoading());
    final (_, failure) = await addComment(
      blogId: event.blogId,
      content: event.content,
      imagePath: event.imagePath,
    );
    if (failure != null) {
      emit(CommentsError(message: failure.message));
    } else {
      emit(CommentAdded());
      add(LoadCommentsEvent(blogId: event.blogId));
    }
  }

  Future<void> _onDeleteComment(
      DeleteCommentEvent event, Emitter<CommentsState> emit) async {
    emit(CommentsLoading());
    final failure = await deleteComment(event.id);
    if (failure != null) {
      emit(CommentsError(message: failure.message));
    } else {
      emit(CommentDeleted());
      add(LoadCommentsEvent(blogId: event.blogId));
    }
  }
}