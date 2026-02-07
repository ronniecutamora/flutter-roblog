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
  // 1. Force the date to the user's local time (Crucial for PH +8 offset)
  final localDate = date.toLocal(); 
  final now = DateTime.now();

  // 2. Create "midnight" versions to compare actual calendar days
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final aDate = DateTime(localDate.year, localDate.month, localDate.day);

  if (aDate == today) {
    return 'Today at ${DateFormat('HH:mm').format(localDate)}';
  } else if (aDate == yesterday) {
    return 'Yesterday at ${DateFormat('HH:mm').format(localDate)}';
  } else if (now.difference(localDate).inDays < 7) {
    // Use inDays here only after we know it's not today or yesterday
    final days = now.difference(localDate).inDays;
    return '$days ${days == 1 ? 'day' : 'days'} ago';
  } else {
    return DateFormat('MMM d, yyyy').format(localDate);
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
