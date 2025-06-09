import 'package:flutter/services.dart';
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

  GetIt.I.registerLazySingleton(
    () => Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        sendTimeout: const Duration(seconds: 3),
      ),
    ),
  );
  GetIt.I.registerLazySingleton(
    () => AuthRepository(secureStorage: const FlutterSecureStorage()),
  );
  GetIt.I.registerLazySingleton(() => UserRepository());
  GetIt.I.registerLazySingleton(() => RecipeRepository());
  GetIt.I.registerLazySingleton(() => TermRepository());
  GetIt.I.registerLazySingleton(() => NoteRepository());

  GetIt.I.registerSingleton<AuthBloc>(
    AuthBloc(GetIt.I<AuthRepository>(), GetIt.I<UserRepository>()),
  );
  GetIt.I.registerSingleton<ThemeBloc>(ThemeBloc(prefs));
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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  @override
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    GetIt.I<AuthBloc>().add(CheckAuthEvent());
    GetIt.I<ThemeBloc>().add(LoadThemeEvent());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      runApp(const MyApp());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handlePop(bool didPop, dynamic result) {
    if (didPop) return;

    final now = DateTime.now();
    const duration = Duration(seconds: 2);

    if (_lastPressedAt == null || now.difference(_lastPressedAt!) > duration) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нажмите ещё раз для выхода'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: GetIt.I<AuthBloc>()),
        BlocProvider.value(value: GetIt.I<ProfileBloc>()),
        BlocProvider.value(value: GetIt.I<RecipeDetailsBloc>()),
        BlocProvider.value(value: GetIt.I<ThemeBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final themeMode =
              state is ThemeChanged ? state.themeMode : ThemeMode.system;
          final isDarkMode =
              themeMode == ThemeMode.dark ||
              (themeMode == ThemeMode.system &&
                  WidgetsBinding
                          .instance
                          .platformDispatcher
                          .platformBrightness ==
                      Brightness.dark);

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              systemNavigationBarColor:
                  isDarkMode ? Colors.black : Colors.white,
              systemNavigationBarIconBrightness:
                  isDarkMode ? Brightness.light : Brightness.dark,
            ),
          );
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: _handlePop,
            child: MaterialApp(
              title: 'Barista Helper',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const MainNavigationScreen(),
            ),
          );
        },
      ),
    );
  }
}
