/// Modello che rappresenta un utente della community.
/// Ogni utente ha un profilo pubblico con statistiche e prompt pubblicati.
class Utente {
  /// Identificativo univoco dell'utente
  final String id;

  /// Nome utente visualizzato (es. "@marco_dev")
  final String nomeUtente;

  /// Nome completo dell'utente
  final String nomeCompleto;

  /// Breve descrizione del profilo
  final String bio;

  /// URL dell'avatar (per ora usiamo icone Material)
  final String avatarUrl;

  /// Colore associato al profilo (hex senza #)
  final int coloreAvatar;

  /// Numero totale di prompt pubblicati
  final int promptPubblicati;

  /// Numero totale di like ricevuti su tutti i prompt
  final int likeRicevuti;

  /// Numero totale di fork ricevuti su tutti i prompt
  final int forkRicevuti;

  /// Data di iscrizione
  final DateTime dataIscrizione;

  const Utente({
    required this.id,
    required this.nomeUtente,
    required this.nomeCompleto,
    required this.bio,
    this.avatarUrl = '',
    required this.coloreAvatar,
    this.promptPubblicati = 0,
    this.likeRicevuti = 0,
    this.forkRicevuti = 0,
    required this.dataIscrizione,
  });
}
