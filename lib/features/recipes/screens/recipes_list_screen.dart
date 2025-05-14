import 'package:barista_helper/domain/models/brewing_method.dart';
import 'package:barista_helper/domain/models/recipe.dart';
import 'package:barista_helper/domain/repositories/recipe_repository.dart';
import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';
import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:barista_helper/features/recipes/bloc/recipe_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key, required this.method});
  final BrewingMethod method;

  @override
  RecipeListScreenState createState() => RecipeListScreenState();
}

class RecipeListScreenState extends State<RecipeListScreen> {
  final ScrollController _scrollController = ScrollController();
  late final RecipeListBloc _recipeListBloc;
  final TextEditingController _searchController = TextEditingController();
  String _currentSortBy = 'id';
  String _currentSortDir = 'asc';

  @override
  void initState() {
    super.initState();
    _recipeListBloc = RecipeListBloc(GetIt.I<RecipeRepository>());
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recipeListBloc.add(
        FetchRecipes(
          method: widget.method.enumName,
          sortBy: _currentSortBy,
          sortDir: _currentSortDir,
        ),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= 200.0) {
      final state = _recipeListBloc.state;
      if (state is RecipeListLoaded && !state.hasReachedMax && !_isLoading) {
        _isLoading = true;
        _recipeListBloc.add(
          FetchRecipes(
            method: widget.method.enumName,
            isInitialLoad: false,
            searchQuery: _searchController.text,
            sortBy: _currentSortBy,
            sortDir: _currentSortDir,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _refreshList();
    });
  }

  void _refreshList() {
    _recipeListBloc.add(
      FetchRecipes(
        method: widget.method.enumName,
        isInitialLoad: true,
        searchQuery: _searchController.text,
        sortBy: _currentSortBy,
        sortDir: _currentSortDir,
      ),
    );
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('По дате (сначала новые)'),
                  onTap: () {
                    setState(() {
                      _currentSortBy = 'id';
                      _currentSortDir = 'desc';
                    });
                    _refreshList();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('По дате (сначала старые)'),
                  onTap: () {
                    setState(() {
                      _currentSortBy = 'id';
                      _currentSortDir = 'asc';
                    });
                    _refreshList();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('По лайкам (по убыванию)'),
                  onTap: () {
                    setState(() {
                      _currentSortBy = 'likes';
                      _currentSortDir = 'desc';
                    });
                    _refreshList();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('По лайкам (по возрастанию)'),
                  onTap: () {
                    setState(() {
                      _currentSortBy = 'likes';
                      _currentSortDir = 'asc';
                    });
                    _refreshList();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _recipeListBloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            bloc: GetIt.I<AuthBloc>(),
            listenWhen:
                (previous, current) =>
                    current is Authenticated || current is Unauthenticated,
            listener: (context, state) {
              context.read<RecipeListBloc>().add(
                FetchRecipes(
                  method: widget.method.enumName,
                  searchQuery: _searchController.text,
                  sortBy: _currentSortBy,
                  sortDir: _currentSortDir,
                ),
              );
            },
          ),
          BlocListener<RecipeListBloc, RecipeListState>(
            listener: (context, state) {
              if (state is RecipeListLoaded ||
                  state is RecipeListError ||
                  state is RecipeListPaginationLoading) {
                _isLoading = false;
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color:
                            Theme.of(context).appBarTheme.titleTextStyle?.color,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.method.title,
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Поиск рецептов...',
                            hintStyle: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Theme.of(context).hintColor),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).hintColor,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          onSubmitted: (_) => _refreshList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: _showSortMenu,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Добавил отступ
              ],
            ),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            toolbarHeight: 120,
            automaticallyImplyLeading: false,
          ),
          body: BlocBuilder<RecipeListBloc, RecipeListState>(
            builder: (context, state) {
              if (state is RecipeListInitial) {
                return Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                );
              }

              if (state is RecipeListError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Что-то пошло не так',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => _refreshList(),
                        child: Text(
                          'Попробовать снова',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is RecipeListLoaded ||
                  state is RecipeListPaginationLoading) {
                final recipes =
                    state is RecipeListLoaded
                        ? state.recipes
                        : (state as RecipeListPaginationLoading).recipes;
                final hasReachedMax =
                    state is RecipeListLoaded ? state.hasReachedMax : false;
                if (recipes.isEmpty) {
                  return Center(
                    child: Text(
                      'Рецепты не найдены',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }
                return Stack(
                  children: [
                    RefreshIndicator(
                      color: AppTheme.primaryBlue,
                      onRefresh: () async {
                        _refreshList();
                        // Ждем пока состояние не обновится
                        await for (final state in _recipeListBloc.stream) {
                          if (state is RecipeListLoaded) {
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                            break;
                          }
                          if (state is RecipeListError) {
                            break;
                          }
                        }
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            hasReachedMax ? recipes.length : recipes.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= recipes.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: _buildRecipeTile(
                              context: context,
                              recipe: recipes[index],
                            ),
                          );
                        },
                      ),
                    ),
                    _addButton(),
                  ],
                );
              }
              return Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBlue),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _addButton() {
    return Positioned(
      right: 24,
      bottom: 24 + MediaQuery.of(context).padding.bottom,
      child: GestureDetector(
        onTap: () {
          Navigator.of(
            context,
            rootNavigator: false,
          ).pushNamed('/createRecipe');
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.activeGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withAlpha((0.3 * 255).round()),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildRecipeTile({
    required BuildContext context,
    required Recipe recipe,
  }) {
    return GestureDetector(
      onTap: () async {
        // Переходим на экран деталей и ждем возвращения
        await Navigator.of(
          context,
          rootNavigator: false,
        ).pushNamed('/recipeDetails', arguments: recipe.id);

        // После возвращения с экрана деталей, принудительно обновляем список
        _recipeListBloc.add(
          FetchRecipes(
            method: widget.method.enumName,
            isInitialLoad: true,
            searchQuery: _searchController.text,
            sortBy: _currentSortBy,
            sortDir: _currentSortDir,
          ),
        );
      },
      child: Container(
        decoration: AppTheme.cardDecoration(color: Theme.of(context).cardColor),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.formatTime(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ), // Добавил отступ между названием и сложностью
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: recipe.difficultyColor.withAlpha(
                        (0.1 * 255).round(),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      recipe.difficulty,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: recipe.difficultyColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      recipe.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        recipe.liked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color:
                            recipe.liked
                                ? AppTheme.errorRed
                                : Theme.of(context).hintColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.likes.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
