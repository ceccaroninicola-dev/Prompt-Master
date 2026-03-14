/// Modello che rappresenta un prompt generato con sezioni strutturate e scoring.
/// Ogni sezione (Ruolo, Contesto, ecc.) è modificabile separatamente.
class PromptGenerato {
  /// Le sezioni che compongono il prompt strutturato
  final List<SezionePrompt> sezioni;

  /// Punteggio globale del prompt (0.0 - 5.0)
  final double punteggioGlobale;

  /// Punteggi per singolo criterio
  final Map<String, double> punteggiCriteri;

  /// Suggerimenti di miglioramento disponibili
  final List<SuggerimentoMiglioramento> suggerimenti;

  const PromptGenerato({
    required this.sezioni,
    required this.punteggioGlobale,
    required this.punteggiCriteri,
    required this.suggerimenti,
  });

  /// Restituisce il prompt come testo continuo (vista semplice)
  String get testoCompleto {
    return sezioni
        .where((s) => s.contenuto.isNotEmpty)
        .map((s) => s.contenuto)
        .join('\n\n');
  }

  /// Crea una copia con sezione aggiornata
  PromptGenerato conSezioneAggiornata(int indice, String nuovoContenuto) {
    final nuoveSezioni = List<SezionePrompt>.from(sezioni);
    nuoveSezioni[indice] = nuoveSezioni[indice].copyWith(contenuto: nuovoContenuto);
    return PromptGenerato(
      sezioni: nuoveSezioni,
      punteggioGlobale: punteggioGlobale,
      punteggiCriteri: punteggiCriteri,
      suggerimenti: suggerimenti,
    );
  }

  /// Crea una copia con punteggi aggiornati
  PromptGenerato conPunteggiAggiornati({
    double? punteggioGlobale,
    Map<String, double>? punteggiCriteri,
    List<SuggerimentoMiglioramento>? suggerimenti,
  }) {
    return PromptGenerato(
      sezioni: sezioni,
      punteggioGlobale: punteggioGlobale ?? this.punteggioGlobale,
      punteggiCriteri: punteggiCriteri ?? this.punteggiCriteri,
      suggerimenti: suggerimenti ?? this.suggerimenti,
    );
  }
}

/// Una singola sezione del prompt (es. Ruolo, Contesto, Istruzioni, ecc.)
class SezionePrompt {
  /// Titolo della sezione (es. "Ruolo", "Contesto")
  final String titolo;

  /// Nome dell'icona Material per la sezione
  final String icona;

  /// Contenuto testuale della sezione
  final String contenuto;

  /// Colore associato alla sezione (in formato hex senza #)
  final int colore;

  const SezionePrompt({
    required this.titolo,
    required this.icona,
    required this.contenuto,
    required this.colore,
  });

  /// Crea una copia con il contenuto aggiornato
  SezionePrompt copyWith({String? contenuto}) {
    return SezionePrompt(
      titolo: titolo,
      icona: icona,
      contenuto: contenuto ?? this.contenuto,
      colore: colore,
    );
  }
}

/// Un suggerimento di miglioramento per il prompt
class SuggerimentoMiglioramento {
  /// Etichetta breve del suggerimento (es. "Aggiungi esempio")
  final String etichetta;

  /// Icona del chip
  final String icona;

  /// Indice della sezione del prompt interessata
  final int sezioneIndice;

  /// Testo della sezione PRIMA dell'applicazione
  final String testoPrima;

  /// Testo della sezione DOPO l'applicazione
  final String testoDopo;

  /// Descrizione del miglioramento
  final String descrizione;

  const SuggerimentoMiglioramento({
    required this.etichetta,
    required this.icona,
    required this.sezioneIndice,
    required this.testoPrima,
    required this.testoDopo,
    required this.descrizione,
  });
}
