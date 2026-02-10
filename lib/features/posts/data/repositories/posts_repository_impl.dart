import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/content_block.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_remote_datasource.dart';

/// Implementation of [PostsRepository] using [PostsRemoteDataSource].
///
/// Handles error conversion from exceptions to failures.
class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource _remoteDataSource;

  /// Creates a [PostsRepositoryImpl] with the given [remoteDataSource].
  PostsRepositoryImpl({required PostsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<(List<Post>?, Failure?)> getPosts() async {
    try {
      final posts = await _remoteDataSource.getPosts();
      return (posts, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<(Post?, Failure?)> getPostById(String id) async {
    try {
      final post = await _remoteDataSource.getPostById(id);
      return (post, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<(Post?, Failure?)> createPost({
    required String title,
    required List<ContentBlock> contentBlocks,
  }) async {
    try {
      final post = await _remoteDataSource.createPost(
        title: title,
        contentBlocks: contentBlocks,
      );
      return (post, null);
    } on AppAuthException catch (e) {
      return (null, AuthFailure(e.message));
    } on ServerException catch (e) {
      return (null, ServerFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<(Post?, Failure?)> updatePost({
    required String id,
    required String title,
    required List<ContentBlock> contentBlocks,
  }) async {
    try {
      final post = await _remoteDataSource.updatePost(
        id: id,
        title: title,
        contentBlocks: contentBlocks,
      );
      return (post, null);
    } on AppAuthException catch (e) {
      return (null, AuthFailure(e.message));
    } on ServerException catch (e) {
      return (null, ServerFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> deletePost(String id) async {
    try {
      await _remoteDataSource.deletePost(id);
      return null;
    } on ServerException catch (e) {
      return ServerFailure(e.message);
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }
}