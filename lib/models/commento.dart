/// Modello che rappresenta un commento su un prompt pubblico.
class Commento {
  /// Identificativo univoco del commento
  final String id;

  /// ID dell'utente autore del commento
  final String autoreId;

  /// Nome utente dell'autore
  final String autoreNome;

  /// Colore avatar dell'autore
  final int autoreColore;

  /// Testo del commento
  final String testo;

  /// Data di pubblicazione
  final DateTime data;

  const Commento({
    required this.id,
    required this.autoreId,
    required this.autoreNome,
    required this.autoreColore,
    required this.testo,
    required this.data,
  });
}
