import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:prompt_master/models/prompt_generato.dart';
import 'package:prompt_master/providers/prompt_generato_provider.dart';

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

  /// Sezione scoring con punteggio globale e breakdown per criterio
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
              // Stelle
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
                  // Nome del criterio
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
                  // Mini barra di progresso teal
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: entry.value / 5,
                        backgroundColor:
                            colorScheme.surfaceContainerHighest,
                        color: colorScheme.primary,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Valore numerico
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

  /// Toggle per alternare tra vista semplice e strutturata
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

  /// Singola opzione del toggle
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
            color: selezionato
                ? colorScheme.surface
                : Colors.transparent,
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
                  fontWeight:
                      selezionato ? FontWeight.w600 : FontWeight.w400,
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

  /// Vista semplice: testo continuo del prompt
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

  /// Vista strutturata: sezioni collassabili con icone colorate
  Widget _buildVistaStrutturata(
    PromptGenerato prompt,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Column(
      children: List.generate(prompt.sezioni.length, (indice) {
        final sezione = prompt.sezioni[indice];
        // Nascondi sezioni vuote
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

  /// Chip cliccabili con suggerimenti di miglioramento
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
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface,
            ),
          ),
          backgroundColor: colorScheme.surfaceContainerLow,
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
          ),
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
            color: isDark
                ? const Color(0xFF1C1C1E)
                : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Maniglia del bottom sheet
              Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Intestazione
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

              // Contenuto scrollabile con prima/dopo
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PRIMA
                      _buildEtichettaPrimaDopo(
                        'Prima',
                        Colors.orange,
                        colorScheme,
                      ),
                      const SizedBox(height: 8),
                      _buildBoxTesto(
                        suggerimento.testoPrima,
                        colorScheme,
                        isDark,
                      ),
                      const SizedBox(height: 16),

                      // DOPO
                      _buildEtichettaPrimaDopo(
                        'Dopo',
                        colorScheme.primary,
                        colorScheme,
                      ),
                      const SizedBox(height: 8),
                      _buildBoxTesto(
                        suggerimento.testoDopo,
                        colorScheme,
                        isDark,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Bottone "Applica"
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

  /// Etichetta "Prima" / "Dopo" colorata
  Widget _buildEtichettaPrimaDopo(
    String testo,
    Color colore,
    ColorScheme colorScheme,
  ) {
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

  /// Box di testo per anteprima prima/dopo
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
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 0.5,
        ),
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

  // ========== BARRA AZIONI ==========

  /// Barra azioni in basso: Copia, Esporta, Salva
  Widget _buildBarraAzioni(
    PromptGenerato prompt,
    ColorScheme colorScheme,
    bool isDark,
  ) {
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
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: prompt.testoCompleto),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Prompt copiato negli appunti!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          // Bottone "Esporta"
          Expanded(
            child: _buildBottoneAzione(
              icona: Icons.ios_share_rounded,
              etichetta: 'Esporta',
              colorScheme: colorScheme,
              isPrimario: false,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funzionalità export in arrivo!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          // Bottone "Salva"
          Expanded(
            child: _buildBottoneAzione(
              icona: Icons.bookmark_outline_rounded,
              etichetta: 'Salva',
              colorScheme: colorScheme,
              isPrimario: false,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funzionalità salvataggio in arrivo!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Bottone singolo della barra azioni
  Widget _buildBottoneAzione({
    required IconData icona,
    required String etichetta,
    required ColorScheme colorScheme,
    required bool isPrimario,
    required VoidCallback onPressed,
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

// ========== WIDGET CARD SEZIONE (ESTRATTO) ==========

/// Card collassabile per una singola sezione del prompt nella vista strutturata.
/// Supporta modifica inline con salva/annulla.
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
  /// Controlla se la sezione è espansa o collassata
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
          // Intestazione della sezione — cliccabile per espandere/collassare
          InkWell(
            onTap: () => setState(() => _espansa = !_espansa),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  // Icona con colore della sezione
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
                  // Titolo della sezione
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
                  // Bottone modifica (solo se espansa e non già in modifica)
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
                  // Freccia espansione/collassamento
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

          // Contenuto della sezione (collassabile)
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

  /// Campo di modifica inline con bottoni Salva e Annulla
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
        // Bottoni Salva e Annulla
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
