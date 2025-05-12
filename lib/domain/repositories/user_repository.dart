import 'package:barista_helper/domain/models/recipe.dart';
import 'package:barista_helper/domain/models/recipe_details.dart';
import 'package:barista_helper/domain/models/user.dart';
import 'package:barista_helper/domain/repositories/auth_repository.dart';
import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:barista_helper/core/config/app_config.dart';

class UserRepository {
  final Dio dio = GetIt.I<Dio>();
  final AuthRepository authRepository = GetIt.I<AuthRepository>();
  final AuthBloc authBloc = GetIt.I<AuthBloc>();
  final String baseUrl = AppConfig.baseUrl;

  UserRepository();

  Future<User> getCurrentUser() async {
    return makeAuthenticatedRequest(
      () => dio.get('$baseUrl/api/users/me'),
      (data) => User.fromJson(data),
    );
  }

  Future<User> updateUserInfo(int id, String username, String email) async {
    return makeAuthenticatedRequest(
      () => dio.put(
        '$baseUrl/api/users/me',
        data: {'id': id, 'username': username, 'email': email},
      ),
      (data) => User.fromJson(data),
    );
  }

  Future<User> updateUserPassword(
    int id,
    String oldPassword,
    String newPassword,
    String newPasswordConfirmation,
  ) async {
    return makeAuthenticatedRequest(
      () => dio.put(
        '$baseUrl/api/users/me/password',
        data: {
          'id': id,
          'oldPassword': oldPassword,
          'password': newPassword,
          'passwordConfirmation': newPasswordConfirmation,
        },
      ),
      (data) => User.fromJson(data),
    );
  }

  Future<void> deleteUser(int userId) async {
    return makeAuthenticatedRequest(
      () => dio.delete('$baseUrl/api/users/$userId'),
      (data) {},
    );
  }

  Future<List<Recipe>> getUserCreatedRecipes({
    required int page,
    required int perPage,
  }) async {
    final userId = (authBloc.state as Authenticated).user.id;
    return await makeAuthenticatedRequest(
      () async => dio.get(
        '$baseUrl/api/users/$userId/recipes',
        queryParameters: {'page': page, 'perPage': perPage},
      ),
      (data) =>
          (data['content'] as List)
              .map((json) => Recipe.fromJson(json))
              .toList(),
    );
  }

  Future<List<Recipe>> getUserLikedRecipes({
    required int page,
    required int perPage,
  }) async {
    final userId = (authBloc.state as Authenticated).user.id;
    return await makeAuthenticatedRequest(
      () async => dio.get(
        '$baseUrl/api/users/$userId/recipes',
        queryParameters: {'page': page, 'perPage': perPage},
      ),
      (data) =>
          (data['content'] as List)
              .map((json) => Recipe.fromJson(json))
              .toList(),
    );
  }

  Future<void> likeRecipe(int recipeId) async {
    final userId = (authBloc.state as Authenticated).user.id;
    return await makeAuthenticatedRequest(
      () async => dio.post('$baseUrl/api/users/$userId/recipes/$recipeId/like'),
      (data) {},
    );
  }

  Future<void> unlikeRecipe(int recipeId) async {
    final userId = (authBloc.state as Authenticated).user.id;
    return await makeAuthenticatedRequest(
      () async =>
          dio.delete('$baseUrl/api/users/$userId/recipes/$recipeId/like'),
      (data) {},
    );
  }

  Future<void> saveRecipe(RecipeDetails recipe) async {
    final userId = (authBloc.state as Authenticated).user.id;
    final recipeData = recipe.toJson();
    recipeData['authorId'] = userId;
    recipeData['id'] = null;
    return await makeAuthenticatedRequest(
      () async =>
          dio.post('$baseUrl/api/users/$userId/recipes', data: recipeData),
      (data) {},
    );
  }

  Future<void> updateRecipe(RecipeDetails recipe) async {
    final userId = (authBloc.state as Authenticated).user.id;
    return await makeAuthenticatedRequest(
      () async => dio.put(
        '$baseUrl/api/users/$userId/recipes/${recipe.id}',
        data: recipe.toJson(),
      ),
      (data) {},
    );
  }

  Future<void> deleteRecipe(int recipeId) async {
    final userId = (authBloc.state as Authenticated).user.id;
    return await makeAuthenticatedRequest(
      () async => dio.delete('$baseUrl/api/users/$userId/recipes/$recipeId'),
      (data) {},
    );
  }

  Future<T> makeAuthenticatedRequest<T>(
    Future<Response> Function() request,
    T Function(dynamic) mapper,
  ) async {
    final tokens = await authRepository.getTokens();
    if (tokens == null) throw Exception('Необходима авторизация');

    final originalHeaders = dio.options.headers;

    dio.options.headers = {
      ...originalHeaders,
      'Authorization': 'Bearer ${tokens.accessToken}',
    };

    try {
      final response = await request();

      return mapper(response.data);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        try {
          await authRepository.refreshToken(tokens.refreshToken);
          return makeAuthenticatedRequest(request, mapper);
        } catch (refreshError) {
          await authRepository.logout();
          throw Exception('Сессия истекла. Пожалуйста, войдите снова');
        }
      }
      throw _handleError(e);
    } finally {
      dio.options.headers = originalHeaders;
    }
  }

  Exception _handleError(DioException e) {
    //final message = e.response?.data?['message'] ?? e.message;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception(
        'Превышено время ожидания. Проверьте подключение к интернету',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return Exception('Ошибка подключения к серверу');
    }

    final errorMessage = e.response?.data?['message'];
    if (errorMessage != null) {
      return Exception(errorMessage);
    }

    return Exception('Неизвестная ошибка. Попробуйте позже');
  }
}
