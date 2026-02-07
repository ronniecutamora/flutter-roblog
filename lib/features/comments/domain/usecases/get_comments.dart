import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';
import '../repositories/comments_repository.dart';

/// Use case for fetching comments for a specific blog post.
class GetComments {
  final CommentsRepository repository;

  GetComments(this.repository);

  Future<(List<Comment>?, Failure?)> call(String blogId) {
    return repository.getComments(blogId);
  }
}