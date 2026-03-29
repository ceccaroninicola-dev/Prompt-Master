import 'package:flutter/material.dart';
import 'package:ideai/models/prompt_generato.dart';

/// Modello che rappresenta un'AI disponibile per il confronto.
class InfoAI {
  /// Nome dell'AI (es. "ChatGPT", "Claude")
  final String nome;

  /// Icona Material rappresentativa
  final IconData icona;

  /// Colore distintivo dell'AI
  final Color colore;

  /// Categorie per le quali questa AI è consigliata
  final List<String> categorieForti;

  const InfoAI({
    required this.nome,
    required this.icona,
    required this.colore,
    required this.categorieForti,
  });
}

/// Modello che rappresenta la risposta di una singola AI al prompt.
class RispostaAI {
  /// Informazioni sull'AI che ha generato la risposta
  final InfoAI ai;

  /// Testo della risposta
  final String risposta;

  /// Punteggio qualità della risposta (0.0 - 5.0)
  final double punteggio;

  /// Punteggi dettagliati per criterio
  final Map<String, double> punteggiDettaglio;

  /// Indica se questa è la risposta migliore del confronto
  final bool isMigliore;

  const RispostaAI({
    required this.ai,
    required this.risposta,
    required this.punteggio,
    required this.punteggiDettaglio,
    this.isMigliore = false,
  });

  /// Crea una copia con il flag isMigliore aggiornato
  RispostaAI conMigliore(bool migliore) {
    return RispostaAI(
      ai: ai,
      risposta: risposta,
      punteggio: punteggio,
      punteggiDettaglio: punteggiDettaglio,
      isMigliore: migliore,
    );
  }
}

/// Modello che rappresenta un confronto completo tra più AI.
class ConfrontoAI {
  /// Il prompt inviato
  final PromptGenerato prompt;

  /// Le risposte ricevute dalle AI
  final List<RispostaAI> risposte;

  /// Data/ora del confronto
  final DateTime dataConfronto;

  const ConfrontoAI({
    required this.prompt,
    required this.risposte,
    required this.dataConfronto,
  });
}
