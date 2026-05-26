import 'package:flutter/material.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:signals/signals_flutter.dart';

class ThemeState {
  final isDarkMode = signal<bool>(false);
  final seedColor = signal<Color>(Colors.deepPurple);

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
  }

  void setSeedColor(Color color) {
    seedColor.value = color;
  }
}

final themeStateRef = Ref.scoped((_) => ThemeState());
