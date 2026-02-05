import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

/// Use case for fetching a single post by ID.
///
/// ## Usage
///
/// ```dart
/// final getPostById = GetPostById(postsRepository);
/// final (post, failure) = await getPostById(id: 'abc-123');
/// ```
class GetPostById {
  final PostsRepository _repository;

  /// Creates a [GetPostById] use case.
  GetPostById(this._repository);

  /// Executes the use case.
  ///
  /// [id] - The post ID to fetch.
  Future<(Post?, Failure?)> call({required String id}) async {
    return await _repository.getPostById(id);
  }
}
