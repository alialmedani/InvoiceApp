import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoice/core/classes/cashe_helper.dart';

/// Persists the user's light/dark preference via [CacheHelper] (Hive-backed,
/// key `theme_mode`). Only light and dark are offered — no system option.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_fromStored(CacheHelper.themeMode));

  static ThemeMode _fromStored(String value) =>
      value == 'dark' ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleDark(bool isDark) async {
    await CacheHelper.setThemeMode(isDark ? 'dark' : 'light');
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
