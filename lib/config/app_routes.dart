import 'package:flutter/material.dart';
import 'package:ideai/screens/home/home_screen.dart';
import 'package:ideai/screens/prompt_creation/input_libero_screen.dart';
import 'package:ideai/screens/prompt_creation/conferma_categoria_screen.dart';
import 'package:ideai/screens/prompt_creation/domande_screen.dart';
import 'package:ideai/screens/prompt_creation/post_generazione_screen.dart';
import 'package:ideai/screens/cronologia/cronologia_screen.dart';
import 'package:ideai/screens/libreria/libreria_screen.dart';
import 'package:ideai/screens/libreria/dettaglio_template_screen.dart';
import 'package:ideai/screens/confronto_ai/confronto_ai_screen.dart';
import 'package:ideai/screens/profilo/profilo_screen.dart';
import 'package:ideai/screens/community/community_screen.dart';
import 'package:ideai/screens/community/dettaglio_prompt_pubblico_screen.dart';
import 'package:ideai/screens/impostazioni/impostazioni_screen.dart';

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
  static const String libreria = '/libreria';
  static const String dettaglioTemplate = '/libreria/dettaglio';
  static const String confrontoAI = '/confronto-ai';
  static const String profilo = '/profilo';
  static const String community = '/community';
  static const String dettaglioPromptPubblico = '/community/dettaglio';
  static const String impostazioni = '/impostazioni';

  /// Mappa delle rotte disponibili nell'app
  static Map<String, WidgetBuilder> rotte = {
    home: (context) => const HomeScreen(),
    inputLibero: (context) => const InputLiberoScreen(),
    confermaCategoria: (context) => const ConfermaCategoriaScreen(),
    domande: (context) => const DomandeScreen(),
    postGenerazione: (context) => const PostGenerazioneScreen(),
    cronologia: (context) => const CronologiaScreen(),
    libreria: (context) => const LibreriaScreen(),
    dettaglioTemplate: (context) => const DettaglioTemplateScreen(),
    confrontoAI: (context) => const ConfrontoAIScreen(),
    profilo: (context) => const ProfiloScreen(),
    community: (context) => const CommunityScreen(),
    dettaglioPromptPubblico: (context) => const DettaglioPromptPubblicoScreen(),
    impostazioni: (context) => const ImpostazioniScreen(),
  };
}
