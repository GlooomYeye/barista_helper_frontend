part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String username;
  final String email;
  final String oldPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  const UpdateProfileEvent({
    required this.username,
    required this.email,
    required this.oldPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  List<Object> get props => [username, email];
}

class DeleteProfileEvent extends ProfileEvent {}
