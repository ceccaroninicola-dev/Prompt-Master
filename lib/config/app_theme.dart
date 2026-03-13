import 'package:flutter/material.dart';

/// Configurazione dei temi dell'applicazione.
/// Gestisce sia il tema chiaro (light) che quello scuro (dark).
class AppTheme {
  // Colori principali dell'app
  static const Color _coloPrimario = Color(0xFF6C63FF);
  static const Color _coloreSecondario = Color(0xFF03DAC6);

  /// Tema chiaro (light mode)
  static ThemeData temaChiaro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _coloPrimario,
      secondary: _coloreSecondario,
      brightness: Brightness.light,
    ),
    // Stile della AppBar
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    // Stile dei bottoni elevati
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  /// Tema scuro (dark mode)
  static ThemeData temaScuro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _coloPrimario,
      secondary: _coloreSecondario,
      brightness: Brightness.dark,
    ),
    // Stile della AppBar
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    // Stile dei bottoni elevati
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
