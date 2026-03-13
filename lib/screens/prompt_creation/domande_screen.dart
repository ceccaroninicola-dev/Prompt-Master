import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prompt_master/models/domanda.dart';
import 'package:prompt_master/providers/sessione_provider.dart';
import 'package:prompt_master/widgets/barra_avanzamento.dart';

/// Schermata delle domande adattive — terza fase del flusso.
/// Mostra una domanda alla volta con la barra di avanzamento in alto.
/// Supporta tre tipi di input: testo libero, bottoni opzioni, chip multipli.
/// Include il bottone "Genera ora" sempre visibile in basso.
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

    // Se abbiamo completato tutte le domande, mostra un messaggio
    if (provider.domandaCorrente == null) {
      _mostraCompletamento();
    }
  }

  /// Mostra il messaggio di completamento (placeholder per la generazione)
  void _mostraCompletamento() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Domande completate!'),
        content: const Text(
          'Hai risposto a tutte le domande. '
          'La generazione del prompt sarà implementata nella prossima fase.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Chiudi il dialog
              // Torna alla Home
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.read<SessioneProvider>().resetSessione();
            },
            child: const Text('Torna alla Home'),
          ),
        ],
      ),
    );
  }

  /// Genera il prompt immediatamente (bottone "Genera ora")
  void _generaOra() {
    showDialog(
      context: context,
      builder: (context) {
        final sessione = context.read<SessioneProvider>().sessione;
        return AlertDialog(
          title: const Text('Genera prompt'),
          content: Text(
            'Il prompt verrà generato con le ${sessione.risposte.length} '
            'risposte fornite finora.\n\n'
            'La generazione sarà implementata nella prossima fase.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
                context.read<SessioneProvider>().resetSessione();
              },
              child: const Text('Torna alla Home'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<SessioneProvider>();
    final sessione = provider.sessione;
    final domanda = provider.domandaCorrente;

    // Se non ci sono domande, mostra il completamento
    if (domanda == null && sessione.domande.isNotEmpty) {
      // Tutte le domande sono state completate
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mostraCompletamento();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (domanda == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(sessione.categoria?.nome ?? 'Domande'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Annulla sessione',
          onPressed: () {
            // Chiedi conferma prima di annullare
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
                      Navigator.of(context)
                          .popUntil((route) => route.isFirst);
                      context.read<SessioneProvider>().resetSessione();
                    },
                    child: const Text('Annulla sessione'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: SafeArea(
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
    // Quando la domanda cambia, resetta l'input
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
    // Inizializza l'input con la risposta precedente o il default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onResetInput(widget.domanda, rispostaPrecedente);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra di avanzamento in alto
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: BarraAvanzamento(
            percentuale: widget.sessione.percentualeCompletamento as double,
            domandaCorrente: widget.sessione.domandaCorrente as int,
            totaleDomande: widget.sessione.domande.length as int,
            // Permetti di navigare alle domande precedenti toccando la barra
            onTapDomanda: (indice) {
              // Naviga alla domanda selezionata (solo se precedente)
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
                      begin: const Offset(0.05, 0),
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
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                  const SizedBox(height: 24),

                  // Widget di input in base al tipo di domanda
                  _buildInput(),
                ],
              ),
            ),
          ),
        ),

        // Barra inferiore con bottoni di navigazione
        _buildBarraInferiore(),
      ],
    );
  }

  /// Costruisce il widget di input appropriato in base al tipo di domanda
  Widget _buildInput() {
    switch (widget.domanda.tipoInput) {
      case TipoInput.testoLibero:
        return _buildInputTestoLibero();
      case TipoInput.bottoniOpzioni:
        return _buildInputBottoni();
      case TipoInput.chipMultipli:
        return _buildInputChip();
    }
  }

  /// Input di tipo testo libero — campo di testo espandibile
  Widget _buildInputTestoLibero() {
    return TextField(
      controller: widget.testoController,
      maxLines: 5,
      onChanged: (_) => widget.onTestoChanged(),
      decoration: InputDecoration(
        hintText: widget.domanda.placeholder ?? 'Scrivi la tua risposta...',
        hintMaxLines: 2,
        filled: true,
        fillColor: widget.colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: widget.colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  /// Input di tipo bottoni opzioni — selezione singola con card cliccabili
  Widget _buildInputBottoni() {
    return Column(
      children: widget.domanda.opzioni.map((opzione) {
        final selezionato = widget.opzioneSelezionata == opzione;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            width: double.infinity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: selezionato
                    ? widget.colorScheme.primaryContainer
                    : widget.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => widget.onOpzioneSelezionata(opzione),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selezionato
                            ? widget.colorScheme.primary
                            : widget.colorScheme.outlineVariant,
                        width: selezionato ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Indicatore di selezione (cerchio)
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selezionato
                                  ? widget.colorScheme.primary
                                  : widget.colorScheme.outline,
                              width: 2,
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
                                  color: selezionato
                                      ? widget
                                          .colorScheme.onPrimaryContainer
                                      : null,
                                ),
                          ),
                        ),
                        // Badge "Default" se è il valore suggerito
                        if (opzione == widget.domanda.valoreDefault &&
                            !selezionato)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Suggerito',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: widget
                                        .colorScheme.onTertiaryContainer,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Input di tipo chip multipli — selezione multipla con chip colorati
  Widget _buildInputChip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Istruzione per la selezione multipla
        Text(
          'Seleziona uno o più elementi:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: widget.colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        // Griglia di chip selezionabili
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
              checkmarkColor: widget.colorScheme.onPrimaryContainer,
              selectedColor: widget.colorScheme.primaryContainer,
              backgroundColor: widget.colorScheme.surfaceContainerLow,
              side: BorderSide(
                color: selezionato
                    ? widget.colorScheme.primary
                    : widget.colorScheme.outlineVariant,
              ),
              labelStyle: TextStyle(
                color: selezionato
                    ? widget.colorScheme.onPrimaryContainer
                    : widget.colorScheme.onSurface,
                fontWeight:
                    selezionato ? FontWeight.w600 : FontWeight.normal,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
        // Mostra i chip selezionati come riepilogo
        if (widget.chipSelezionati.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Selezionati: ${widget.chipSelezionati.join(", ")}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: widget.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ],
    );
  }

  /// Costruisce la barra inferiore con navigazione e bottone "Genera ora"
  Widget _buildBarraInferiore() {
    final puoTornareIndietro = widget.provider.puoTornareIndietro;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
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
              // Bottone "Indietro" (visibile solo se non è la prima domanda)
              if (puoTornareIndietro)
                IconButton(
                  onPressed: () => widget.provider.domandaPrecedente(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Domanda precedente',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        widget.colorScheme.surfaceContainerHighest,
                  ),
                ),
              if (puoTornareIndietro) const SizedBox(width: 12),

              // Bottone "Avanti" / "Conferma"
              Expanded(
                child: ElevatedButton(
                  onPressed: _isRispostaValida()
                      ? widget.onInviaRisposta
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colorScheme.primary,
                    foregroundColor: widget.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    widget.provider.isUltimaDomanda
                        ? 'Completa'
                        : 'Avanti',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Bottone "Genera ora" — sempre visibile
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: widget.onGeneraOra,
              icon: const Icon(Icons.bolt, size: 18),
              label: const Text('Genera ora con le info raccolte'),
              style: TextButton.styleFrom(
                foregroundColor: widget.colorScheme.secondary,
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
