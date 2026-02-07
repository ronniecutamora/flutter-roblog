import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';
import '../repositories/comments_repository.dart';

/// Use case for adding a new comment to a blog post.
class AddComment {
  final CommentsRepository repository;

  AddComment(this.repository);

  Future<(Comment?, Failure?)> call({
    required String blogId,
    required String content,
    String? imagePath,
  }) {
    return repository.addComment(blogId, content, imagePath);
  }
}