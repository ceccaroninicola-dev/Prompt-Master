import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:prompt_master/models/prompt_generato.dart';
import 'package:prompt_master/providers/prompt_generato_provider.dart';
import 'package:prompt_master/providers/sessione_provider.dart';
import 'package:prompt_master/providers/cronologia_provider.dart';
import 'package:prompt_master/services/export_service.dart';

/// Schermata post-generazione — mostra il prompt generato con:
/// - Anteprima in due viste (semplice/strutturata)
/// - Modifica inline per sezione
/// - Scoring a stelle con breakdown per criterio
/// - Suggerimenti di miglioramento con anteprima prima/dopo
/// - Barra azioni (copia, esporta, salva)
class PostGenerazioneScreen extends StatefulWidget {
  const PostGenerazioneScreen({super.key});

  @override
  State<PostGenerazioneScreen> createState() => _PostGenerazioneScreenState();
}

class _PostGenerazioneScreenState extends State<PostGenerazioneScreen> {
  /// true = vista strutturata, false = vista semplice
  bool _vistaStrutturata = false;

  /// Indice della sezione in fase di modifica (-1 = nessuna)
  int _sezioneInModifica = -1;

  /// Controller per il campo di modifica inline
  final _editController = TextEditingController();

  /// AI di destinazione selezionata (null = non ancora scelta)
  String? _aiSelezionata;

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  /// Mappa nome icona → IconData Material
  IconData _getIcona(String nome) {
    switch (nome) {
      case 'person':
        return Icons.person_outline;
      case 'info':
        return Icons.info_outline;
      case 'list':
        return Icons.checklist_rounded;
      case 'format_align_left':
        return Icons.format_align_left;
      case 'block':
        return Icons.block_outlined;
      case 'lightbulb':
        return Icons.lightbulb_outline;
      case 'record_voice_over':
        return Icons.record_voice_over_outlined;
      default:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<PromptGeneratoProvider>();
    final prompt = provider.prompt;

    // Schermata di caricamento durante la generazione
    if (provider.staGenerando || prompt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Generazione...')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                'Genero il tuo prompt...',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Il tuo prompt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Contenuto scrollabile
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Scoring a stelle ---
                    _buildScoring(prompt, colorScheme, isDark),
                    const SizedBox(height: 20),

                    // --- Toggle vista semplice/strutturata ---
                    _buildToggleVista(colorScheme),
                    const SizedBox(height: 16),

                    // --- Anteprima del prompt ---
                    _vistaStrutturata
                        ? _buildVistaStrutturata(prompt, colorScheme, isDark)
                        : _buildVistaSemplice(prompt, colorScheme, isDark),
                    const SizedBox(height: 24),

                    // --- Suggerimenti di miglioramento ---
                    if (prompt.suggerimenti.isNotEmpty) ...[
                      Text(
                        'Migliora il tuo prompt',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildSuggerimenti(prompt, colorScheme),
                    ],
                  ],
                ),
              ),
            ),

            // --- Barra azioni in basso ---
            _buildBarraAzioni(prompt, colorScheme, isDark),
          ],
        ),
      ),
    );
  }

  // ========== SCORING A STELLE ==========

  Widget _buildScoring(
    PromptGenerato prompt,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        children: [
          // Punteggio globale con stelle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (i) {
                final valore = prompt.punteggioGlobale - i;
                return Icon(
                  valore >= 1
                      ? Icons.star_rounded
                      : valore >= 0.5
                          ? Icons.star_half_rounded
                          : Icons.star_outline_rounded,
                  color: colorScheme.primary,
                  size: 28,
                );
              }),
              const SizedBox(width: 10),
              Text(
                '${prompt.punteggioGlobale}/5',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Breakdown per criterio
          ...prompt.punteggiCriteri.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: entry.value / 5,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: colorScheme.primary,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${entry.value}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ========== TOGGLE VISTA ==========

  Widget _buildToggleVista(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleOpzione(
            etichetta: 'Semplice',
            icona: Icons.subject_rounded,
            selezionato: !_vistaStrutturata,
            colorScheme: colorScheme,
            onTap: () => setState(() {
              _vistaStrutturata = false;
              _sezioneInModifica = -1;
            }),
          ),
          _buildToggleOpzione(
            etichetta: 'Strutturata',
            icona: Icons.view_agenda_outlined,
            selezionato: _vistaStrutturata,
            colorScheme: colorScheme,
            onTap: () => setState(() => _vistaStrutturata = true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOpzione({
    required String etichetta,
    required IconData icona,
    required bool selezionato,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selezionato ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selezionato
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icona,
                size: 16,
                color: selezionato
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                etichetta,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selezionato ? FontWeight.w600 : FontWeight.w400,
                  color: selezionato
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== VISTA SEMPLICE ==========

  Widget _buildVistaSemplice(
    PromptGenerato prompt,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: SelectableText(
        prompt.testoCompleto,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
      ),
    );
  }

  // ========== VISTA STRUTTURATA ==========

  Widget _buildVistaStrutturata(
    PromptGenerato prompt,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Column(
      children: List.generate(prompt.sezioni.length, (indice) {
        final sezione = prompt.sezioni[indice];
        if (sezione.contenuto.isEmpty) return const SizedBox.shrink();

        final inModifica = _sezioneInModifica == indice;
        final coloreSezione = Color(sezione.colore);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _CardSezione(
            sezione: sezione,
            coloreSezione: coloreSezione,
            isDark: isDark,
            colorScheme: colorScheme,
            inModifica: inModifica,
            icona: _getIcona(sezione.icona),
            onTapModifica: () {
              setState(() {
                if (inModifica) {
                  _sezioneInModifica = -1;
                } else {
                  _sezioneInModifica = indice;
                  _editController.text = sezione.contenuto;
                }
              });
            },
            editController: _editController,
            onSalva: () {
              context.read<PromptGeneratoProvider>().aggiornaSezione(
                    indice,
                    _editController.text,
                  );
              setState(() => _sezioneInModifica = -1);
            },
            onAnnulla: () {
              setState(() => _sezioneInModifica = -1);
            },
          ),
        );
      }),
    );
  }

  // ========== SUGGERIMENTI ==========

  Widget _buildSuggerimenti(
    PromptGenerato prompt,
    ColorScheme colorScheme,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: prompt.suggerimenti.map((suggerimento) {
        return ActionChip(
          avatar: Icon(
            _getIcona(suggerimento.icona),
            size: 16,
            color: colorScheme.primary,
          ),
          label: Text(
            suggerimento.etichetta,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
          ),
          backgroundColor: colorScheme.surfaceContainerLow,
          side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: () => _mostraAnteprimaSuggerimento(
            suggerimento,
            colorScheme,
          ),
        );
      }).toList(),
    );
  }

  /// Bottom sheet con anteprima prima/dopo per un suggerimento
  void _mostraAnteprimaSuggerimento(
    SuggerimentoMiglioramento suggerimento,
    ColorScheme colorScheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildManiglia(colorScheme),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Icon(
                      _getIcona(suggerimento.icona),
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      suggerimento.etichetta,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Text(
                  suggerimento.descrizione,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEtichettaPrimaDopo('Prima', Colors.orange),
                      const SizedBox(height: 8),
                      _buildBoxTesto(suggerimento.testoPrima, colorScheme, isDark),
                      const SizedBox(height: 16),
                      _buildEtichettaPrimaDopo('Dopo', colorScheme.primary),
                      const SizedBox(height: 8),
                      _buildBoxTesto(suggerimento.testoDopo, colorScheme, isDark),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<PromptGeneratoProvider>()
                          .applicaSuggerimento(suggerimento);
                      Navigator.of(ctx).pop();
                    },
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('Applica miglioramento'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ========== BARRA AZIONI ==========

  Widget _buildBarraAzioni(
    PromptGenerato prompt,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final cronologia = context.watch<CronologiaProvider>();
    final giaSalvato = cronologia.isGiaSalvato(prompt);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bottone "Copia"
          Expanded(
            child: _buildBottoneAzione(
              icona: Icons.copy_rounded,
              etichetta: 'Copia',
              colorScheme: colorScheme,
              isPrimario: true,
              onPressed: () async {
                try {
                  await ExportService.copiaTestoNegliAppunti(prompt);
                  if (mounted) {
                    _mostraConferma(
                      Icons.check_circle,
                      'Prompt copiato negli appunti!',
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    _mostraConferma(
                      Icons.error_outline,
                      'Impossibile copiare il prompt',
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          // Bottone "Esporta" — apre il bottom sheet export
          Expanded(
            child: _buildBottoneAzione(
              icona: Icons.ios_share_rounded,
              etichetta: 'Esporta',
              colorScheme: colorScheme,
              isPrimario: false,
              onPressed: () => _mostraExportSheet(prompt, colorScheme),
            ),
          ),
          const SizedBox(width: 10),
          // Bottone "Salva" — salva nella cronologia in memoria
          Expanded(
            child: _buildBottoneAzione(
              icona: giaSalvato
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              etichetta: giaSalvato ? 'Salvato' : 'Salva',
              colorScheme: colorScheme,
              isPrimario: false,
              onPressed: giaSalvato
                  ? null
                  : () => _salvaPrompt(prompt, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  /// Salva il prompt nella cronologia
  void _salvaPrompt(PromptGenerato prompt, ColorScheme colorScheme) {
    final sessione = context.read<SessioneProvider>().sessione;
    context.read<CronologiaProvider>().salvaPrompt(
          prompt: prompt,
          categoria: sessione.categoria?.nome ?? 'Generico',
          fraseIniziale: sessione.fraseIniziale,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.bookmark_added, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Prompt salvato!'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ========== BOTTOM SHEET EXPORT ==========

  /// Mostra il bottom sheet con le opzioni di export e il selettore AI
  void _mostraExportSheet(PromptGenerato prompt, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildManiglia(colorScheme),
                  const SizedBox(height: 12),

                  // Titolo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.ios_share_rounded,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Esporta prompt',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Selettore AI di destinazione ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ottimizza per AI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildSelettoreAi(
                          colorScheme,
                          isDark,
                          (ai) => setSheetState(() => _aiSelezionata = ai),
                        ),
                      ],
                    ),
                  ),

                  // Messaggio ottimizzazione
                  if (_aiSelezionata != null && _aiSelezionata != 'Generico')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Prompt ottimizzato per $_aiSelezionata',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // --- Opzioni di export ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Metodo di esportazione',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Copia negli appunti
                        _buildOpzioneExport(
                          icona: Icons.copy_rounded,
                          etichetta: 'Copia negli appunti',
                          descrizione: 'Copia il prompt come testo',
                          colorScheme: colorScheme,
                          isDark: isDark,
                          onTap: () async {
                            Navigator.of(ctx).pop();
                            try {
                              await ExportService.copiaTestoNegliAppunti(prompt);
                              if (mounted) {
                                _mostraConferma(
                                  Icons.check_circle,
                                  'Prompt copiato negli appunti!',
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                _mostraConferma(
                                  Icons.error_outline,
                                  'Impossibile copiare il prompt',
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 8),

                        // Condividi come testo
                        _buildOpzioneExport(
                          icona: Icons.share_rounded,
                          etichetta: kIsWeb
                              ? 'Copia testo completo'
                              : 'Condividi come testo',
                          descrizione: kIsWeb
                              ? 'Copia il prompt negli appunti'
                              : 'WhatsApp, Telegram, Email...',
                          colorScheme: colorScheme,
                          isDark: isDark,
                          onTap: () async {
                            Navigator.of(ctx).pop();
                            try {
                              await ExportService.condividiTesto(prompt);
                              if (mounted) {
                                _mostraConferma(
                                  Icons.check_circle,
                                  'Prompt copiato negli appunti!',
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                _mostraConferma(
                                  Icons.error_outline,
                                  'Impossibile condividere il prompt',
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 8),

                        // Esporta come PDF
                        _buildOpzioneExport(
                          icona: Icons.picture_as_pdf_rounded,
                          etichetta: kIsWeb
                              ? 'Scarica PDF'
                              : 'Esporta come PDF',
                          descrizione: kIsWeb
                              ? 'Download diretto nel browser'
                              : 'Salva il prompt in formato PDF',
                          colorScheme: colorScheme,
                          isDark: isDark,
                          onTap: () async {
                            Navigator.of(ctx).pop();
                            await _esportaConFeedback(
                              () => ExportService.esportaPdf(
                                prompt,
                                nomeAiDestinazione: _aiSelezionata,
                              ),
                              messaggioSuccesso: kIsWeb
                                  ? 'PDF scaricato!'
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(height: 8),

                        // Esporta come TXT
                        _buildOpzioneExport(
                          icona: Icons.description_outlined,
                          etichetta: kIsWeb
                              ? 'Scarica TXT'
                              : 'Esporta come TXT',
                          descrizione: kIsWeb
                              ? 'Download diretto nel browser'
                              : 'Salva il prompt come file di testo',
                          colorScheme: colorScheme,
                          isDark: isDark,
                          onTap: () async {
                            Navigator.of(ctx).pop();
                            await _esportaConFeedback(
                              () => ExportService.esportaTxt(
                                prompt,
                                nomeAiDestinazione: _aiSelezionata,
                              ),
                              messaggioSuccesso: kIsWeb
                                  ? 'File TXT scaricato!'
                                  : null,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Selettore AI — griglia orizzontale con icone
  Widget _buildSelettoreAi(
    ColorScheme colorScheme,
    bool isDark,
    ValueChanged<String> onSelect,
  ) {
    // Lista delle AI disponibili con icone Material
    final listaAi = [
      _AiOption('ChatGPT', Icons.chat_bubble_outline, const Color(0xFF10A37F)),
      _AiOption('Claude', Icons.auto_awesome, const Color(0xFFD97706)),
      _AiOption('Gemini', Icons.diamond_outlined, const Color(0xFF4285F4)),
      _AiOption('Generico', Icons.tune, colorScheme.onSurfaceVariant),
    ];

    return Row(
      children: listaAi.map((ai) {
        final selezionato = _aiSelezionata == ai.nome;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(ai.nome),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selezionato
                    ? ai.colore.withValues(alpha: 0.1)
                    : colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selezionato ? ai.colore : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  if (!isDark && !selezionato)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    ai.icona,
                    size: 24,
                    color: selezionato
                        ? ai.colore
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ai.nome,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          selezionato ? FontWeight.w600 : FontWeight.w400,
                      color: selezionato
                          ? ai.colore
                          : colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Singola opzione nel bottom sheet export
  Widget _buildOpzioneExport({
    required IconData icona,
    required String etichetta,
    required String descrizione,
    required ColorScheme colorScheme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icona, size: 20, color: colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        etichetta,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        descrizione,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Esegue l'export con feedback di successo o errore
  Future<void> _esportaConFeedback(
    Future<void> Function() azione, {
    String? messaggioSuccesso,
  }) async {
    try {
      await azione();
      if (mounted && messaggioSuccesso != null) {
        _mostraConferma(Icons.check_circle, messaggioSuccesso);
      }
    } catch (e) {
      if (mounted) {
        _mostraConferma(Icons.error_outline, 'Errore durante l\'esportazione');
      }
    }
  }

  /// Mostra una snackbar di conferma con icona
  void _mostraConferma(IconData icona, String messaggio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icona, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Flexible(child: Text(messaggio)),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ========== WIDGET HELPER ==========

  /// Maniglia del bottom sheet
  Widget _buildManiglia(ColorScheme colorScheme) {
    return Container(
      width: 36,
      height: 5,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildEtichettaPrimaDopo(String testo, Color colore) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colore.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        testo,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colore,
        ),
      ),
    );
  }

  Widget _buildBoxTesto(
    String testo,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Text(
        testo.isEmpty ? '(vuoto)' : testo,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: testo.isEmpty
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurface,
          fontStyle: testo.isEmpty ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  Widget _buildBottoneAzione({
    required IconData icona,
    required String etichetta,
    required ColorScheme colorScheme,
    required bool isPrimario,
    required VoidCallback? onPressed,
  }) {
    if (isPrimario) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icona, size: 18),
            const SizedBox(width: 6),
            Text(etichetta, style: const TextStyle(fontSize: 14)),
          ],
        ),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icona, size: 18),
          const SizedBox(width: 6),
          Text(etichetta, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// ========== MODELLO AI OPTION ==========

/// Rappresenta un'opzione AI nel selettore
class _AiOption {
  final String nome;
  final IconData icona;
  final Color colore;
  const _AiOption(this.nome, this.icona, this.colore);
}

// ========== WIDGET CARD SEZIONE ==========

/// Card collassabile per una singola sezione del prompt nella vista strutturata.
class _CardSezione extends StatefulWidget {
  final SezionePrompt sezione;
  final Color coloreSezione;
  final bool isDark;
  final ColorScheme colorScheme;
  final bool inModifica;
  final IconData icona;
  final VoidCallback onTapModifica;
  final TextEditingController editController;
  final VoidCallback onSalva;
  final VoidCallback onAnnulla;

  const _CardSezione({
    required this.sezione,
    required this.coloreSezione,
    required this.isDark,
    required this.colorScheme,
    required this.inModifica,
    required this.icona,
    required this.onTapModifica,
    required this.editController,
    required this.onSalva,
    required this.onAnnulla,
  });

  @override
  State<_CardSezione> createState() => _CardSezioneState();
}

class _CardSezioneState extends State<_CardSezione> {
  bool _espansa = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: widget.inModifica
            ? Border.all(color: widget.colorScheme.primary, width: 1.5)
            : null,
        boxShadow: [
          if (!widget.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _espansa = !_espansa),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.coloreSezione.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icona,
                      size: 18,
                      color: widget.coloreSezione,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.sezione.titolo,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: widget.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (_espansa && !widget.inModifica)
                    GestureDetector(
                      onTap: widget.onTapModifica,
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: widget.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _espansa ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: widget.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: widget.inModifica
                  ? _buildCampoModifica()
                  : Text(
                      widget.sezione.contenuto,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: widget.colorScheme.onSurface,
                      ),
                    ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _espansa
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoModifica() {
    return Column(
      children: [
        TextField(
          controller: widget.editController,
          maxLines: null,
          minLines: 3,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: widget.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: widget.colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: widget.colorScheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: widget.onAnnulla,
              child: Text(
                'Annulla',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: widget.onSalva,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text('Salva', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ],
    );
  }
}
