part of 'recipe_list_bloc.dart';

abstract class RecipeListEvent extends Equatable {
  const RecipeListEvent();

  @override
  List<Object> get props => [];
}

class FetchRecipes extends RecipeListEvent {
  final String method;
  final bool isInitialLoad;
  final String? searchQuery;
  final String sortBy;
  final String sortDir;

  const FetchRecipes({
    required this.method,
    this.isInitialLoad = true,
    this.searchQuery,
    this.sortBy = 'id',
    this.sortDir = 'asc',
  });

  @override
  List<Object> get props => [
    method,
    isInitialLoad,
    searchQuery ?? '',
    sortBy,
    sortDir,
  ];
}
