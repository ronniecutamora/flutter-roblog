import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String? displayName;
  final String? avatarPath;

  UpdateProfileEvent({this.displayName, this.avatarPath});

  @override
  List<Object?> get props => [displayName, avatarPath];
}