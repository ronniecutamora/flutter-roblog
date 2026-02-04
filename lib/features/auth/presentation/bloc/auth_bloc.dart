import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state.
///
/// Handles:
/// - User login
/// - User registration
/// - User logout
/// - Authentication status checks
///
/// ## Event → State Flow
///
/// | Event | Success State | Error State |
/// |-------|---------------|-------------|
/// | [LoginEvent] | [Authenticated] | [AuthError] |
/// | [RegisterEvent] | [Authenticated] | [AuthError] |
/// | [LogoutEvent] | [Unauthenticated] | [AuthError] |
/// | [CheckAuthStatusEvent] | [Authenticated] / [Unauthenticated] | - |
///
/// ## Usage
///
/// ```dart
/// // Fire event
/// context.read<AuthBloc>().add(LoginEvent(email: email, password: password));
///
/// // Listen to state
/// BlocBuilder<AuthBloc, AuthState>(
///   builder: (context, state) {
///     if (state is Authenticated) return HomePage();
///     if (state is AuthLoading) return LoadingSpinner();
///     return LoginPage();
///   },
/// )
/// ```
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login _login;
  final Register _register;
  final Logout _logout;
  final AuthRepository _authRepository;

  /// Creates an [AuthBloc] with the required use cases and repository.
  AuthBloc({
    required Login login,
    required Register register,
    required Logout logout,
    required AuthRepository authRepository,
  })  : _login = login,
        _register = register,
        _logout = logout,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  /// Handles [LoginEvent].
  ///
  /// Emits [AuthLoading], then either [Authenticated] or [AuthError].
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final (user, failure) = await _login(
      email: event.email,
      password: event.password,
    );

    if (failure != null) {
      emit(AuthError(message: failure.message));
    } else {
      emit(Authenticated(user: user!));
    }
  }

  /// Handles [RegisterEvent].
  ///
  /// Emits [AuthLoading], then either [Authenticated] or [AuthError].
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final (user, failure) = await _register(
      email: event.email,
      password: event.password,
    );

    if (failure != null) {
      emit(AuthError(message: failure.message));
    } else {
      emit(Authenticated(user: user!));
    }
  }

  /// Handles [LogoutEvent].
  ///
  /// Emits [AuthLoading], then either [Unauthenticated] or [AuthError].
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final failure = await _logout();

    if (failure != null) {
      emit(AuthError(message: failure.message));
    } else {
      emit(const Unauthenticated());
    }
  }

  /// Handles [CheckAuthStatusEvent].
  ///
  /// Checks if user is currently logged in and emits appropriate state.
  /// Does not emit [AuthLoading] to avoid flicker on app startup.
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;

    if (user != null) {
      emit(Authenticated(user: user));
    } else {
      emit(const Unauthenticated());
    }
  }
}
