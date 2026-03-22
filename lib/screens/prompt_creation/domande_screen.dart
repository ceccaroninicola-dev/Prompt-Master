import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ideai/config/app_routes.dart';
import 'package:ideai/models/domanda.dart';
import 'package:ideai/providers/sessione_provider.dart';
import 'package:ideai/providers/prompt_generato_provider.dart';
import 'package:ideai/widgets/barra_avanzamento.dart';
import 'package:ideai/widgets/banner_ad_widget.dart';
import 'package:ideai/services/ad_service.dart';

/// Schermata delle domande adattive — terza fase del flusso.
/// Design minimal stile Apple: card pulite, teal accento, animazioni fluide.
class DomandeScreen extends StatefulWidget {
  const DomandeScreen({super.key});

  @override
  State<DomandeScreen> createState() => _DomandeScreenState();
}

class _DomandeScreenState extends State<DomandeScreen> {
  // Controller per il campo di testo libero
  final _testoController = TextEditingController();

  // Opzione selezionata per i bottoni opzioni (selezione singola)
  String? _opzioneSelezionata;

  // Chip selezionati per la selezione multipla
  final Set<String> _chipSelezionati = {};

  // Flag per evitare navigazioni multiple alla post-generazione
  bool _haNavigato = false;

  // Flag: l'utente è tornato indietro dalla post-generazione
  bool _ritornatoDaPostGenerazione = false;

  @override
  void initState() {
    super.initState();
    // Pre-carica l'interstitial all'inizio della sessione domande
    AdService().precaricaInterstitial();
  }

  @override
  void dispose() {
    _testoController.dispose();
    super.dispose();
  }

  /// Resetta lo stato di input quando si cambia domanda
  void _resetInput(Domanda domanda, String? rispostaPrecedente) {
    _testoController.clear();
    _opzioneSelezionata = null;
    _chipSelezionati.clear();

    // Se c'è una risposta precedente, ripristinala
    if (rispostaPrecedente != null) {
      switch (domanda.tipoInput) {
        case TipoInput.testoLibero:
          _testoController.text = rispostaPrecedente;
          break;
        case TipoInput.bottoniOpzioni:
          _opzioneSelezionata = rispostaPrecedente;
          break;
        case TipoInput.chipMultipli:
          _chipSelezionati
              .addAll(rispostaPrecedente.split(', ').where((s) => s.isNotEmpty));
          break;
      }
    } else if (domanda.valoreDefault != null) {
      // Altrimenti, imposta il valore di default se presente
      switch (domanda.tipoInput) {
        case TipoInput.testoLibero:
          _testoController.text = domanda.valoreDefault!;
          break;
        case TipoInput.bottoniOpzioni:
          _opzioneSelezionata = domanda.valoreDefault;
          break;
        case TipoInput.chipMultipli:
          _chipSelezionati.addAll(
              domanda.valoreDefault!.split(', ').where((s) => s.isNotEmpty));
          break;
      }
    }
  }

  /// Verifica se l'utente ha fornito una risposta valida
  bool _rispostaValida(TipoInput tipo) {
    switch (tipo) {
      case TipoInput.testoLibero:
        return _testoController.text.trim().isNotEmpty;
      case TipoInput.bottoniOpzioni:
        return _opzioneSelezionata != null;
      case TipoInput.chipMultipli:
        return _chipSelezionati.isNotEmpty;
    }
  }

  /// Restituisce la risposta formattata in base al tipo di input
  String _getRisposta(TipoInput tipo) {
    switch (tipo) {
      case TipoInput.testoLibero:
        return _testoController.text.trim();
      case TipoInput.bottoniOpzioni:
        return _opzioneSelezionata ?? '';
      case TipoInput.chipMultipli:
        return _chipSelezionati.join(', ');
    }
  }

  /// Invia la risposta e passa alla domanda successiva
  void _inviRisposta() {
    final provider = context.read<SessioneProvider>();
    final domanda = provider.domandaCorrente;
    if (domanda == null) return;

    if (!_rispostaValida(domanda.tipoInput)) return;

    provider.rispondiDomanda(_getRisposta(domanda.tipoInput));

    // Se abbiamo completato tutte le domande, naviga alla post-generazione.
    // Non serve anche il check nel build() perché lo facciamo qui direttamente.
    if (provider.domandaCorrente == null) {
      _navigaAPostGenerazione();
    }
  }

  /// Genera il prompt immediatamente (bottone "Genera ora")
  void _generaOra() {
    _navigaAPostGenerazione();
  }

  /// Avvia la generazione del prompt e naviga alla schermata post-generazione.
  /// Mostra un interstitial tra la sessione domande e la post-generazione
  /// (massimo 1 ogni 3 minuti). Il flag _haNavigato previene push multipli.
  Future<void> _navigaAPostGenerazione() async {
    if (_haNavigato) return;
    _haNavigato = true;

    final sessione = context.read<SessioneProvider>().sessione;
    final promptProvider = context.read<PromptGeneratoProvider>();

    // Avvia la generazione del prompt fittizio
    promptProvider.generaPrompt(
      fraseIniziale: sessione.fraseIniziale,
      categoria: sessione.categoria?.nome ?? 'Scrittura',
      risposte: sessione.risposte,
    );

    // Mostra l'interstitial prima di navigare (se disponibile e non su web)
    if (!kIsWeb) {
      await AdService().mostraInterstitial();
    }

    if (!mounted) return;

    // Naviga alla schermata post-generazione
    Navigator.of(context).pushNamed(AppRoutes.postGenerazione).then((_) {
      // L'utente è tornato indietro dalla post-generazione:
      // segna il flag per evitare il loop di ri-navigazione
      if (mounted) {
        _haNavigato = false;
        _ritornatoDaPostGenerazione = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<SessioneProvider>();
    final sessione = provider.sessione;
    final domanda = provider.domandaCorrente;

    // Se tutte le domande sono completate:
    if (domanda == null && sessione.domande.isNotEmpty) {
      if (_ritornatoDaPostGenerazione) {
        // L'utente è tornato dalla post-generazione: torna alla Home
        // per evitare il loop infinito di ri-navigazione
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        });
      } else if (!_haNavigato) {
        // Prima volta: naviga alla post-generazione
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _navigaAPostGenerazione();
        });
      }
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    if (domanda == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(sessione.categoria?.nome ?? 'Domande'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Annulla sessione',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Annullare la sessione?'),
                content: const Text(
                  'Le risposte fornite finora andranno perse.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Continua'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.read<SessioneProvider>().resetSessione();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                    child: const Text('Annulla sessione'),
                  ),
                ],
              ),
            );
          },
        ),
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
        child: Column(
          children: [
            // Contenuto principale delle domande
            Expanded(
              child: _DomandeBody(
                domanda: domanda,
                sessione: sessione,
                provider: provider,
                colorScheme: colorScheme,
                testoController: _testoController,
                opzioneSelezionata: _opzioneSelezionata,
                chipSelezionati: _chipSelezionati,
                onResetInput: _resetInput,
                onOpzioneSelezionata: (val) =>
                    setState(() => _opzioneSelezionata = val),
                onChipToggle: (chip) {
                  setState(() {
                    if (_chipSelezionati.contains(chip)) {
                      _chipSelezionati.remove(chip);
                    } else {
                      _chipSelezionati.add(chip);
                    }
                  });
                },
                onInviaRisposta: _inviRisposta,
                onGeneraOra: _generaOra,
                onTestoChanged: () => setState(() {}),
              ),
            ),
            // Banner pubblicitario in basso (solo su mobile, non su web)
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}

/// Widget separato per il body della schermata domande.
/// Gestisce il layout e l'animazione tra una domanda e l'altra.
class _DomandeBody extends StatefulWidget {
  final Domanda domanda;
  final dynamic sessione;
  final SessioneProvider provider;
  final ColorScheme colorScheme;
  final TextEditingController testoController;
  final String? opzioneSelezionata;
  final Set<String> chipSelezionati;
  final void Function(Domanda, String?) onResetInput;
  final ValueChanged<String> onOpzioneSelezionata;
  final ValueChanged<String> onChipToggle;
  final VoidCallback onInviaRisposta;
  final VoidCallback onGeneraOra;
  final VoidCallback onTestoChanged;

  const _DomandeBody({
    required this.domanda,
    required this.sessione,
    required this.provider,
    required this.colorScheme,
    required this.testoController,
    required this.opzioneSelezionata,
    required this.chipSelezionati,
    required this.onResetInput,
    required this.onOpzioneSelezionata,
    required this.onChipToggle,
    required this.onInviaRisposta,
    required this.onGeneraOra,
    required this.onTestoChanged,
  });

  @override
  State<_DomandeBody> createState() => _DomandeBodyState();
}

class _DomandeBodyState extends State<_DomandeBody> {
  // Tiene traccia dell'ultimo id domanda visualizzato per resettare l'input
  String? _ultimaDomandaId;

  @override
  void didUpdateWidget(covariant _DomandeBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.domanda.id != _ultimaDomandaId) {
      _ultimaDomandaId = widget.domanda.id;
      final rispostaPrecedente =
          widget.sessione.risposte[widget.domanda.id] as String?;
      widget.onResetInput(widget.domanda, rispostaPrecedente);
    }
  }

  @override
  void initState() {
    super.initState();
    _ultimaDomandaId = widget.domanda.id;
    final rispostaPrecedente =
        widget.sessione.risposte[widget.domanda.id] as String?;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onResetInput(widget.domanda, rispostaPrecedente);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Barra di avanzamento in alto
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: BarraAvanzamento(
            percentuale: widget.sessione.percentualeCompletamento as double,
            domandaCorrente: widget.sessione.domandaCorrente as int,
            totaleDomande: widget.sessione.domande.length as int,
            onTapDomanda: (indice) {
              final diff =
                  (widget.sessione.domandaCorrente as int) - indice;
              for (var i = 0; i < diff; i++) {
                widget.provider.domandaPrecedente();
              }
            },
          ),
        ),
        const SizedBox(height: 24),

        // Contenuto principale — domanda e input
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.03, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Column(
                key: ValueKey(widget.domanda.id),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Testo della domanda
                  Text(
                    widget.domanda.testo,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),

                  // Widget di input in base al tipo di domanda
                  _buildInput(isDark),
                ],
              ),
            ),
          ),
        ),

        // Barra inferiore con bottoni di navigazione
        _buildBarraInferiore(isDark),
      ],
    );
  }

  /// Costruisce il widget di input appropriato
  Widget _buildInput(bool isDark) {
    switch (widget.domanda.tipoInput) {
      case TipoInput.testoLibero:
        return _buildInputTestoLibero();
      case TipoInput.bottoniOpzioni:
        return _buildInputBottoni(isDark);
      case TipoInput.chipMultipli:
        return _buildInputChip();
    }
  }

  /// Input di tipo testo libero — campo di testo con bordi morbidi
  Widget _buildInputTestoLibero() {
    return TextField(
      controller: widget.testoController,
      maxLines: 5,
      onChanged: (_) => widget.onTestoChanged(),
      decoration: InputDecoration(
        hintText: widget.domanda.placeholder ?? 'Scrivi la tua risposta...',
        hintMaxLines: 2,
        hintStyle: TextStyle(
          color: widget.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: widget.colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: widget.colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(18),
      ),
    );
  }

  /// Input di tipo bottoni opzioni — card Apple-style con selezione singola
  Widget _buildInputBottoni(bool isDark) {
    return Column(
      children: widget.domanda.opzioni.map((opzione) {
        final selezionato = widget.opzioneSelezionata == opzione;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: double.infinity,
            decoration: BoxDecoration(
              color: selezionato
                  ? widget.colorScheme.primary.withValues(alpha: 0.08)
                  : widget.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selezionato
                    ? widget.colorScheme.primary
                    : isDark
                        ? widget.colorScheme.outlineVariant
                        : Colors.transparent,
                width: selezionato ? 1.5 : 0.5,
              ),
              boxShadow: [
                if (!isDark && !selezionato)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => widget.onOpzioneSelezionata(opzione),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      // Indicatore di selezione — cerchio teal
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selezionato
                                ? widget.colorScheme.primary
                                : widget.colorScheme.outline,
                            width: selezionato ? 2 : 1.5,
                          ),
                          color: selezionato
                              ? widget.colorScheme.primary
                              : Colors.transparent,
                        ),
                        child: selezionato
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      // Testo dell'opzione
                      Expanded(
                        child: Text(
                          opzione,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                fontWeight: selezionato
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                      // Badge "Suggerito" — teal leggero
                      if (opzione == widget.domanda.valoreDefault &&
                          !selezionato)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Suggerito',
                            style: TextStyle(
                              color: widget.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Input di tipo chip multipli — chip teal con selezione multipla
  Widget _buildInputChip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleziona uno o più elementi:',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.domanda.opzioni.map((opzione) {
            final selezionato = widget.chipSelezionati.contains(opzione);
            return FilterChip(
              label: Text(opzione),
              selected: selezionato,
              onSelected: (_) => widget.onChipToggle(opzione),
              showCheckmark: true,
              checkmarkColor: Colors.white,
              selectedColor: widget.colorScheme.primary.withValues(alpha: 0.15),
              backgroundColor: widget.colorScheme.surfaceContainerLow,
              side: BorderSide(
                color: selezionato
                    ? widget.colorScheme.primary
                    : widget.colorScheme.outlineVariant,
                width: selezionato ? 1.5 : 0.5,
              ),
              labelStyle: TextStyle(
                color: selezionato
                    ? widget.colorScheme.primary
                    : widget.colorScheme.onSurface,
                fontWeight:
                    selezionato ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }).toList(),
        ),
        // Riepilogo dei chip selezionati
        if (widget.chipSelezionati.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Selezionati: ${widget.chipSelezionati.join(", ")}',
            style: TextStyle(
              color: widget.colorScheme.primary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }

  /// Barra inferiore — stile Apple con ombra sottile
  Widget _buildBarraInferiore(bool isDark) {
    final puoTornareIndietro = widget.provider.puoTornareIndietro;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Riga con bottoni Indietro e Avanti
          Row(
            children: [
              // Bottone "Indietro"
              if (puoTornareIndietro)
                Container(
                  decoration: BoxDecoration(
                    color: widget.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => widget.provider.domandaPrecedente(),
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    tooltip: 'Domanda precedente',
                    color: widget.colorScheme.onSurface,
                  ),
                ),
              if (puoTornareIndietro) const SizedBox(width: 12),

              // Bottone "Avanti" / "Completa" — teal pieno
              Expanded(
                child: ElevatedButton(
                  onPressed: _isRispostaValida()
                      ? widget.onInviaRisposta
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.provider.isUltimaDomanda
                        ? 'Completa'
                        : 'Avanti',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Bottone "Genera ora" — teal testo
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: widget.onGeneraOra,
              icon: Icon(Icons.bolt, size: 18,
                  color: widget.colorScheme.primary),
              label: Text(
                'Genera ora con le info raccolte',
                style: TextStyle(color: widget.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Verifica se la risposta corrente è valida
  bool _isRispostaValida() {
    switch (widget.domanda.tipoInput) {
      case TipoInput.testoLibero:
        return widget.testoController.text.trim().isNotEmpty;
      case TipoInput.bottoniOpzioni:
        return widget.opzioneSelezionata != null;
      case TipoInput.chipMultipli:
        return widget.chipSelezionati.isNotEmpty;
    }
  }
}
