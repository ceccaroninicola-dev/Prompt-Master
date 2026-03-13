/// Modello che rappresenta la categoria rilevata dall'AI
/// dopo che l'utente ha inserito la frase libera iniziale.
/// Contiene il riepilogo di ciò che l'app ha capito.
class CategoriaRilevata {
  /// Nome della categoria principale (es. "Scrittura", "Coding", "Immagini")
  final String nome;

  /// Icona associata alla categoria (nome dell'icona Material)
  final String icona;

  /// Riepilogo di ciò che l'AI ha capito dalla frase dell'utente
  final String riepilogo;

  /// Sottocategoria opzionale (es. "Marketing", "Social Media")
  final String? sottocategoria;

  /// Lista di elementi chiave estratti dalla frase dell'utente
  final List<String> elementiChiave;

  const CategoriaRilevata({
    required this.nome,
    required this.icona,
    required this.riepilogo,
    this.sottocategoria,
    this.elementiChiave = const [],
  });
}
