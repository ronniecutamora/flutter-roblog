/// Abstract contract for storage operations.
///
/// Provides a unified interface for image upload and deletion
/// across all features (posts, comments, profile).
abstract class StorageRepository {
  /// Uploads an image to storage.
  ///
  /// [filePath] - Local path to the image file (supports both web and mobile).
  /// [userId] - User ID for organizing uploads in user-specific folders.
  ///
  /// Returns the public URL of the uploaded image.
  /// Throws [ServerException] on upload failure.
  Future<String> uploadImage({
    required String filePath,
    required String userId,
  });

  /// Deletes an image from storage.
  ///
  /// [imageUrl] - The public URL of the image to delete.
  ///
  /// Fails silently if deletion fails to avoid blocking operations.
  Future<void> deleteImage(String imageUrl);

  /// Replaces an existing image with a new one.
  ///
  /// Deletes [oldImageUrl] if provided, then uploads new image from [filePath].
  /// Returns the public URL of the newly uploaded image.
  Future<String> replaceImage({
    required String filePath,
    required String userId,
    String? oldImageUrl,
  });
}