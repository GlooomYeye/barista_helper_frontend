import 'package:barista_helper/core/navigation/navigation_screen.dart';
import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:barista_helper/core/theme/bloc/theme_bloc.dart';
import 'package:barista_helper/domain/repositories/auth_repository.dart';
import 'package:barista_helper/domain/repositories/note_repository.dart';
import 'package:barista_helper/domain/repositories/recipe_repository.dart';
import 'package:barista_helper/domain/repositories/term_repository.dart';
import 'package:barista_helper/domain/repositories/user_repository.dart';
import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';

import 'package:barista_helper/features/notes/bloc/notes_bloc.dart';
import 'package:barista_helper/features/profile/bloc/profile_bloc.dart';
import 'package:barista_helper/features/recipes/bloc/recipe_create_bloc.dart';
import 'package:barista_helper/features/recipes/bloc/recipe_details_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  GetIt.I.registerLazySingleton(() => Dio());
  GetIt.I.registerLazySingleton(
    () => AuthRepository(secureStorage: FlutterSecureStorage()),
  );
  GetIt.I.registerLazySingleton(() => UserRepository());

  GetIt.I.registerSingleton<AuthBloc>(AuthBloc(GetIt.I<AuthRepository>()));
  GetIt.I.registerSingleton<ThemeBloc>(ThemeBloc(prefs));

  GetIt.I.registerLazySingleton(() => RecipeRepository());
  GetIt.I.registerLazySingleton(() => TermRepository());
  GetIt.I.registerLazySingleton(() => NoteRepository());

  GetIt.I.registerSingleton<RecipeDetailsBloc>(
    RecipeDetailsBloc(GetIt.I<RecipeRepository>(), GetIt.I<UserRepository>()),
  );
  GetIt.I.registerSingleton<NotesBloc>(NotesBloc(GetIt.I<NoteRepository>()));
  GetIt.I.registerSingleton<ProfileBloc>(
    ProfileBloc(GetIt.I<UserRepository>()),
  );
  GetIt.I.registerSingleton<CreateRecipeBloc>(
    CreateRecipeBloc(GetIt.I<UserRepository>()),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    _authBloc;
    _themeBloc.add(LoadThemeEvent());
  }

  final AuthBloc _authBloc = GetIt.I<AuthBloc>();
  final ProfileBloc _profileBloc = GetIt.I<ProfileBloc>();
  final RecipeDetailsBloc _recipeDetailsBloc = GetIt.I<RecipeDetailsBloc>();
  final ThemeBloc _themeBloc = GetIt.I<ThemeBloc>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _profileBloc),
        BlocProvider.value(value: _recipeDetailsBloc),
        BlocProvider.value(value: _themeBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final themeMode =
              state is ThemeChanged ? state.themeMode : ThemeMode.system;
          return MaterialApp(
            title: 'Barista Helper',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
