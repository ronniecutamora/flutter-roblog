import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';
import '../repositories/comments_repository.dart';

/// Use case for adding a new comment to a blog post.
class CreateComment {
  final CommentsRepository repository;

  CreateComment(this.repository);

  Future<(Comment?, Failure?)> call({
    required String blogId,
    required String content,
    List<String> imagePaths = const [],
  }) {
    return repository.createComment(
      blogId: blogId,
      content: content,
      imagePaths: imagePaths,
    );
  }
}