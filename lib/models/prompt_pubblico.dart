import 'package:ideai/models/prompt_generato.dart';
import 'package:ideai/models/commento.dart';

/// Livelli di visibilità per un prompt condiviso
enum Visibilita { privato, soloLink, pubblico }

/// Modello che rappresenta un prompt pubblicato nella community.
/// Estende le informazioni del prompt con dati social (like, fork, commenti).
class PromptPubblico {
  /// Identificativo univoco
  final String id;

  /// Titolo del prompt
  final String titolo;

  /// Descrizione breve
  final String descrizione;

  /// Categoria del prompt
  final String categoria;

  /// ID dell'autore originale
  final String autoreId;

  /// Nome utente dell'autore
  final String autoreNome;

  /// Colore avatar dell'autore
  final int autoreColore;

  /// Sezioni strutturate del prompt
  final List<SezionePrompt> sezioni;

  /// Punteggio di qualità (0.0 - 5.0)
  final double punteggio;

  /// Numero di like ricevuti
  int numerLike;

  /// Numero di fork
  int numeroFork;

  /// Lista dei commenti
  final List<Commento> commenti;

  /// Visibilità del prompt
  final Visibilita visibilita;

  /// Data di pubblicazione
  final DateTime dataPubblicazione;

  /// Se il prompt è un fork, ID del prompt originale
  final String? forkatoDaId;

  /// Se il prompt è un fork, nome dell'autore originale
  final String? forkatoDaNome;

  /// Tag per la ricerca
  final List<String> tag;

  /// Se l'utente corrente ha messo like
  bool haLike;

  PromptPubblico({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.categoria,
    required this.autoreId,
    required this.autoreNome,
    required this.autoreColore,
    required this.sezioni,
    required this.punteggio,
    this.numerLike = 0,
    this.numeroFork = 0,
    this.commenti = const [],
    this.visibilita = Visibilita.pubblico,
    required this.dataPubblicazione,
    this.forkatoDaId,
    this.forkatoDaNome,
    this.tag = const [],
    this.haLike = false,
  });

  /// Restituisce il prompt come testo continuo
  String get testoCompleto {
    return sezioni
        .where((s) => s.contenuto.isNotEmpty)
        .map((s) => s.contenuto)
        .join('\n\n');
  }
}
