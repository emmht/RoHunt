import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeService {
  ThemeModeService._();

  static const String _themeModeKey = 'theme_mode';

  static final ValueNotifier<ThemeMode> notifier = ValueNotifier(
    ThemeMode.light,
  );

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final savedThemeMode = preferences.getString(_themeModeKey);

    notifier.value = savedThemeMode == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  static bool get isDarkMode => notifier.value == ThemeMode.dark;

  static Future<void> setDarkMode(bool isDarkMode) async {
    final themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifier.value = themeMode;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, isDarkMode ? 'dark' : 'light');
  }
}
