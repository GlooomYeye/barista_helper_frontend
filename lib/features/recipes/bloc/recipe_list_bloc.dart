import 'package:barista_helper/domain/models/recipe.dart';
import 'package:barista_helper/domain/repositories/recipe_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'recipe_list_event.dart';
part 'recipe_list_state.dart';

class RecipeListBloc extends Bloc<RecipeListEvent, RecipeListState> {
  final RecipeRepository recipeRepository;
  int _page = 1;
  final int _perPage = 7;

  RecipeListBloc(this.recipeRepository) : super(RecipeListInitial()) {
    on<FetchRecipes>(_onFetchRecipes);
  }

  Future<void> _onFetchRecipes(
    FetchRecipes event,
    Emitter<RecipeListState> emit,
  ) async {
    try {
      if (event.isInitialLoad) {
        _page = 1;
        emit(RecipeListLoading());
      } else {
        if (state is! RecipeListLoaded) return;
        final currentState = state as RecipeListLoaded;
        if (currentState.hasReachedMax) return;

        emit(RecipeListPaginationLoading(recipes: currentState.recipes));
      }

      final newRecipes = await recipeRepository.getRecipes(
        event.method,
        _page,
        _perPage,
        searchQuery: event.searchQuery,
        sortBy: event.sortBy,
        sortDir: event.sortDir,
      );

      final hasReachedMax = newRecipes.length < _perPage;

      List<Recipe> currentRecipes = [];
      if (state is RecipeListPaginationLoading) {
        currentRecipes = (state as RecipeListPaginationLoading).recipes;
      }

      final updatedRecipes =
          event.isInitialLoad ? newRecipes : [...currentRecipes, ...newRecipes];

      if (!event.isInitialLoad) {
        _page++;
      }

      emit(
        RecipeListLoaded(
          recipes: updatedRecipes,
          hasReachedMax: hasReachedMax,
          method: event.method,
          searchQuery: event.searchQuery,
          sortBy: event.sortBy,
          sortDir: event.sortDir,
        ),
      );
    } catch (e) {
      emit(RecipeListError(e.toString()));
    }
  }
}
