import 'package:flutter/material.dart';
import 'package:ideai/config/app_routes.dart';

/// Barra di navigazione inferiore condivisa tra Home e Cronologia.
/// Tre tab: Home, Crea (apre il flusso creazione), Cronologia.
class BarraNavigazione extends StatelessWidget {
  /// Indice della tab attualmente selezionata (0 = Home, 2 = Cronologia)
  final int indiceCorrente;

  const BarraNavigazione({super.key, required this.indiceCorrente});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: indiceCorrente,
      onDestinationSelected: (indice) {
        if (indice == indiceCorrente) return; // Già sulla tab

        if (indice == 1) {
          // "Crea" apre il flusso creazione come rotta separata
          Navigator.of(context).pushNamed(AppRoutes.inputLibero);
        } else if (indice == 0) {
          // Torna alla Home sostituendo la rotta corrente
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else if (indice == 2) {
          // Vai alla Cronologia sostituendo la rotta corrente
          Navigator.of(context).pushReplacementNamed(AppRoutes.cronologia);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: 'Crea',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'Cronologia',
        ),
      ],
    );
  }
}
