import 'package:flutter/material.dart';
import 'package:prompt_master/screens/home/home_screen.dart';
import 'package:prompt_master/screens/prompt_creation/input_libero_screen.dart';
import 'package:prompt_master/screens/prompt_creation/conferma_categoria_screen.dart';
import 'package:prompt_master/screens/prompt_creation/domande_screen.dart';
import 'package:prompt_master/screens/prompt_creation/post_generazione_screen.dart';
import 'package:prompt_master/screens/cronologia/cronologia_screen.dart';

/// Configurazione delle rotte dell'applicazione.
/// Gestisce la navigazione tra le schermate.
class AppRoutes {
  // Nomi delle rotte
  static const String home = '/';
  static const String inputLibero = '/crea/input-libero';
  static const String confermaCategoria = '/crea/conferma-categoria';
  static const String domande = '/crea/domande';
  static const String postGenerazione = '/crea/post-generazione';
  static const String cronologia = '/cronologia';

  /// Mappa delle rotte disponibili nell'app
  static Map<String, WidgetBuilder> rotte = {
    home: (context) => const HomeScreen(),
    inputLibero: (context) => const InputLiberoScreen(),
    confermaCategoria: (context) => const ConfermaCategoriaScreen(),
    domande: (context) => const DomandeScreen(),
    postGenerazione: (context) => const PostGenerazioneScreen(),
    cronologia: (context) => const CronologiaScreen(),
  };
}
