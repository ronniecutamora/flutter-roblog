import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';

abstract class CommentsRepository {
  Future<(List<Comment>?, Failure?)> getComments(String blogId);
  Future<(Comment?, Failure?)> createComment({
    required String blogId,
    required String content,
    List<String> imagePaths = const [],
  });
  Future<Failure?> deleteComment(String id);
}