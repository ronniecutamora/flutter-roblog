import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

/// Base class for all authentication states.
///
/// States represent the current situation of the authentication system.
/// The UI rebuilds based on state changes.
///
/// ## State Flow
///
/// ```
/// AuthInitial → AuthLoading → Authenticated / Unauthenticated / AuthError
/// ```
abstract class AuthState extends Equatable {
  /// Creates an [AuthState].
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any authentication check.
///
/// The app should check auth status when in this state.
class AuthInitial extends AuthState {
  /// Creates an [AuthInitial] state.
  const AuthInitial();
}

/// State while an authentication operation is in progress.
///
/// UI should show a loading indicator.
class AuthLoading extends AuthState {
  /// Creates an [AuthLoading] state.
  const AuthLoading();
}

/// State when user is successfully authenticated.
///
/// Contains the authenticated [user] data.
class Authenticated extends AuthState {
  /// The authenticated user.
  final AppUser user;

  /// Creates an [Authenticated] state with the given [user].
  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated.
///
/// UI should show login/register options.
class Unauthenticated extends AuthState {
  /// Creates an [Unauthenticated] state.
  const Unauthenticated();
}

/// State when an authentication error occurs.
///
/// Contains the error [message] to display.
class AuthError extends AuthState {
  /// Error message describing what went wrong.
  final String message;

  /// Creates an [AuthError] state with the given [message].
  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
