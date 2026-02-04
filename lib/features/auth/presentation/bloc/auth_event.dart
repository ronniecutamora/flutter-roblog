import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
///
/// Events represent user actions or system triggers that the [AuthBloc]
/// responds to. Each event may carry data needed to process the action.
///
/// ## Usage
///
/// ```dart
/// context.read<AuthBloc>().add(LoginEvent(email: email, password: password));
/// ```
abstract class AuthEvent extends Equatable {
  /// Creates an [AuthEvent].
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when user attempts to log in.
///
/// Carries [email] and [password] credentials.
class LoginEvent extends AuthEvent {
  /// User's email address.
  final String email;

  /// User's password.
  final String password;

  /// Creates a [LoginEvent] with the given credentials.
  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event triggered when user attempts to register.
///
/// Carries [email] and [password] for the new account.
class RegisterEvent extends AuthEvent {
  /// Email for the new account.
  final String email;

  /// Password for the new account.
  final String password;

  /// Creates a [RegisterEvent] with the given credentials.
  const RegisterEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event triggered when user logs out.
class LogoutEvent extends AuthEvent {
  /// Creates a [LogoutEvent].
  const LogoutEvent();
}

/// Event triggered to check current authentication status.
///
/// Typically fired on app startup to determine initial route.
class CheckAuthStatusEvent extends AuthEvent {
  /// Creates a [CheckAuthStatusEvent].
  const CheckAuthStatusEvent();
}
