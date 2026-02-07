import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC for managing user profile state.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
      LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final (user, failure) = await getProfile();
    if (failure != null) {
      emit(ProfileError(message: failure.message));
    } else {
      emit(ProfileLoaded(user: user!));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final (user, failure) = await updateProfile(
      displayName: event.displayName,
      avatarPath: event.avatarPath,
    );
    if (failure != null) {
      emit(ProfileError(message: failure.message));
    } else {
      emit(ProfileUpdated(user: user!));
    }
  }
}