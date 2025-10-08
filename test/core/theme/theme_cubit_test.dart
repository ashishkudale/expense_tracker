import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/theme/theme_cubit.dart';

void main() {
  group('ThemeCubit', () {
    late ThemeCubit themeCubit;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      themeCubit = ThemeCubit(prefs);
    });

    tearDown(() {
      themeCubit.close();
    });

    test('initial state is AppThemeMode.system', () {
      expect(themeCubit.state, AppThemeMode.system);
    });

    test('setTheme updates state to light mode', () async {
      await themeCubit.setTheme(AppThemeMode.light);
      expect(themeCubit.state, AppThemeMode.light);
      expect(prefs.getInt('theme_mode'), AppThemeMode.light.index);
    });

    test('setTheme updates state to dark mode', () async {
      await themeCubit.setTheme(AppThemeMode.dark);
      expect(themeCubit.state, AppThemeMode.dark);
      expect(prefs.getInt('theme_mode'), AppThemeMode.dark.index);
    });

    test('setTheme updates state to system mode', () async {
      await themeCubit.setTheme(AppThemeMode.light);
      await themeCubit.setTheme(AppThemeMode.system);
      expect(themeCubit.state, AppThemeMode.system);
      expect(prefs.getInt('theme_mode'), AppThemeMode.system.index);
    });

    test('themeMode getter returns correct ThemeMode for system', () {
      expect(themeCubit.themeMode, ThemeMode.system);
    });

    test('themeMode getter returns correct ThemeMode for light', () async {
      await themeCubit.setTheme(AppThemeMode.light);
      expect(themeCubit.themeMode, ThemeMode.light);
    });

    test('themeMode getter returns correct ThemeMode for dark', () async {
      await themeCubit.setTheme(AppThemeMode.dark);
      expect(themeCubit.themeMode, ThemeMode.dark);
    });

    test('loads saved theme from preferences', () async {
      await prefs.setInt('theme_mode', AppThemeMode.dark.index);
      final newCubit = ThemeCubit(prefs);
      expect(newCubit.state, AppThemeMode.dark);
      newCubit.close();
    });
  });
}