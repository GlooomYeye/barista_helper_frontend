import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'app_theme';
  final SharedPreferences _prefs;

  ThemeBloc(this._prefs) : super(const ThemeInitial()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final themeIndex = _prefs.getInt(_themeKey);
    if (themeIndex != null) {
      final themeMode = ThemeMode.values[themeIndex];
      emit(ThemeChanged(themeMode));
    }
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _prefs.setInt(_themeKey, event.themeMode.index);
    emit(ThemeChanged(event.themeMode));
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            event.themeMode == ThemeMode.dark
                ? const Color(0xFF121212)
                : Colors.white,
        systemNavigationBarIconBrightness:
            event.themeMode == ThemeMode.dark
                ? Brightness.light
                : Brightness.dark,
      ),
    );
  }
}
