/// Enum che rappresenta i tipi di input disponibili per rispondere a una domanda.
/// Ogni tipo corrisponde a un widget diverso nell'interfaccia.
enum TipoInput {
  /// Testo libero — l'utente digita o detta la risposta
  testoLibero,

  /// Bottoni con opzioni — per scelte discrete e chiare (selezione singola)
  bottoniOpzioni,

  /// Chip/tag selezionabili — per selezioni multiple
  chipMultipli,
}

/// Modello che rappresenta una singola domanda del motore adattivo.
/// Ogni domanda ha un testo, un tipo di input e opzioni facoltative.
class Domanda {
  /// Identificatore univoco della domanda
  final String id;

  /// Testo della domanda mostrata all'utente
  final String testo;

  /// Tipo di input per la risposta (testo libero, bottoni, chip)
  final TipoInput tipoInput;

  /// Lista di opzioni disponibili (per bottoni e chip)
  /// Vuota se il tipo è testoLibero
  final List<String> opzioni;

  /// Placeholder per il campo di testo (se tipoInput è testoLibero)
  final String? placeholder;

  /// Valore di default suggerito (pre-selezionato)
  final String? valoreDefault;

  const Domanda({
    required this.id,
    required this.testo,
    required this.tipoInput,
    this.opzioni = const [],
    this.placeholder,
    this.valoreDefault,
  });
}
