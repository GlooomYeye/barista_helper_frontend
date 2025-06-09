import 'package:barista_helper/core/navigation/bottom_nav_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barista_helper/domain/models/brewing_method.dart';
import 'package:barista_helper/domain/models/recipe_details.dart';
import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';
import 'package:barista_helper/features/notes/bloc/notes_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:barista_helper/features/auth/screens/sign_in_screen.dart';
import 'package:barista_helper/features/auth/screens/sign_up_screen.dart';

import 'package:barista_helper/features/dictionary/screens/dictionary_screen.dart';

import 'package:barista_helper/features/notes/screens/notes_details_screen.dart';
import 'package:barista_helper/features/notes/screens/notes_screen.dart';
import 'package:barista_helper/features/profile/screens/account_security_screen.dart';
import 'package:barista_helper/features/profile/screens/account_settings_screen.dart';
import 'package:barista_helper/features/profile/screens/appearance_settings_screen.dart';
import 'package:barista_helper/features/profile/screens/profile_screen.dart';
import 'package:barista_helper/features/profile/screens/support_screen.dart';
import 'package:barista_helper/features/recipes/screens/interactive_complete_screen.dart';
import 'package:barista_helper/features/recipes/screens/recipe_create_screen.dart';
import 'package:barista_helper/features/recipes/screens/recipe_details_screen.dart';
import 'package:barista_helper/features/recipes/screens/recipe_interactive_screen.dart';
import 'package:barista_helper/features/recipes/screens/recipes_list_screen.dart';
import 'package:barista_helper/features/recipes/screens/methods_screen.dart';

import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) {
      _resetTabToRoot(index);
      if (index == 1) {
        GetIt.I<NotesBloc>().add(LoadNotesEvent());
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _resetTabToRoot(int tabIndex) {
    _navigatorKeys[tabIndex].currentState?.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildOffstageNavigator(0),
          _buildOffstageNavigator(1),
          _buildOffstageNavigator(2),
          _buildOffstageNavigator(3),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        activeIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) {
          Widget page;
          final authState = context.read<AuthBloc>().state;
          switch (index) {
            case 0:
              if (settings.name == '/recipes') {
                page = RecipeListScreen(
                  method: settings.arguments as BrewingMethod,
                );
              } else if (settings.name == '/recipeDetails') {
                page = RecipeDetailsScreen(recipeId: settings.arguments as int);
              } else if (settings.name == '/createRecipe') {
                page = CreateRecipeScreen(
                  isEditing: settings.arguments != null,
                  initialRecipe: settings.arguments as RecipeDetails?,
                );
              } else if (settings.name == '/interactiveBrew') {
                page = InteractiveBrewScreen(
                  recipe: settings.arguments as RecipeDetails,
                );
              } else if (settings.name == '/brewComplete') {
                final args = settings.arguments as Map<String, dynamic>;
                page = BrewCompleteScreen(
                  recipe: args['recipe'] as RecipeDetails,
                  totalTime: args['totalTime'] as String,
                );
              } else {
                page = const MethodsScreen();
              }
              break;

            case 1:
              if (settings.name == '/noteDetails') {
                page = const NoteDetailsScreen();
              } else {
                page = const NotesScreen();
              }
              break;

            case 2:
              page = const DictionaryScreen();
              break;

            case 3:
              if (settings.name == '/signup') {
                page = const SignUpScreen();
              } else if (settings.name == '/accountSettings') {
                page = const AccountSettingsScreen();
              } else if (settings.name == '/appearance') {
                page = const AppearanceScreen();
              } else if (settings.name == '/privacy') {
                page = const PrivacyScreen();
              } else if (settings.name == '/help') {
                page = const HelpScreen();
              } else if (settings.name == '/signin') {
                page = const SignInScreen();
              } else if (settings.name == '/profile') {
                page =
                    authState is Authenticated
                        ? const ProfileScreen()
                        : const SignInScreen();
              } else {
                page =
                    authState is Authenticated
                        ? const ProfileScreen()
                        : const SignInScreen();
              }
              break;

            default:
              page = Container();
          }

          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }
}
