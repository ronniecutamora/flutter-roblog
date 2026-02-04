/// Exception thrown when a server/API error occurs.
///
/// Used in the data layer (datasources) when:
/// - API returns non-2xx status codes
/// - Response parsing fails
/// - Database operations fail
///
/// Example:
/// ```dart
/// if (response.statusCode != 200) {
///   throw ServerException('Failed to fetch posts');
/// }
/// ```
class ServerException implements Exception {
  /// Error message describing what went wrong.
  final String message;

  /// Creates a [ServerException] with an optional [message].
  ServerException([this.message = 'Server error occurred']);

  @override
  String toString() => message;
}

/// Exception thrown when authentication fails.
///
/// Used in the data layer when:
/// - Login credentials are invalid
/// - User is not authenticated
/// - Session has expired
///
/// Note: Named `AppAuthException` to avoid conflict with
/// Supabase's `AuthException` class.
class AppAuthException implements Exception {
  /// Error message describing the auth failure.
  final String message;

  /// Creates an [AppAuthException] with an optional [message].
  AppAuthException([this.message = 'Authentication error']);

  @override
  String toString() => message;
}

/// Exception thrown when a requested resource is not found.
///
/// Used when:
/// - Post doesn't exist
/// - User profile not found
/// - Comment deleted
class NotFoundException implements Exception {
  /// Error message describing what wasn't found.
  final String message;

  /// Creates a [NotFoundException] with an optional [message].
  NotFoundException([this.message = 'Resource not found']);

  @override
  String toString() => message;
}
