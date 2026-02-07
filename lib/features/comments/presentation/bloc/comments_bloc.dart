import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_comment.dart' as create_comment;
import '../../domain/usecases/delete_comment.dart';
import '../../domain/usecases/get_comments.dart';
import 'comments_event.dart';
import 'comments_state.dart';

/// BLoC for managing comments state.
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final GetComments getComments;
  final create_comment.CreateComment createComment;
  final DeleteComment deleteComment;

  CommentsBloc({
    required this.getComments,
    required this.createComment,
    required this.deleteComment,
  }) : super(CommentsInitial()) {
    on<LoadCommentsEvent>(_onLoadComments);
    on<CreateCommentEvent>(_onCreateComment);
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

  Future<void> _onCreateComment(
      CreateCommentEvent event, Emitter<CommentsState> emit) async {
    emit(CommentsLoading());
    final (_, failure) = await createComment(
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