import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comments_repository.dart';
import '../datasources/comments_remote_datasource.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource remoteDataSource;

  CommentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<(List<Comment>?, Failure?)> getComments(String blogId) async {
    try {
      final comments = await remoteDataSource.getComments(blogId);
      return (comments.cast<Comment>(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<(Comment?, Failure?)> createComment({
    required String blogId,
    required String content,
    List<String> imagePaths = const [],
  }) async {
    try {
      final comment = await remoteDataSource.createComment(
        blogId: blogId,
        content: content,
        imagePaths: imagePaths,
      );
      return (comment as Comment, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> deleteComment(String id) async {
    try {
      await remoteDataSource.deleteComment(id);
      return null;
    } on ServerException catch (e) {
      return ServerFailure(e.message);
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }
}