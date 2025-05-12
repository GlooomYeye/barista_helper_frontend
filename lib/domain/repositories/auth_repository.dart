import 'package:barista_helper/domain/models/auth_tokens.dart';
import 'package:barista_helper/domain/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:barista_helper/core/config/app_config.dart';

class AuthRepository {
  final Dio dio = GetIt.I<Dio>();
  final FlutterSecureStorage secureStorage;
  final String baseUrl = AppConfig.baseUrl;
  User? _currentUser;

  User? get currentUser => _currentUser;

  AuthRepository({required this.secureStorage});

  Future<User> login(String login, String password) async {
    dio.interceptors.add(LogInterceptor(request: true, responseBody: true));
    try {
      final response = await dio.post(
        '$baseUrl/api/auth/login',
        data: {'login': login, 'password': password},
      );

      final tokens = AuthTokens.fromJson(response.data);
      await _saveTokens(tokens);

      final userResponse = await dio.get(
        '$baseUrl/api/users/me',
        options: _getAuthOptions(tokens.accessToken),
      );
      final user = User.fromJson(userResponse.data);
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await dio.post(
        '$baseUrl/api/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'passwordConfirmation': passwordConfirmation,
        },
      );

      return login(email, password);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await secureStorage.deleteAll();
    _currentUser = null;
    dio.options.headers.remove('Authorization');
  }

  Future<AuthTokens?> getTokens() async {
    final accessToken = await secureStorage.read(key: 'access_token');
    final refreshToken = await secureStorage.read(key: 'refresh_token');
    return (accessToken != null && refreshToken != null)
        ? AuthTokens(accessToken: accessToken, refreshToken: refreshToken)
        : null;
  }

  Future<void> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/auth/refresh',
        data: refreshToken,
      );
      await _saveTokens(AuthTokens.fromJson(response.data));
    } catch (e) {
      await logout();
      throw Exception('Сессия истекла. Пожалуйста, войдите снова.');
    }
  }

  Future<void> _saveTokens(AuthTokens tokens) async {
    await secureStorage.write(key: 'access_token', value: tokens.accessToken);
    await secureStorage.write(key: 'refresh_token', value: tokens.refreshToken);
  }

  Options _getAuthOptions(String token) {
    return Options(
      headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
    );
  }

  Exception _handleError(DioException e) {
    final message = e.response?.data?['message'] ?? e.message;
    return Exception(message ?? 'Unknown error');
  }
}
