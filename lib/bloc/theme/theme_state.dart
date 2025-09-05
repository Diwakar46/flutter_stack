import 'package:flutter/material.dart';

class ThemeState {
  final ThemeData themeData;
  final bool isDark;

  const ThemeState({
    required this.themeData,
    required this.isDark,
  });

  static ThemeState get light => ThemeState(
    themeData: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    ),
    isDark: false,
  );

  static ThemeState get dark => ThemeState(
    themeData: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0E161F),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    isDark: true,
  );
}