import 'package:flutter_svg/flutter_svg.dart';
import 'package:barista_helper/domain/models/brewing_step.dart';
import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';
import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:barista_helper/features/recipes/bloc/recipe_details_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final int recipeId;
  const RecipeDetailsScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GetIt.I.get<RecipeDetailsBloc>()..add(LoadRecipeDetails(recipeId)),
      child: BlocListener<AuthBloc, AuthState>(
        bloc: GetIt.I<AuthBloc>(),
        listenWhen:
            (previous, current) =>
                current is Authenticated || current is Unauthenticated,
        listener: (context, state) {
          BlocProvider.of<RecipeDetailsBloc>(
            context,
          ).add(LoadRecipeDetails(recipeId));
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Детали рецепта',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).appBarTheme.titleTextStyle?.color,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: BlocBuilder<RecipeDetailsBloc, RecipeDetailsState>(
            builder: (context, state) {
              if (state is RecipeDetailsLoading) {
                return Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                );
              } else if (state is RecipeDetailsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppTheme.errorRed,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppTheme.errorRed),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed:
                            () => BlocProvider.of<RecipeDetailsBloc>(
                              context,
                            ).add(LoadRecipeDetails(recipeId)),
                        child: Text(
                          'Обновить',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is RecipeDetailsLoaded) {
                return _buildLoadedContent(context, state);
              }
              return Center(
                child: Text(
                  'Начальное состояние',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, RecipeDetailsLoaded state) {
    final recipe = state.recipe;
    final bloc = BlocProvider.of<RecipeDetailsBloc>(context);
    final authBloc = GetIt.I<AuthBloc>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title, difficulty and likes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.activeGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        recipe.title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: recipe.difficultyColor.withAlpha(
                            (0.2 * 255).round(),
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          recipe.difficulty,
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: recipe.difficultyColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (authBloc.state is Authenticated) {
                            bloc.add(ToggleLike());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Войдите, чтобы оценить рецепты',
                                  // style: Theme.of(context).textTheme.bodyMedium, // Удаляем эту строку
                                ),
                                backgroundColor: AppTheme.errorRed,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                recipe.liked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 16,
                                color:
                                    recipe.liked
                                        ? AppTheme.errorRed
                                        : Theme.of(context).hintColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                recipe.likes.toString(),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Time and author
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color:
                            isDark
                                ? Colors.white70
                                : Theme.of(context).hintColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        recipe.formatTime(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              isDark
                                  ? Colors.white70
                                  : Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'автор ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              isDark
                                  ? Colors.white70
                                  : Theme.of(context).hintColor,
                        ),
                      ),
                      Text(
                        recipe.author,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              isDark
                                  ? AppTheme.primaryGreen
                                  : AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (authBloc.state is Authenticated &&
                      (authBloc.state as Authenticated).user.username ==
                          recipe.author)
                    IconButton(
                      icon: Icon(
                        Icons.edit_square,
                        size: 20,
                        color:
                            isDark
                                ? AppTheme.primaryGreen
                                : AppTheme.primaryBlue,
                      ),
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed('/createRecipe', arguments: recipe);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                recipe.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 130,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        context,
                        title: 'Кофе',
                        mainValue: '${recipe.coffeeAmount} г',
                        secondaryValue: recipe.coffeeGrind.title,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailCard(
                        context,
                        title: 'Вода',
                        mainValue: '${recipe.waterAmount} мл',
                        secondaryValue: '${recipe.waterTemp}°C \n',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailCard(
                        context,
                        title: 'Доля',
                        mainValue: '1 : ${recipe.ratio}',
                        secondaryValue: ' \n',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Instructions
              Text(
                'Инструкция',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),

              ...recipe.brewingSteps.map(
                (step) =>
                    _buildInstructionStep(context, step: step, isDark: isDark),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),

        // Start brewing button
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            decoration: AppTheme.gradientButtonDecoration(),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                  rootNavigator: false,
                ).pushNamed('/interactiveBrew', arguments: recipe);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.keyboard_double_arrow_down, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Перейти к инструкции',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required String mainValue,
    required String secondaryValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.activeGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              maxLines: 1, // Добавляем ограничение по строкам
              overflow:
                  TextOverflow
                      .ellipsis, // Добавляем многоточие при переполнении
            ),
            const SizedBox(height: 6),
            Text(
              mainValue,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (secondaryValue.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                secondaryValue,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
    BuildContext context, {
    required BrewingStep step,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                step.type.iconPath,
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleSmall?.color,
                    ),
                  ),
                  if (step.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: isDark ? Colors.white70 : Theme.of(context).hintColor,
                ),
                const SizedBox(width: 4),
                Text(
                  step.formattedDuration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
