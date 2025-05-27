import 'package:barista_helper/domain/models/recipe.dart';
import 'package:barista_helper/domain/models/recipe_details.dart';

import 'package:barista_helper/domain/repositories/user_repository.dart';
import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:barista_helper/core/config/app_config.dart';

class RecipeRepository {
  final Dio dio = GetIt.I<Dio>();
  final String baseUrl = AppConfig.baseUrl;
  final AuthBloc authbloc = GetIt.I<AuthBloc>();
  final UserRepository userRepository = GetIt.I<UserRepository>();
  RecipeRepository();

  Future<List<Recipe>> getRecipes(
    String method,
    int page,
    int perPage, {
    String? searchQuery,
    String sortBy = 'id',
    String sortDir = 'asc',
  }) async {
    if (authbloc.state is Authenticated) {
      if (method == 'FAVORITES') {
        final authState = authbloc.state as Authenticated;
        final userId = authState.user.id;
        return await userRepository.makeAuthenticatedRequest(
          () async => dio.get(
            '$baseUrl/api/users/$userId/favorites',
            queryParameters: {
              'page': page,
              'perPage': perPage,
              if (searchQuery != null && searchQuery.isNotEmpty)
                'search': searchQuery,
              'sortBy': sortBy,
              'sortDir': sortDir,
            },
          ),
          (data) =>
              (data['content'] as List)
                  .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
                  .toList(),
        );
      } else if (method == 'CREATED') {
        final authState = authbloc.state as Authenticated;
        final userId = authState.user.id;
        return await userRepository.makeAuthenticatedRequest(
          () async => dio.get(
            '$baseUrl/api/users/$userId/recipes',
            queryParameters: {
              'page': page,
              'perPage': perPage,
              if (searchQuery != null && searchQuery.isNotEmpty)
                'search': searchQuery,
              'sortBy': sortBy,
              'sortDir': sortDir,
            },
          ),
          (data) =>
              (data['content'] as List)
                  .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
                  .toList(),
        );
      } else {
        return await userRepository.makeAuthenticatedRequest(
          () async => dio.get(
            '$baseUrl/api/recipes',
            queryParameters: {
              'method': method,
              'page': page,
              'perPage': perPage,
              if (searchQuery != null && searchQuery.isNotEmpty)
                'search': searchQuery,
              'sortBy': sortBy,
              'sortDir': sortDir,
            },
          ),
          (data) =>
              (data['content'] as List)
                  .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
                  .toList(),
        );
      }
    } else {
      if (method == 'FAVORITES' || method == 'CREATED') {
        throw Exception(
          'Необходимо войти в систему для доступа к этому разделу',
        );
      }
      try {
        final response = await dio.get<Map<String, dynamic>>(
          '$baseUrl/api/recipes',
          queryParameters: {
            'method': method,
            'page': page,
            'perPage': perPage,
            if (searchQuery != null && searchQuery.isNotEmpty)
              'search': searchQuery,
            'sortBy': sortBy,
            'sortDir': sortDir,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          final content = response.data!['content'] as List<dynamic>?;

          if (content == null) {
            throw Exception('Ошибка формата ответа: отсутствует поле content');
          }

          return content
              .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
            'Не удалось загрузить рецепты (Статус: ${response.statusCode})',
          );
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) {
          throw Exception('Запрос был отменен');
        } else {
          throw Exception('Ошибка сети: ${e.message}');
        }
      } catch (e) {
        throw Exception('Неожиданная ошибка: $e');
      }
    }
  }

  Future<RecipeDetails> getRecipeDetails(int id) async {
    if (authbloc.state is Authenticated) {
      return await userRepository.makeAuthenticatedRequest(
        () async => dio.get('$baseUrl/api/recipes/$id'),
        (data) => RecipeDetails.fromJson(data),
      );
    } else {
      try {
        final response = await dio.get<Map<String, dynamic>>(
          '$baseUrl/api/recipes/$id',
        );

        if (response.statusCode == 200 && response.data != null) {
          return RecipeDetails.fromJson(response.data!);
        } else {
          throw Exception(
            'Не удалось загрузить детали рецепта (Статус: ${response.statusCode})',
          );
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) {
          throw Exception('Запрос был отменен');
        } else {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            throw Exception(
              'Превышено время ожидания. Проверьте подключение к интернету',
            );
          }

          if (e.type == DioExceptionType.connectionError) {
            throw Exception('Ошибка подключения к серверу');
          }

          final errorMessage = e.response?.data?['message'];
          if (errorMessage != null) {
            throw Exception(errorMessage);
          }

          throw Exception('Неизвестная ошибка. Попробуйте позже');
        }
      } catch (e) {
        throw Exception('Неожиданная ошибка: $e');
      }
    }
  }
}
