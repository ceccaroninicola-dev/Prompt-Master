import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prompt_master/config/app_routes.dart';
import 'package:prompt_master/providers/sessione_provider.dart';

/// Schermata di input libero — prima fase del flusso di creazione prompt.
/// Design minimal stile Apple: superfici pulite, teal come accento, ombre sottili.
class InputLiberoScreen extends StatefulWidget {
  const InputLiberoScreen({super.key});

  @override
  State<InputLiberoScreen> createState() => _InputLiberoScreenState();
}

class _InputLiberoScreenState extends State<InputLiberoScreen> {
  // Controller per il campo di testo
  final _testoController = TextEditingController();

  // Nodo di focus per gestire la tastiera
  final _focusNode = FocusNode();

  // Indica se il bottone di invio deve essere attivo
  bool _testoValido = false;

  @override
  void initState() {
    super.initState();
    // Ascolta i cambiamenti del testo per abilitare/disabilitare il bottone
    _testoController.addListener(() {
      setState(() {
        _testoValido = _testoController.text.trim().length >= 5;
      });
    });
  }

  @override
  void dispose() {
    _testoController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Invia la frase e avvia l'analisi
  Future<void> _inviaFrase() async {
    if (!_testoValido) return;

    final provider = context.read<SessioneProvider>();
    final navigator = Navigator.of(context);

    // Avvia la sessione con la frase dell'utente
    await provider.avviaSessione(_testoController.text.trim());

    // Naviga alla schermata di conferma categoria
    if (mounted) {
      navigator.pushNamed(AppRoutes.confermaCategoria);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final staAnalizzando = context.watch<SessioneProvider>().staAnalizzando;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo Prompt'),
        actions: [
          // Bottone Home — torna alla Home cancellando lo stack
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Torna alla Home',
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.home,
              (route) => false,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titolo
              Text(
                'Cosa vuoi ottenere?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              // Istruzioni
              Text(
                'Descrivi con parole tue cosa vorresti che l\'AI facesse per te. '
                'Più dettagli dai, migliore sarà il prompt generato.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),

              // Campo di testo principale
              Expanded(
                child: TextField(
                  controller: _testoController,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  enabled: !staAnalizzando,
                  decoration: InputDecoration(
                    hintText:
                        'Es. "Voglio scrivere un post LinkedIn per lanciare '
                        'il mio nuovo prodotto SaaS per piccole imprese"',
                    hintMaxLines: 3,
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 15,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 16),

              // Suggerimenti rapidi
              if (!staAnalizzando) ...[
                Text(
                  'Esempi rapidi:',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chipEsempio(
                      'Scrivi un\'email professionale',
                      Icons.email_outlined,
                    ),
                    _chipEsempio(
                      'Aiutami con codice Python',
                      Icons.code,
                    ),
                    _chipEsempio(
                      'Crea un\'immagine per il mio brand',
                      Icons.image_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Bottone di invio / indicatore di caricamento
              SizedBox(
                width: double.infinity,
                height: 56,
                child: staAnalizzando
                    ? _buildIndicatoreCaricamento(colorScheme)
                    : ElevatedButton.icon(
                        onPressed: _testoValido ? _inviaFrase : null,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        label: const Text('Analizza e prosegui'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Chip cliccabile con esempio rapido — stile minimal teal
  Widget _chipEsempio(String testo, IconData icona) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(icona, size: 16, color: colorScheme.primary),
      label: Text(
        testo,
        style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
      ),
      backgroundColor: colorScheme.surfaceContainerLow,
      side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: () {
        _testoController.text = testo;
        _testoController.selection = TextSelection.fromPosition(
          TextPosition(offset: testo.length),
        );
      },
    );
  }

  /// Indicatore di caricamento durante l'analisi AI
  Widget _buildIndicatoreCaricamento(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Analizzo la tua richiesta...',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
