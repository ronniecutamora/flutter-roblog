import '../../../../core/errors/failures.dart';
import '../repositories/comments_repository.dart';

/// Use case for deleting a comment.
class DeleteComment {
  final CommentsRepository repository;

  DeleteComment(this.repository);

  Future<Failure?> call(String id) {
    return repository.deleteComment(id);
  }
}