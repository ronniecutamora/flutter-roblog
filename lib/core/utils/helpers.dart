import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

/// Utility functions used throughout the Roblog application.
///
/// Provides reusable helpers for:
/// - Date formatting
/// - Showing snackbars
/// - Confirmation dialogs
class Helpers {
  Helpers._(); // Private constructor

  /// Formats a [DateTime] to a human-readable string.
  ///
  /// Returns:
  /// - "Today at HH:mm" for today's dates
  /// - "Yesterday at HH:mm" for yesterday
  /// - "X days ago" for dates within a week
  /// - "MMM d, yyyy" for older dates
  ///
  /// Example:
  /// ```dart
  /// Text(Helpers.formatDate(post.createdAt)) // "Today at 14:30"
  /// ```
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  /// Shows a snackbar with the given [message].
  ///
  /// Set [isError] to `true` for error styling (red background).
  ///
  /// Example:
  /// ```dart
  /// Helpers.showSnackBar(context, 'Post created!');
  /// Helpers.showSnackBar(context, 'Failed to save', isError: true);
  /// ```
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows a confirmation dialog and returns the user's choice.
  ///
  /// Returns `true` if user confirms, `false` if cancelled.
  ///
  /// Example:
  /// ```dart
  /// final confirmed = await Helpers.showConfirmDialog(
  ///   context,
  ///   'Delete Post',
  ///   'Are you sure you want to delete this post?',
  /// );
  /// if (confirmed) {
  ///   // Delete the post
  /// }
  /// ```
  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
