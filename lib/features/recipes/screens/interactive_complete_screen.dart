import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:barista_helper/domain/models/recipe_details.dart';
import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';

import 'package:barista_helper/features/recipes/bloc/recipe_details_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class BrewCompleteScreen extends StatelessWidget {
  final RecipeDetails recipe;
  final String totalTime;
  final bool authenticated = GetIt.I<AuthBloc>().state is Authenticated;

  BrewCompleteScreen({
    super.key,
    required this.recipe,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    final stepsCompleted = recipe.brewingSteps.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipe.title,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<RecipeDetailsBloc, RecipeDetailsState>(
        bloc: GetIt.I<RecipeDetailsBloc>(),
        listener: (context, state) {
          if (state is RecipeDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Что-то пошло не так',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: AppTheme.errorRed,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is RecipeDetailsLoaded && state.recipe.liked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Рецепт добавлен в избранное!',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: AppTheme.primaryGreen,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppTheme.activeGradient(context),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check, size: 60, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Отличная работа!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Вы успешно приготовили кофе',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        context,
                        icon: Icons.access_time,
                        label: 'Общее время',
                        value: totalTime,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatTile(
                        context,
                        icon: Icons.check,
                        label: 'Шагов выполнено',
                        value: '$stepsCompleted',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Container(
                    decoration: AppTheme.gradientButtonDecoration(context),
                    child:
                        authenticated
                            ? _buildButtonForAuth(context)
                            : _buildButtonForGuest(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonForAuth(context) {
    return ElevatedButton.icon(
      onPressed: () => _toggleLike(context),
      icon: Icon(
        recipe.liked ? Icons.favorite : Icons.favorite_border,
        color: Colors.white,
      ),
      label: Text(
        recipe.liked ? 'Рецепт уже сохранен' : 'Сохранить рецепт',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Widget _buildButtonForGuest(context) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.coffee, color: Colors.white),
      label: Text(
        "Продолжить",
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(color: Theme.of(context).cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                icon,
                color: isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      // ),
    );
  }

  void _toggleLike(BuildContext context) {
    if (recipe.liked) {
      Navigator.pop(context);
      return;
    }
    GetIt.I<RecipeDetailsBloc>().add(ToggleLike());
    Navigator.pop(context);
  }
}
