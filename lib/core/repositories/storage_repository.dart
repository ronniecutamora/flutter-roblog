/// Abstract contract for storage operations.
///
/// Provides a unified interface for image upload and deletion
/// across all features (posts, comments, profile).
abstract class StorageRepository {
  /// Uploads a new image to storage.
  ///
  /// [filePath] - Local path to the image file (supports both web and mobile).
  /// [userEmail] - User email for organizing uploads in user-specific folders.
  ///
  /// Returns the public URL of the uploaded image.
  /// Throws [ServerException] on upload failure.
  Future<String> uploadImage({
    required String filePath,
    required String userEmail,
  });

  /// Deletes an image from storage.
  ///
  /// [imageUrl] - The public URL of the image to delete.
  ///
  /// Fails silently if deletion fails to avoid blocking operations.
  Future<void> deleteImage(String imageUrl);

  /// Replaces an existing image by deleting old and uploading new.
  ///
  /// If [oldImageUrl] is provided, deletes the old image first,
  /// then uploads the new image with a fresh path.
  ///
  /// If [oldImageUrl] is null, creates a new file.
  ///
  /// Returns the public URL of the uploaded image.
  Future<String> replaceImage({
    required String filePath,
    required String userEmail,
    String? oldImageUrl,
  });
}