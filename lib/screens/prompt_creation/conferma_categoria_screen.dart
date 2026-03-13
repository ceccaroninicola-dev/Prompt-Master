import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prompt_master/config/app_routes.dart';
import 'package:prompt_master/providers/sessione_provider.dart';

/// Schermata di conferma categoria — seconda fase del flusso.
/// Mostra all'utente la categoria rilevata e un riepilogo di ciò che
/// l'app ha capito dalla frase iniziale.
/// L'utente può confermare per proseguire o tornare indietro per riformulare.
class ConfermaCategoriaScreen extends StatelessWidget {
  const ConfermaCategoriaScreen({super.key});

  /// Restituisce l'icona Material corrispondente al nome dell'icona della categoria
  IconData _getIcona(String nomeIcona) {
    switch (nomeIcona) {
      case 'code':
        return Icons.code;
      case 'image':
        return Icons.image;
      case 'edit_note':
        return Icons.edit_note;
      default:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sessione = context.watch<SessioneProvider>().sessione;
    final categoria = sessione.categoria;

    // Se la categoria non è stata rilevata, torna indietro
    if (categoria == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conferma categoria'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Icona della categoria con sfondo decorativo
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIcona(categoria.icona),
                          size: 48,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nome della categoria
                      Text(
                        categoria.nome,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),

                      // Sottocategoria (se presente)
                      if (categoria.sottocategoria != null)
                        Chip(
                          label: Text(
                            categoria.sottocategoria!,
                            style: TextStyle(color: colorScheme.primary),
                          ),
                          backgroundColor:
                              colorScheme.primaryContainer.withValues(alpha: 0.5),
                          side: BorderSide.none,
                        ),
                      const SizedBox(height: 24),

                      // Card con il riepilogo di ciò che l'app ha capito
                      Card(
                        elevation: 0,
                        color: colorScheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Intestazione del riepilogo
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ecco cosa ho capito',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Testo del riepilogo
                              Text(
                                categoria.riepilogo,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),

                              // Frase originale dell'utente
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'La tua richiesta:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color:
                                                colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '"${sessione.fraseIniziale}"',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Elementi chiave estratti dalla frase
                      if (categoria.elementiChiave.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Parole chiave rilevate:',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categoria.elementiChiave
                              .map((elemento) => Chip(
                                    label: Text(elemento),
                                    backgroundColor:
                                        colorScheme.secondaryContainer,
                                    side: BorderSide.none,
                                    labelStyle: TextStyle(
                                      color:
                                          colorScheme.onSecondaryContainer,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottoni di azione in basso
              const SizedBox(height: 16),
              Row(
                children: [
                  // Bottone "Riformula" — torna alla schermata precedente
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Riformula'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Bottone "Prosegui" — conferma e va alle domande
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Conferma la categoria e naviga alle domande
                        context.read<SessioneProvider>().confermCategoria();
                        Navigator.of(context)
                            .pushNamed(AppRoutes.domande);
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Prosegui'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
