import 'package:flutter/material.dart';
import 'package:ideai/models/prompt_generato.dart';

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

  /// AI di destinazione scelta (es. "ChatGPT", "Claude", null se non scelta)
  final String? aiDestinazione;

  const ElementoCronologia({
    required this.id,
    required this.prompt,
    required this.dataSalvataggio,
    required this.categoria,
    required this.fraseIniziale,
    this.aiDestinazione,
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
  int get numeroPromptSalvati => _cronologia.length;

  /// Salva un prompt nella cronologia
  void salvaPrompt({
    required PromptGenerato prompt,
    required String categoria,
    required String fraseIniziale,
    String? aiDestinazione,
  }) {
    final elemento = ElementoCronologia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      prompt: prompt,
      dataSalvataggio: DateTime.now(),
      categoria: categoria,
      fraseIniziale: fraseIniziale,
      aiDestinazione: aiDestinazione,
    );
    _cronologia.add(elemento);
    notifyListeners();
  }

  /// Duplica un elemento della cronologia
  void duplicaPrompt(String id) {
    final originale = _cronologia.firstWhere(
      (e) => e.id == id,
      orElse: () => throw StateError('Elemento non trovato'),
    );
    salvaPrompt(
      prompt: originale.prompt,
      categoria: originale.categoria,
      fraseIniziale: originale.fraseIniziale,
      aiDestinazione: originale.aiDestinazione,
    );
  }

  /// Rimuove un prompt dalla cronologia
  void rimuoviPrompt(String id) {
    _cronologia.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Verifica se un prompt è già stato salvato (confronto per contenuto)
  bool isGiaSalvato(PromptGenerato prompt) {
    return _cronologia
        .any((e) => e.prompt.testoCompleto == prompt.testoCompleto);
  }

  /// Cerca nella cronologia per parola chiave (frase iniziale o contenuto prompt)
  List<ElementoCronologia> cerca(String query) {
    if (query.isEmpty) return cronologia;
    final q = query.toLowerCase();
    return cronologia.where((e) {
      return e.fraseIniziale.toLowerCase().contains(q) ||
          e.prompt.testoCompleto.toLowerCase().contains(q) ||
          e.categoria.toLowerCase().contains(q);
    }).toList();
  }

  /// Filtra per categoria
  List<ElementoCronologia> filtraPerCategoria(String categoria) {
    if (categoria == 'Tutti') return cronologia;
    return cronologia.where((e) => e.categoria == categoria).toList();
  }

  /// Cerca e filtra combinati
  List<ElementoCronologia> cercaEFiltra(String query, String categoria) {
    var risultati = categoria == 'Tutti' ? cronologia : filtraPerCategoria(categoria);
    if (query.isEmpty) return risultati;
    final q = query.toLowerCase();
    return risultati.where((e) {
      return e.fraseIniziale.toLowerCase().contains(q) ||
          e.prompt.testoCompleto.toLowerCase().contains(q);
    }).toList();
  }
}
