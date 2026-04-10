import 'package:ideai/models/categoria_rilevata.dart';
import 'package:ideai/models/domanda.dart';

/// Modello che rappresenta una sessione di creazione prompt.
/// Contiene la frase iniziale, la categoria rilevata,
/// le domande poste e le risposte dell'utente.
class SessionePrompt {
  /// Frase libera iniziale dell'utente
  final String fraseIniziale;

  /// Categoria rilevata dall'AI
  final CategoriaRilevata? categoria;

  /// Lista delle domande poste all'utente
  final List<Domanda> domande;

  /// Mappa delle risposte: chiave = id domanda, valore = risposta
  /// Per i chip multipli, le risposte sono separate da virgola
  final Map<String, String> risposte;

  /// Indice della domanda corrente (0-based)
  final int domandaCorrente;

  /// Percentuale di completamento stimata (0.0 - 1.0)
  final double percentualeCompletamento;

  /// Numero di domande scelto dall'utente (5, 10, 20). Default: 10.
  final int numeroDomande;

  const SessionePrompt({
    required this.fraseIniziale,
    this.categoria,
    this.domande = const [],
    this.risposte = const {},
    this.domandaCorrente = 0,
    this.percentualeCompletamento = 0.0,
    this.numeroDomande = 10,
  });

  /// Crea una copia della sessione con i campi modificati
  SessionePrompt copyWith({
    String? fraseIniziale,
    CategoriaRilevata? categoria,
    List<Domanda>? domande,
    Map<String, String>? risposte,
    int? domandaCorrente,
    double? percentualeCompletamento,
    int? numeroDomande,
  }) {
    return SessionePrompt(
      fraseIniziale: fraseIniziale ?? this.fraseIniziale,
      categoria: categoria ?? this.categoria,
      domande: domande ?? this.domande,
      risposte: risposte ?? this.risposte,
      domandaCorrente: domandaCorrente ?? this.domandaCorrente,
      percentualeCompletamento:
          percentualeCompletamento ?? this.percentualeCompletamento,
      numeroDomande: numeroDomande ?? this.numeroDomande,
    );
  }
}
