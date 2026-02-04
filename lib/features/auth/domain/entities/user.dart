import 'package:equatable/equatable.dart';

/// Represents a user in the Roblog application.
///
/// This is a **domain entity** - a pure Dart class with no external dependencies.
/// It defines what a user IS in business terms, not how it's stored or fetched.
///
/// The data layer ([UserModel]) extends this to add JSON serialization.
///
/// Named [AppUser] to avoid conflicts with Supabase's [User] class.
class AppUser extends Equatable {
  /// Unique identifier from Supabase Auth.
  final String id;

  /// User's email address.
  final String email;

  /// User's display name (optional, from user metadata).
  final String? displayName;

  /// URL to user's avatar image (optional, from user metadata).
  final String? avatarUrl;

  /// Creates an [AppUser] instance.
  ///
  /// [id] and [email] are required.
  /// [displayName] and [avatarUrl] are optional profile fields.
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });

  /// List of properties used for equality comparison.
  ///
  /// Two [AppUser] instances are equal if all these fields match.
  @override
  List<Object?> get props => [id, email, displayName, avatarUrl];
}
