import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ideai/config/app_theme.dart';
import 'package:ideai/config/app_routes.dart';
import 'package:ideai/providers/theme_provider.dart';
import 'package:ideai/providers/sessione_provider.dart';
import 'package:ideai/providers/prompt_generato_provider.dart';
import 'package:ideai/providers/cronologia_provider.dart';
import 'package:ideai/providers/libreria_provider.dart';
import 'package:ideai/providers/confronto_ai_provider.dart';
import 'package:ideai/providers/community_provider.dart';
import 'package:ideai/services/api_service.dart';
import 'package:ideai/services/ad_service.dart';

/// Entry point dell'applicazione IdeAI.
/// Configura i provider globali, inizializza l'API key, AdMob e avvia l'app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza la API key da variabile d'ambiente (se disponibile)
  // Su web, usa --dart-define=OPENAI_API_KEY=sk-xxx durante il build
  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  if (apiKey.isNotEmpty) {
    ApiService().impostaApiKey(apiKey);
  }

  // Inizializza AdMob (su web è un no-op automatico)
  await AdService().inizializza();

  // Richiesta consenso GDPR (obbligatoria per l'Europa)
  // Il form appare solo se necessario (utenti EU)
  AdService().richiestaConsensoGDPR();

  runApp(const PromptMasterApp());
}

/// Widget radice dell'applicazione.
/// Utilizza MultiProvider per iniettare i provider globali
/// e gestisce il tema chiaro/scuro tramite ThemeProvider.
class PromptMasterApp extends StatelessWidget {
  const PromptMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Lista dei provider globali disponibili in tutta l'app
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SessioneProvider()),
        ChangeNotifierProvider(create: (_) => PromptGeneratoProvider()),
        ChangeNotifierProvider(create: (_) => CronologiaProvider()),
        ChangeNotifierProvider(create: (_) => LibreriaProvider()),
        ChangeNotifierProvider(create: (_) => ConfrontoAIProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'IdeAI',
            debugShowCheckedModeBanner: false,

            // Configurazione dei temi
            theme: AppTheme.temaChiaro,
            darkTheme: AppTheme.temaScuro,
            themeMode: themeProvider.modalitaTema,

            // Configurazione delle rotte
            initialRoute: AppRoutes.home,
            routes: AppRoutes.rotte,
          );
        },
      ),
    );
  }
}
