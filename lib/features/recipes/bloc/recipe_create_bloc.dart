import 'package:barista_helper/domain/models/recipe_details.dart';
import 'package:barista_helper/domain/repositories/user_repository.dart';
import 'package:bloc/bloc.dart';

part 'recipe_create_event.dart';
part 'recipe_create_state.dart';

class CreateRecipeBloc extends Bloc<CreateRecipeEvent, CreateRecipeState> {
  final UserRepository userRepository;

  CreateRecipeBloc(this.userRepository) : super(CreateRecipeInitial()) {
    on<SubmitRecipeEvent>(_onSubmitRecipe);
    on<DeleteRecipeEvent>(_onDeleteRecipe);
  }

  Future<void> _onSubmitRecipe(
    SubmitRecipeEvent event,
    Emitter<CreateRecipeState> emit,
  ) async {
    emit(CreateRecipeLoading());

    try {
      if (event.isEditing) {
        await userRepository.updateRecipe(event.recipeDetails);
      } else {
        await userRepository.saveRecipe(event.recipeDetails);
      }
      emit(CreateRecipeSuccess());
    } catch (e) {
      emit(CreateRecipeError(e.toString()));
    }
  }

  Future<void> _onDeleteRecipe(
    DeleteRecipeEvent event,
    Emitter<CreateRecipeState> emit,
  ) async {
    emit(CreateRecipeLoading());

    try {
      await userRepository.deleteRecipe(event.recipeId);
      emit(CreateRecipeSuccess());
    } catch (e) {
      emit(CreateRecipeError(e.toString()));
    }
  }
}
