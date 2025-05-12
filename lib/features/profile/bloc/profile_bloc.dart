import 'package:barista_helper/domain/models/user.dart';
import 'package:barista_helper/domain/repositories/user_repository.dart';
import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc(this.userRepository) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<DeleteProfileEvent>(_onDeleteProfile);
  }

  Future<void> _onLoadProfile(event, emit) async {
    emit(ProfileLoading());
    try {
      AuthBloc authBloc = GetIt.I<AuthBloc>();
      if (authBloc.state is Authenticated) {
        final user = (authBloc.state as Authenticated).user;
        emit(ProfileLoaded(user));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, emit) async {
    try {
      if (state is! ProfileLoaded) return;
      final currentUser = (state as ProfileLoaded).user;

      emit(ProfileLoading());
      User updatedUser;

      if (event.newPassword.isNotEmpty) {
        updatedUser = await userRepository.updateUserPassword(
          currentUser.id,
          event.oldPassword,
          event.newPassword,
          event.newPasswordConfirmation,
        );
      } else {
        updatedUser = await userRepository.updateUserInfo(
          currentUser.id,
          event.username,
          event.email,
        );
      }

      emit(ProfileUpdateSuccess(updatedUser));
    } catch (e) {
      if (state is ProfileLoaded) {
        emit(ProfileError(e.toString()));
        emit(state);
      } else {
        emit(ProfileError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteProfile(
    DeleteProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      await userRepository.deleteUser((state as ProfileLoaded).user.id);
      emit(ProfileDeleteSuccess());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
