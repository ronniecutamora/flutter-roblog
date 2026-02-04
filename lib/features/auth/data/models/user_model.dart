import '../../domain/entities/user.dart';

/// Data model for [AppUser] with JSON serialization.
///
/// Extends the domain entity [AppUser] and adds methods to:
/// - Create from Supabase Auth user metadata
/// - Convert to/from JSON maps
///
/// ## Why Separate Model and Entity?
///
/// - **Entity**: Pure business object (domain layer)
/// - **Model**: Knows how to serialize/deserialize (data layer)
///
/// This separation keeps the domain layer free of external dependencies.
class UserModel extends AppUser {
  /// Creates a [UserModel] instance.
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.avatarUrl,
  });

  /// Creates a [UserModel] from Supabase Auth user data.
  ///
  /// [id] - The user's unique ID from Supabase Auth
  /// [email] - The user's email address
  /// [metadata] - User metadata map containing display_name and avatar_url
  ///
  /// Example:
  /// ```dart
  /// final user = UserModel.fromAuthUser(
  ///   authUser.id,
  ///   authUser.email!,
  ///   authUser.userMetadata,
  /// );
  /// ```
  factory UserModel.fromAuthUser(
    String id,
    String email,
    Map<String, dynamic>? metadata,
  ) {
    return UserModel(
      id: id,
      email: email,
      displayName: metadata?['display_name'] as String?,
      avatarUrl: metadata?['avatar_url'] as String?,
    );
  }

  /// Creates a [UserModel] from a JSON map.
  ///
  /// Used when deserializing from local cache or API responses.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  /// Converts this [UserModel] to a JSON map.
  ///
  /// Used when serializing for local cache or API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
    };
  }
}
