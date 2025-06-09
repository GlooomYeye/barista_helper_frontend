import 'package:barista_helper/domain/models/user.dart';
import 'package:barista_helper/domain/repositories/auth_repository.dart';
import 'package:barista_helper/domain/repositories/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthBloc(this.authRepository, this.userRepository) : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuthStatus);
    on<UpdateUserEvent>(_onUpdateUser);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await userRepository.getCurrentUser();
      emit(Authenticated(user: user));
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.register(
        username: event.username,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogin(event, emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.login, event.password);
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogout(event, emit) async {
    await authRepository.logout();
    emit(Unauthenticated());
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;

    try {
      final currentUser = (state as Authenticated).user;
      final user = await userRepository.updateUserInfo(
        currentUser.id,
        event.username,
        event.email,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      if (state is Authenticated) {
        emit(state);
      }
    }
  }
}
