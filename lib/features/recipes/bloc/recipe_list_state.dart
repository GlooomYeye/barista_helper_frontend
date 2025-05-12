part of 'recipe_list_bloc.dart';

abstract class RecipeListState extends Equatable {
  const RecipeListState();

  @override
  List<Object> get props => [];
}

class RecipeListInitial extends RecipeListState {}

class RecipeListLoading extends RecipeListState {}

class RecipeListPaginationLoading extends RecipeListState {
  final List<Recipe> recipes;

  const RecipeListPaginationLoading({required this.recipes});

  @override
  List<Object> get props => [recipes];
}

class RecipeListLoaded extends RecipeListState {
  final List<Recipe> recipes;
  final bool hasReachedMax;
  final String method;
  final String? searchQuery;
  final String sortBy;
  final String sortDir;

  const RecipeListLoaded({
    required this.recipes,
    this.hasReachedMax = false,
    required this.method,
    this.searchQuery,
    this.sortBy = 'id',
    this.sortDir = 'asc',
  });

  @override
  List<Object> get props => [
    recipes,
    hasReachedMax,
    method,
    searchQuery ?? '',
    sortBy,
    sortDir,
  ];
}

class RecipeListError extends RecipeListState {
  final String message;

  const RecipeListError(this.message);

  @override
  List<Object> get props => [message];
}
