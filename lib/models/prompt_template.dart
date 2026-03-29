import 'package:ideai/models/prompt_generato.dart';

/// Modello che rappresenta un template di prompt pronto all'uso.
/// Ogni template ha una categoria, un punteggio di popolarità e sezioni strutturate.
class PromptTemplate {
  /// Identificativo univoco del template
  final String id;

  /// Titolo del template (es. "Email professionale")
  final String titolo;

  /// Descrizione breve del template
  final String descrizione;

  /// Categoria di appartenenza (es. "Marketing", "Coding")
  final String categoria;

  /// Nome dell'icona Material per la categoria
  final String icona;

  /// Punteggio di popolarità (0.0 - 5.0)
  final double popolarita;

  /// Numero di utilizzi del template
  final int utilizzi;

  /// Sezioni strutturate del prompt
  final List<SezionePrompt> sezioni;

  /// Tag opzionali per la ricerca
  final List<String> tag;

  const PromptTemplate({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.categoria,
    required this.icona,
    required this.popolarita,
    required this.utilizzi,
    required this.sezioni,
    this.tag = const [],
  });

  /// Restituisce il prompt come testo continuo
  String get testoCompleto {
    return sezioni
        .where((s) => s.contenuto.isNotEmpty)
        .map((s) => s.contenuto)
        .join('\n\n');
  }
}
