/// Form field validators for the Roblog application.
///
/// All validators return `null` if valid, or an error message string if invalid.
/// Designed to work with [TextFormField.validator].
///
/// Example:
/// ```dart
/// TextFormField(
///   validator: Validators.email,
/// )
/// ```
class Validators {
  Validators._(); // Private constructor

  /// Validates email format.
  ///
  /// Returns error message if:
  /// - Email is empty
  /// - Email doesn't match standard format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validates password strength.
  ///
  /// Returns error message if:
  /// - Password is empty
  /// - Password is less than 6 characters
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validates that a required field is not empty.
  ///
  /// [fieldName] is used in the error message.
  ///
  /// Example:
  /// ```dart
  /// validator: (v) => Validators.required(v, 'Title'),
  /// ```
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates post title.
  ///
  /// Returns error message if:
  /// - Title is empty
  /// - Title is less than 3 characters
  static String? postTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }

    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }

    return null;
  }

  /// Validates post content.
  ///
  /// Returns error message if:
  /// - Content is empty
  /// - Content is less than 10 characters
  static String? postContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Content is required';
    }

    if (value.trim().length < 10) {
      return 'Content must be at least 10 characters';
    }

    return null;
  }
}
