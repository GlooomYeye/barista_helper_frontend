part of 'recipe_details_bloc.dart';

abstract class RecipeDetailsState extends Equatable {
  const RecipeDetailsState();

  @override
  List<Object> get props => [];
}

class RecipeDetailsInitial extends RecipeDetailsState {}

class RecipeDetailsLoading extends RecipeDetailsState {}

class RecipeDetailsLoaded extends RecipeDetailsState {
  final RecipeDetails recipe;

  const RecipeDetailsLoaded(this.recipe);

  @override
  List<Object> get props => [recipe];
}

class RecipeDetailsError extends RecipeDetailsState {
  final String message;

  const RecipeDetailsError(this.message);

  @override
  List<Object> get props => [message];
}
