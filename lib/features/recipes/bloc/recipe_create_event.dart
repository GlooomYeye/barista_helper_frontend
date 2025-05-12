part of 'recipe_create_bloc.dart';

abstract class CreateRecipeEvent {}

class SubmitRecipeEvent extends CreateRecipeEvent {
  final RecipeDetails recipeDetails;
  final bool isEditing;

  SubmitRecipeEvent(this.recipeDetails, {this.isEditing = false});
}

class DeleteRecipeEvent extends CreateRecipeEvent {
  final int recipeId;

  DeleteRecipeEvent(this.recipeId);
}
