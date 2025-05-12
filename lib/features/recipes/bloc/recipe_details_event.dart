part of 'recipe_details_bloc.dart';

abstract class RecipeDetailsEvent extends Equatable {
  const RecipeDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadRecipeDetails extends RecipeDetailsEvent {
  final int recipeId;

  const LoadRecipeDetails(this.recipeId);

  @override
  List<Object> get props => [recipeId];
}

class ToggleLike extends RecipeDetailsEvent {}
