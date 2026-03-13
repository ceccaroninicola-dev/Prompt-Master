import 'package:flutter/material.dart';
import 'package:prompt_master/config/app_routes.dart';
import 'package:prompt_master/providers/theme_provider.dart';
import 'package:provider/provider.dart';

/// Schermata principale (Home) dell'app Prompt Master.
/// Mostra il titolo dell'app e i bottoni per le azioni principali:
/// - Crea nuovo prompt
/// - Libreria
/// - Cronologia
/// Include anche un toggle per il tema chiaro/scuro.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Otteniamo il provider del tema per gestire il toggle
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt Master'),
        actions: [
          // Bottone per alternare tra tema chiaro e scuro
          IconButton(
            icon: Icon(
              themeProvider.modalitaTema == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Cambia tema',
            onPressed: () => themeProvider.cambiaTema(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icona decorativa dell'app
                Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),

                // Titolo principale
                Text(
                  'Prompt Master',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),

                // Sottotitolo descrittivo
                Text(
                  'Il tuo assistente per creare prompt perfetti',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Bottone "Crea nuovo prompt"
                _buildBottoneHome(
                  context: context,
                  icona: Icons.add_circle_outline,
                  etichetta: 'Crea nuovo prompt',
                  descrizione: 'Crea un prompt da zero con l\'aiuto dell\'AI',
                  colore: colorScheme.primary,
                  onPressed: () {
                    // Naviga alla schermata di input libero
                    Navigator.of(context).pushNamed(AppRoutes.inputLibero);
                  },
                ),
                const SizedBox(height: 16),

                // Bottone "Libreria"
                _buildBottoneHome(
                  context: context,
                  icona: Icons.library_books_outlined,
                  etichetta: 'Libreria',
                  descrizione: 'Sfoglia i tuoi prompt salvati',
                  colore: colorScheme.secondary,
                  onPressed: () {
                    // TODO: Navigare alla schermata libreria
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funzionalità in arrivo!'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Bottone "Cronologia"
                _buildBottoneHome(
                  context: context,
                  icona: Icons.history,
                  etichetta: 'Cronologia',
                  descrizione: 'Rivedi i prompt usati di recente',
                  colore: colorScheme.tertiary,
                  onPressed: () {
                    // TODO: Navigare alla schermata cronologia
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funzionalità in arrivo!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Costruisce un bottone stilizzato per la schermata Home.
  /// Ogni bottone ha un'icona, un'etichetta, una descrizione e un colore.
  Widget _buildBottoneHome({
    required BuildContext context,
    required IconData icona,
    required String etichetta,
    required String descrizione,
    required Color colore,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icona del bottone con sfondo colorato
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colore.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icona, color: colore, size: 28),
                ),
                const SizedBox(width: 16),
                // Testo del bottone (etichetta + descrizione)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        etichetta,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descrizione,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                // Freccia indicante navigazione
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
