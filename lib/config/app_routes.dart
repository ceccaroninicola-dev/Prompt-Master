import 'package:flutter/material.dart';
import 'package:prompt_master/screens/home/home_screen.dart';

/// Configurazione delle rotte dell'applicazione.
/// Gestisce la navigazione tra le schermate.
class AppRoutes {
  // Nomi delle rotte
  static const String home = '/';

  /// Mappa delle rotte disponibili nell'app
  static Map<String, WidgetBuilder> rotte = {
    home: (context) => const HomeScreen(),
  };
}
