import 'package:barista_helper/domain/models/recipe_details.dart';
import 'package:barista_helper/domain/repositories/recipe_repository.dart';
import 'package:barista_helper/domain/repositories/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'recipe_details_event.dart';
part 'recipe_details_state.dart';

class RecipeDetailsBloc extends Bloc<RecipeDetailsEvent, RecipeDetailsState> {
  final RecipeRepository recipeRepository;
  final UserRepository userRepository;

  RecipeDetailsBloc(this.recipeRepository, this.userRepository)
    : super(RecipeDetailsInitial()) {
    on<LoadRecipeDetails>(_onLoadRecipeDetails);
    on<ToggleLike>(_onToggleLike);
  }

  Future<void> _onLoadRecipeDetails(
    LoadRecipeDetails event,
    Emitter<RecipeDetailsState> emit,
  ) async {
    emit(RecipeDetailsLoading());
    try {
      final recipe = await recipeRepository.getRecipeDetails(event.recipeId);
      emit(RecipeDetailsLoaded(recipe));
    } catch (e) {
      emit(RecipeDetailsError('Не удалось загрузить рецепт'));
    }
  }

  Future<void> _onToggleLike(
    ToggleLike event,
    Emitter<RecipeDetailsState> emit,
  ) async {
    if (state is RecipeDetailsLoaded) {
      final currentState = state as RecipeDetailsLoaded;
      final updatedRecipe = currentState.recipe.copyWith(
        liked: !currentState.recipe.liked,
        likes:
            currentState.recipe.liked
                ? currentState.recipe.likes - 1
                : currentState.recipe.likes + 1,
      );

      try {
        if (updatedRecipe.liked) {
          await userRepository.likeRecipe(currentState.recipe.id);
        } else {
          await userRepository.unlikeRecipe(currentState.recipe.id);
        }
        emit(RecipeDetailsLoaded(updatedRecipe));
      } catch (e) {
        emit(RecipeDetailsError('Не удалось изменить оценку рецепта'));
      }
    }
  }
}
