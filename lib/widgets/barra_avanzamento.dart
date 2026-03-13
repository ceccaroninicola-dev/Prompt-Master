import 'package:flutter/material.dart';

/// Widget che mostra una barra di avanzamento adattiva.
/// La barra si aggiorna dinamicamente durante la sessione di domande.
/// Mostra la percentuale di completamento e il numero della domanda corrente.
class BarraAvanzamento extends StatelessWidget {
  /// Percentuale di completamento (da 0.0 a 1.0)
  final double percentuale;

  /// Indice della domanda corrente (0-based)
  final int domandaCorrente;

  /// Numero totale di domande
  final int totaleDomande;

  /// Callback quando l'utente tocca un punto specifico della barra
  /// per navigare a una domanda precedente
  final ValueChanged<int>? onTapDomanda;

  const BarraAvanzamento({
    super.key,
    required this.percentuale,
    required this.domandaCorrente,
    required this.totaleDomande,
    this.onTapDomanda,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Riga con testo di stato e percentuale
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Indicatore domanda corrente
              Text(
                totaleDomande > 0
                    ? 'Domanda ${domandaCorrente + 1} di $totaleDomande'
                    : 'Analisi in corso...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              // Percentuale di completamento
              Text(
                '${(percentuale * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Barra di avanzamento animata con indicatori per ogni domanda
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Sfondo della barra
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Riempimento animato della barra
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  height: 8,
                  width: constraints.maxWidth * percentuale.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Indicatori cliccabili per ogni domanda (punti sulla barra)
                if (totaleDomande > 0)
                  SizedBox(
                    height: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(totaleDomande, (indice) {
                        // Determina se questa domanda è stata completata
                        final completata = indice < domandaCorrente;
                        final corrente = indice == domandaCorrente;

                        return GestureDetector(
                          onTap: completata && onTapDomanda != null
                              ? () => onTapDomanda!(indice)
                              : null,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: completata
                                  ? colorScheme.primary
                                  : corrente
                                      ? colorScheme.primaryContainer
                                      : Colors.transparent,
                              border: corrente
                                  ? Border.all(
                                      color: colorScheme.primary,
                                      width: 2,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
