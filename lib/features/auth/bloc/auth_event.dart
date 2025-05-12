part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String passwordConfirmation;

  const RegisterEvent({
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object> get props => [username, email, password, passwordConfirmation];
}

class LoginEvent extends AuthEvent {
  final String login;
  final String password;

  const LoginEvent({required this.login, required this.password});

  @override
  List<Object> get props => [login, password];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

class RefreshTokenEvent extends AuthEvent {}
