part of 'theme_bloc.dart';

abstract class ThemeState {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
}

class ThemeInitial extends ThemeState {
  const ThemeInitial() : super(ThemeMode.light);
}

class ThemeChanged extends ThemeState {
  const ThemeChanged(super.mode);
}
