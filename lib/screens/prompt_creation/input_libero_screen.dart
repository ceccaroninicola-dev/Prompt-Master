import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prompt_master/config/app_routes.dart';
import 'package:prompt_master/providers/sessione_provider.dart';

/// Schermata di input libero — prima fase del flusso di creazione prompt.
/// L'utente scrive o detta una frase libera che descrive cosa vuole ottenere.
/// Dopo l'invio, l'app analizza la frase e naviga alla schermata di conferma categoria.
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
    // Osserva lo stato di caricamento dal provider
    final staAnalizzando = context.watch<SessioneProvider>().staAnalizzando;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo Prompt'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titolo e istruzioni
              Text(
                'Cosa vuoi ottenere?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Descrivi con parole tue cosa vorresti che l\'AI facesse per te. '
                'Più dettagli dai, migliore sarà il prompt generato.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),

              // Campo di testo principale per la frase libera
              Expanded(
                child: TextField(
                  controller: _testoController,
                  focusNode: _focusNode,
                  maxLines: null, // Permette testo su più righe
                  expands: true, // Occupa tutto lo spazio disponibile
                  textAlignVertical: TextAlignVertical.top,
                  enabled: !staAnalizzando,
                  decoration: InputDecoration(
                    hintText:
                        'Es. "Voglio scrivere un post LinkedIn per lanciare '
                        'il mio nuovo prodotto SaaS per piccole imprese"',
                    hintMaxLines: 3,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
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

              // Suggerimenti rapidi per ispirare l'utente
              if (!staAnalizzando) ...[
                Text(
                  'Esempi rapidi:',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
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
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Analizza e prosegui'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Costruisce un chip cliccabile con un esempio rapido.
  /// Al tap, inserisce il testo dell'esempio nel campo di input.
  Widget _chipEsempio(String testo, IconData icona) {
    return ActionChip(
      avatar: Icon(icona, size: 18),
      label: Text(testo, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        _testoController.text = testo;
        // Sposta il cursore alla fine del testo
        _testoController.selection = TextSelection.fromPosition(
          TextPosition(offset: testo.length),
        );
      },
    );
  }

  /// Costruisce l'indicatore di caricamento durante l'analisi AI
  Widget _buildIndicatoreCaricamento(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Analizzo la tua richiesta...',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
