import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeCubit extends Cubit<AppThemeMode> {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;
  
  ThemeCubit(this._prefs) : super(AppThemeMode.system) {
    _loadTheme();
  }
  
  void _loadTheme() {
    final themeIndex = _prefs.getInt(_themeKey) ?? 0;
    emit(AppThemeMode.values[themeIndex]);
  }
  
  Future<void> setTheme(AppThemeMode mode) async {
    await _prefs.setInt(_themeKey, mode.index);
    emit(mode);
  }
  
  ThemeMode get themeMode {
    switch (state) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}