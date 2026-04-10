import 'package:ideai/models/categoria_rilevata.dart';
import 'package:ideai/models/domanda.dart';

/// Modello che rappresenta una sessione di creazione prompt.
/// Supporta il sistema a 3 livelli progressivi:
/// - Livello 1: 5 domande macro sui punti focali
/// - Livello 2: approfondimento risposte generiche del livello 1
/// - Livello 3: dettagli finali e punti focali non ancora trattati
class SessionePrompt {
  /// Frase libera iniziale dell'utente
  final String fraseIniziale;

  /// Categoria rilevata dall'AI
  final CategoriaRilevata? categoria;

  /// Lista delle domande del livello corrente
  final List<Domanda> domande;

  /// Mappa delle risposte del livello corrente: chiave = id domanda, valore = risposta
  final Map<String, String> risposte;

  /// Indice della domanda corrente nel livello (0-based)
  final int domandaCorrente;

  /// Percentuale di completamento stimata (0.0 - 1.0)
  final double percentualeCompletamento;

  /// Livello attuale del sistema a cascata (1, 2, 3)
  final int livello;

  /// Risposte accumulate di tutti i livelli precedenti.
  /// Struttura: { "livello_1": { "id_domanda": "risposta" }, "livello_2": ... }
  final Map<String, Map<String, String>> risposteLivelli;

  /// Punti focali generati dall'AI nella fase 0 di analisi.
  /// Lista di 20-25 aspetti dell'argomento su cui basare le domande.
  final List<String> puntiFocali;

  /// Indica se il livello corrente è completato e l'utente
  /// deve scegliere se approfondire o generare.
  final bool livelloCompletato;

  const SessionePrompt({
    required this.fraseIniziale,
    this.categoria,
    this.domande = const [],
    this.risposte = const {},
    this.domandaCorrente = 0,
    this.percentualeCompletamento = 0.0,
    this.livello = 1,
    this.risposteLivelli = const {},
    this.puntiFocali = const [],
    this.livelloCompletato = false,
  });

  /// Crea una copia della sessione con i campi modificati
  SessionePrompt copyWith({
    String? fraseIniziale,
    CategoriaRilevata? categoria,
    List<Domanda>? domande,
    Map<String, String>? risposte,
    int? domandaCorrente,
    double? percentualeCompletamento,
    int? livello,
    Map<String, Map<String, String>>? risposteLivelli,
    List<String>? puntiFocali,
    bool? livelloCompletato,
  }) {
    return SessionePrompt(
      fraseIniziale: fraseIniziale ?? this.fraseIniziale,
      categoria: categoria ?? this.categoria,
      domande: domande ?? this.domande,
      risposte: risposte ?? this.risposte,
      domandaCorrente: domandaCorrente ?? this.domandaCorrente,
      percentualeCompletamento:
          percentualeCompletamento ?? this.percentualeCompletamento,
      livello: livello ?? this.livello,
      risposteLivelli: risposteLivelli ?? this.risposteLivelli,
      puntiFocali: puntiFocali ?? this.puntiFocali,
      livelloCompletato: livelloCompletato ?? this.livelloCompletato,
    );
  }

  /// Restituisce TUTTE le risposte accumulate da tutti i livelli,
  /// incluso il livello corrente. Usato per generare il prompt finale.
  Map<String, String> get tutteLeRisposte {
    final tutte = <String, String>{};
    for (final entry in risposteLivelli.values) {
      tutte.addAll(entry);
    }
    tutte.addAll(risposte);
    return tutte;
  }

  /// Restituisce una descrizione leggibile delle risposte per il contesto AI.
  String get riepilogoRisposte {
    final buffer = StringBuffer();
    for (int i = 1; i <= 3; i++) {
      final key = 'livello_$i';
      final risposteLiv = risposteLivelli[key];
      if (risposteLiv != null && risposteLiv.isNotEmpty) {
        buffer.writeln('--- Risposte livello $i ---');
        risposteLiv.forEach((id, risposta) {
          buffer.writeln('- $id: $risposta');
        });
        buffer.writeln();
      }
    }
    // Aggiungi risposte del livello corrente se ci sono
    if (risposte.isNotEmpty) {
      buffer.writeln('--- Risposte livello $livello (corrente) ---');
      risposte.forEach((id, risposta) {
        buffer.writeln('- $id: $risposta');
      });
    }
    return buffer.toString();
  }
}
