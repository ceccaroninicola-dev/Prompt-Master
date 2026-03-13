import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prompt_master/config/app_theme.dart';
import 'package:prompt_master/config/app_routes.dart';
import 'package:prompt_master/providers/theme_provider.dart';
import 'package:prompt_master/providers/sessione_provider.dart';

/// Entry point dell'applicazione Prompt Master.
/// Configura i provider globali e avvia l'app.
void main() {
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
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Prompt Master',
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
