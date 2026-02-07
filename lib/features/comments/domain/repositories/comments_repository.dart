import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';

abstract class CommentsRepository {
  Future<(List<Comment>?, Failure?)> getComments(String blogId);
  Future<(Comment?, Failure?)> addComment(String blogId, String content, String? imagePath);
  Future<Failure?> deleteComment(String id);
}