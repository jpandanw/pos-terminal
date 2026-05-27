import 'package:flutter/material.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

class ThemeState {
  final isDarkMode = signal<bool>(false);
  final seedColor = signal<Color>(Colors.deepPurple);

  ThemeState() {
    _loadState();
  }

  static const _darkModeKey = 'theme_is_dark_mode';
  static const _seedColorKey = 'theme_seed_color';

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_darkModeKey)) {
        isDarkMode.value = prefs.getBool(_darkModeKey) ?? false;
      }
      if (prefs.containsKey(_seedColorKey)) {
        final colorValue = prefs.getInt(_seedColorKey);
        if (colorValue != null) {
          seedColor.value = Color(colorValue);
        }
      }
    } catch (e) {
      debugPrint('Error loading theme state: $e');
    }
  }

  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, isDarkMode.value);
    } catch (e) {
      debugPrint('Error saving dark mode state: $e');
    }
  }

  Future<void> setSeedColor(Color color) async {
    seedColor.value = color;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_seedColorKey, color.toARGB32());
    } catch (e) {
      debugPrint('Error saving seed color state: $e');
    }
  }
}

final themeStateRef = Ref.scoped((_) => ThemeState());
