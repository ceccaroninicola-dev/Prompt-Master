import 'package:flutter/material.dart';
import 'package:prompt_master/models/prompt_generato.dart';

/// Elemento salvato nella cronologia — contiene il prompt e i metadati
class ElementoCronologia {
  /// Identificativo univoco
  final String id;

  /// Il prompt generato salvato
  final PromptGenerato prompt;

  /// Data e ora del salvataggio
  final DateTime dataSalvataggio;

  /// Categoria del prompt (es. "Scrittura", "Coding")
  final String categoria;

  /// Frase iniziale dell'utente
  final String fraseIniziale;

  const ElementoCronologia({
    required this.id,
    required this.prompt,
    required this.dataSalvataggio,
    required this.categoria,
    required this.fraseIniziale,
  });
}

/// Provider per la gestione della cronologia dei prompt salvati.
/// Per ora salva in memoria; il database verrà aggiunto in seguito.
class CronologiaProvider extends ChangeNotifier {
  /// Lista dei prompt salvati (in memoria)
  final List<ElementoCronologia> _cronologia = [];

  // -- Getter --

  /// Restituisce la cronologia ordinata per data (più recenti prima)
  List<ElementoCronologia> get cronologia =>
      List.unmodifiable(_cronologia.reversed);

  /// Numero di prompt salvati
  int get numeroPomptSalvati => _cronologia.length;

  /// Salva un prompt nella cronologia
  void salvaPrompt({
    required PromptGenerato prompt,
    required String categoria,
    required String fraseIniziale,
  }) {
    final elemento = ElementoCronologia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      prompt: prompt,
      dataSalvataggio: DateTime.now(),
      categoria: categoria,
      fraseIniziale: fraseIniziale,
    );
    _cronologia.add(elemento);
    notifyListeners();
  }

  /// Rimuove un prompt dalla cronologia
  void rimuoviPrompt(String id) {
    _cronologia.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Verifica se un prompt è già stato salvato (confronto per contenuto)
  bool isGiaSalvato(PromptGenerato prompt) {
    return _cronologia.any((e) => e.prompt.testoCompleto == prompt.testoCompleto);
  }
}
