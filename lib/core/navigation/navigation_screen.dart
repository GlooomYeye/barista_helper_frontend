import 'package:barista_helper/core/navigation/bottom_nav_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barista_helper/domain/models/brewing_method.dart';
import 'package:barista_helper/domain/models/recipe_details.dart';
import 'package:barista_helper/features/auth/bloc/auth_bloc.dart';
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
  MainNavigationScreenState createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex == index) {
      _resetTabToRoot(index);
    } else {
      setState(() => _currentIndex = index);
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
                page = MethodsScreen();
              }
              break;

            case 1:
              if (settings.name == '/noteDetails') {
                page = NoteDetailsScreen();
              } else {
                page = NotesScreen();
              }
              break;

            case 2:
              page = DictionaryScreen();
              break;

            case 3:
              if (settings.name == '/signup') {
                page = SignUpScreen();
              } else if (settings.name == '/accountSettings') {
                page = AccountSettingsScreen();
              } else if (settings.name == '/appearance') {
                page = AppearanceScreen();
              } else if (settings.name == '/privacy') {
                page = PrivacyScreen();
              } else if (settings.name == '/help') {
                page = HelpScreen();
              } else if (settings.name == '/signin') {
                page = SignInScreen();
              } else if (settings.name == '/profile') {
                page =
                    authState is Authenticated
                        ? ProfileScreen()
                        : SignInScreen();
              } else {
                page =
                    authState is Authenticated
                        ? ProfileScreen()
                        : SignInScreen();
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
