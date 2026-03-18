import 'package:flutter/material.dart';
import 'package:prompt_master/models/utente.dart';
import 'package:prompt_master/models/prompt_pubblico.dart';
import 'package:prompt_master/models/prompt_generato.dart';
import 'package:prompt_master/models/commento.dart';

/// Provider per la gestione della community.
/// Gestisce utenti, prompt pubblici, like, fork e commenti.
/// Per ora usa dati fittizi — in futuro si collegherà al backend.
class CommunityProvider extends ChangeNotifier {
  // === UTENTE CORRENTE (fittizio) ===
  Utente _utenteCorrente = Utente(
    id: 'me',
    nomeUtente: '@prompt_hero',
    nomeCompleto: 'Tu',
    bio: 'Appassionato di AI e prompt engineering',
    coloreAvatar: 0xFF009688,
    promptPubblicati: 3,
    likeRicevuti: 42,
    forkRicevuti: 8,
    dataIscrizione: DateTime(2025, 6, 1),
  );

  Utente get utenteCorrente => _utenteCorrente;

  // === UTENTI FITTIZI ===
  final List<Utente> _utenti = [
    Utente(
      id: 'u1',
      nomeUtente: '@marco_dev',
      nomeCompleto: 'Marco Rossi',
      bio: 'Full-stack developer | Amo automatizzare tutto con AI',
      coloreAvatar: 0xFF1976D2,
      promptPubblicati: 3,
      likeRicevuti: 87,
      forkRicevuti: 12,
      dataIscrizione: DateTime(2025, 3, 15),
    ),
    Utente(
      id: 'u2',
      nomeUtente: '@sara_writes',
      nomeCompleto: 'Sara Bianchi',
      bio: 'Copywriter freelance | Prompt per contenuti creativi',
      coloreAvatar: 0xFFE91E63,
      promptPubblicati: 2,
      likeRicevuti: 134,
      forkRicevuti: 28,
      dataIscrizione: DateTime(2025, 1, 10),
    ),
    Utente(
      id: 'u3',
      nomeUtente: '@luca_ai',
      nomeCompleto: 'Luca Verdi',
      bio: 'AI researcher | Esploro i limiti dei modelli linguistici',
      coloreAvatar: 0xFF4CAF50,
      promptPubblicati: 3,
      likeRicevuti: 256,
      forkRicevuti: 45,
      dataIscrizione: DateTime(2024, 11, 5),
    ),
    Utente(
      id: 'u4',
      nomeUtente: '@giulia_mkt',
      nomeCompleto: 'Giulia Ferrari',
      bio: 'Digital marketer | Creo campagne con l\'AI',
      coloreAvatar: 0xFFFF9800,
      promptPubblicati: 2,
      likeRicevuti: 98,
      forkRicevuti: 15,
      dataIscrizione: DateTime(2025, 2, 20),
    ),
    Utente(
      id: 'u5',
      nomeUtente: '@alex_design',
      nomeCompleto: 'Alessandro Conti',
      bio: 'UI/UX Designer | Prompt per generazione immagini',
      coloreAvatar: 0xFF9C27B0,
      promptPubblicati: 2,
      likeRicevuti: 176,
      forkRicevuti: 32,
      dataIscrizione: DateTime(2025, 4, 1),
    ),
    Utente(
      id: 'u6',
      nomeUtente: '@emma_data',
      nomeCompleto: 'Emma Russo',
      bio: 'Data scientist | Analisi dati potenziata da AI',
      coloreAvatar: 0xFF00BCD4,
      promptPubblicati: 1,
      likeRicevuti: 64,
      forkRicevuti: 9,
      dataIscrizione: DateTime(2025, 5, 12),
    ),
    Utente(
      id: 'u7',
      nomeUtente: '@paolo_code',
      nomeCompleto: 'Paolo Marino',
      bio: 'Backend developer | Python e Go enthusiast',
      coloreAvatar: 0xFF607D8B,
      promptPubblicati: 2,
      likeRicevuti: 112,
      forkRicevuti: 18,
      dataIscrizione: DateTime(2025, 1, 25),
    ),
    Utente(
      id: 'u8',
      nomeUtente: '@chiara_edu',
      nomeCompleto: 'Chiara Lombardi',
      bio: 'Insegnante | Uso l\'AI per creare materiale didattico',
      coloreAvatar: 0xFFFFC107,
      promptPubblicati: 1,
      likeRicevuti: 89,
      forkRicevuti: 21,
      dataIscrizione: DateTime(2025, 3, 8),
    ),
    Utente(
      id: 'u9',
      nomeUtente: '@matteo_startup',
      nomeCompleto: 'Matteo Colombo',
      bio: 'Founder & CEO | L\'AI come copilota per startup',
      coloreAvatar: 0xFFFF5722,
      promptPubblicati: 1,
      likeRicevuti: 45,
      forkRicevuti: 6,
      dataIscrizione: DateTime(2025, 6, 20),
    ),
    Utente(
      id: 'u10',
      nomeUtente: '@francesca_art',
      nomeCompleto: 'Francesca Moretti',
      bio: 'Digital artist | Creo mondi con Midjourney e Stable Diffusion',
      coloreAvatar: 0xFFE040FB,
      promptPubblicati: 2,
      likeRicevuti: 203,
      forkRicevuti: 38,
      dataIscrizione: DateTime(2024, 12, 1),
    ),
    Utente(
      id: 'u11',
      nomeUtente: '@davide_pm',
      nomeCompleto: 'Davide Ricci',
      bio: 'Product manager | Prompt per analisi e strategia',
      coloreAvatar: 0xFF795548,
      promptPubblicati: 1,
      likeRicevuti: 56,
      forkRicevuti: 7,
      dataIscrizione: DateTime(2025, 4, 15),
    ),
    Utente(
      id: 'u12',
      nomeUtente: '@valentina_seo',
      nomeCompleto: 'Valentina Galli',
      bio: 'SEO specialist | Contenuti ottimizzati con AI',
      coloreAvatar: 0xFF3F51B5,
      promptPubblicati: 1,
      likeRicevuti: 78,
      forkRicevuti: 11,
      dataIscrizione: DateTime(2025, 5, 3),
    ),
  ];

  List<Utente> get utenti => _utenti;

  // === PROMPT PUBBLICI FITTIZI ===
  late final List<PromptPubblico> _promptPubblici = _generaPromptFittizi();

  List<PromptPubblico> get promptPubblici => _promptPubblici;

  /// Filtro categoria corrente
  String _categoriaFiltro = 'Tutti';
  String get categoriaFiltro => _categoriaFiltro;

  /// Testo di ricerca
  String _testoRicerca = '';
  String get testoRicerca => _testoRicerca;

  /// Categorie disponibili per i filtri
  final List<String> categorie = [
    'Tutti',
    'Coding',
    'Scrittura',
    'Marketing',
    'Immagini',
    'Analisi',
    'Studio',
    'Email',
  ];

  // === GETTERS FILTRATI ===

  /// Prompt trending — ordinati per like, top 10
  List<PromptPubblico> get trending {
    final pubblici = _promptPubblici
        .where((p) => p.visibilita == Visibilita.pubblico)
        .toList()
      ..sort((a, b) => b.numerLike.compareTo(a.numerLike));
    return pubblici.take(10).toList();
  }

  /// Prompt più recenti
  List<PromptPubblico> get piuRecenti {
    final pubblici = _promptPubblici
        .where((p) => p.visibilita == Visibilita.pubblico)
        .toList()
      ..sort((a, b) => b.dataPubblicazione.compareTo(a.dataPubblicazione));
    return pubblici;
  }

  /// Prompt filtrati per categoria e ricerca
  List<PromptPubblico> get promptFiltrati {
    var risultati = _promptPubblici
        .where((p) => p.visibilita == Visibilita.pubblico)
        .toList();

    if (_categoriaFiltro != 'Tutti') {
      risultati =
          risultati.where((p) => p.categoria == _categoriaFiltro).toList();
    }

    if (_testoRicerca.isNotEmpty) {
      final query = _testoRicerca.toLowerCase();
      risultati = risultati
          .where((p) =>
              p.titolo.toLowerCase().contains(query) ||
              p.descrizione.toLowerCase().contains(query) ||
              p.autoreNome.toLowerCase().contains(query) ||
              p.tag.any((t) => t.toLowerCase().contains(query)))
          .toList();
    }

    return risultati;
  }

  /// Prompt dell'utente corrente
  List<PromptPubblico> get promptUtente {
    return _promptPubblici.where((p) => p.autoreId == 'me').toList();
  }

  /// Prompt di un utente specifico
  List<PromptPubblico> promptDiUtente(String utenteId) {
    return _promptPubblici
        .where(
            (p) => p.autoreId == utenteId && p.visibilita == Visibilita.pubblico)
        .toList();
  }

  /// Trova un utente per ID
  Utente? trovaUtente(String id) {
    if (id == 'me') return _utenteCorrente;
    try {
      return _utenti.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  // === AZIONI ===

  /// Aggiorna il filtro categoria
  void filtraPerCategoria(String categoria) {
    _categoriaFiltro = categoria;
    notifyListeners();
  }

  /// Aggiorna il testo di ricerca
  void cercaPrompt(String testo) {
    _testoRicerca = testo;
    notifyListeners();
  }

  /// Toggle like su un prompt
  void toggleLike(String promptId) {
    final prompt =
        _promptPubblici.firstWhere((p) => p.id == promptId);
    if (prompt.haLike) {
      prompt.numerLike--;
      prompt.haLike = false;
    } else {
      prompt.numerLike++;
      prompt.haLike = true;
    }
    notifyListeners();
  }

  /// Fork di un prompt — crea una copia nel profilo dell'utente
  void forkPrompt(PromptPubblico originale) {
    final fork = PromptPubblico(
      id: 'fork_${DateTime.now().millisecondsSinceEpoch}',
      titolo: '${originale.titolo} (fork)',
      descrizione: originale.descrizione,
      categoria: originale.categoria,
      autoreId: 'me',
      autoreNome: _utenteCorrente.nomeUtente,
      autoreColore: _utenteCorrente.coloreAvatar,
      sezioni: List.from(originale.sezioni),
      punteggio: originale.punteggio,
      numerLike: 0,
      numeroFork: 0,
      commenti: [],
      visibilita: Visibilita.privato,
      dataPubblicazione: DateTime.now(),
      forkatoDaId: originale.id,
      forkatoDaNome: originale.autoreNome,
      tag: List.from(originale.tag),
    );

    // Incrementa il contatore fork sull'originale
    originale.numeroFork++;
    _promptPubblici.insert(0, fork);

    // Aggiorna statistiche utente
    _utenteCorrente = Utente(
      id: _utenteCorrente.id,
      nomeUtente: _utenteCorrente.nomeUtente,
      nomeCompleto: _utenteCorrente.nomeCompleto,
      bio: _utenteCorrente.bio,
      coloreAvatar: _utenteCorrente.coloreAvatar,
      promptPubblicati: _utenteCorrente.promptPubblicati + 1,
      likeRicevuti: _utenteCorrente.likeRicevuti,
      forkRicevuti: _utenteCorrente.forkRicevuti,
      dataIscrizione: _utenteCorrente.dataIscrizione,
    );

    notifyListeners();
  }

  /// Aggiungi un commento a un prompt
  void aggiungiCommento(String promptId, String testo) {
    final prompt =
        _promptPubblici.firstWhere((p) => p.id == promptId);
    prompt.commenti.add(Commento(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      autoreId: 'me',
      autoreNome: _utenteCorrente.nomeUtente,
      autoreColore: _utenteCorrente.coloreAvatar,
      testo: testo,
      data: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Pubblica un prompt (da post-generazione)
  void pubblicaPrompt({
    required String titolo,
    required String descrizione,
    required String categoria,
    required List<SezionePrompt> sezioni,
    required double punteggio,
    required Visibilita visibilita,
    List<String> tag = const [],
  }) {
    final nuovo = PromptPubblico(
      id: 'pub_${DateTime.now().millisecondsSinceEpoch}',
      titolo: titolo,
      descrizione: descrizione,
      categoria: categoria,
      autoreId: 'me',
      autoreNome: _utenteCorrente.nomeUtente,
      autoreColore: _utenteCorrente.coloreAvatar,
      sezioni: sezioni,
      punteggio: punteggio,
      visibilita: visibilita,
      dataPubblicazione: DateTime.now(),
      tag: tag,
    );

    _promptPubblici.insert(0, nuovo);

    _utenteCorrente = Utente(
      id: _utenteCorrente.id,
      nomeUtente: _utenteCorrente.nomeUtente,
      nomeCompleto: _utenteCorrente.nomeCompleto,
      bio: _utenteCorrente.bio,
      coloreAvatar: _utenteCorrente.coloreAvatar,
      promptPubblicati: _utenteCorrente.promptPubblicati + 1,
      likeRicevuti: _utenteCorrente.likeRicevuti,
      forkRicevuti: _utenteCorrente.forkRicevuti,
      dataIscrizione: _utenteCorrente.dataIscrizione,
    );

    notifyListeners();
  }

  /// Aggiorna il profilo dell'utente corrente
  void aggiornaProfilo({String? bio}) {
    if (bio != null) {
      _utenteCorrente = Utente(
        id: _utenteCorrente.id,
        nomeUtente: _utenteCorrente.nomeUtente,
        nomeCompleto: _utenteCorrente.nomeCompleto,
        bio: bio,
        coloreAvatar: _utenteCorrente.coloreAvatar,
        promptPubblicati: _utenteCorrente.promptPubblicati,
        likeRicevuti: _utenteCorrente.likeRicevuti,
        forkRicevuti: _utenteCorrente.forkRicevuti,
        dataIscrizione: _utenteCorrente.dataIscrizione,
      );
      notifyListeners();
    }
  }

  // === GENERAZIONE DATI FITTIZI ===

  List<PromptPubblico> _generaPromptFittizi() {
    return [
      // --- @marco_dev ---
      PromptPubblico(
        id: 'p1',
        titolo: 'Debug intelligente Python',
        descrizione: 'Prompt per analizzare e risolvere bug complessi in Python',
        categoria: 'Coding',
        autoreId: 'u1',
        autoreNome: '@marco_dev',
        autoreColore: 0xFF1976D2,
        punteggio: 4.6,
        numerLike: 45,
        numeroFork: 8,
        dataPubblicazione: DateTime(2026, 3, 14),
        tag: ['python', 'debug', 'coding'],
        commenti: [
          Commento(id: 'c1', autoreId: 'u3', autoreNome: '@luca_ai', autoreColore: 0xFF4CAF50, testo: 'Ottimo prompt! Lo uso ogni giorno per il mio lavoro.', data: DateTime(2026, 3, 15)),
          Commento(id: 'c2', autoreId: 'u7', autoreNome: '@paolo_code', autoreColore: 0xFF607D8B, testo: 'Suggerisco di aggiungere una sezione per i test unitari.', data: DateTime(2026, 3, 15)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Codice', icona: 'code', contenuto: 'Analizza il bug nella mia applicazione Python che si manifesta solo in produzione ma funziona correttamente in ambiente di sviluppo. Esamina il traceback fornito, identifica le possibili cause root, suggerisci fix con codice e proponi test per prevenire regressioni. Rispondi con diagnosi breve, causa probabile, codice fix e test suggeriti. Usa solo librerie standard Python e assicurati che il fix sia retrocompatibile con Python 3.8+.', colore: 0xFF7C3AED),
        ],
      ),
      PromptPubblico(
        id: 'p2',
        titolo: 'API REST con FastAPI',
        descrizione: 'Genera endpoint REST completi con documentazione',
        categoria: 'Coding',
        autoreId: 'u1',
        autoreNome: '@marco_dev',
        autoreColore: 0xFF1976D2,
        punteggio: 4.3,
        numerLike: 32,
        numeroFork: 5,
        dataPubblicazione: DateTime(2026, 3, 10),
        tag: ['fastapi', 'rest', 'api'],
        commenti: [
          Commento(id: 'c3', autoreId: 'u6', autoreNome: '@emma_data', autoreColore: 0xFF00BCD4, testo: 'Perfetto per i miei progetti di data science!', data: DateTime(2026, 3, 11)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Codice', icona: 'code', contenuto: 'Genera gli endpoint CRUD completi per un\'API REST FastAPI dedicata a un\'app di gestione progetti con autenticazione JWT. Includi validazione Pydantic, gestione errori e documentazione OpenAPI. Produci codice Python con type hints, docstring e commenti inline. Usa async/await e segui le best practice di sicurezza OWASP.', colore: 0xFF7C3AED),
        ],
      ),
      PromptPubblico(
        id: 'p3',
        titolo: 'Review del codice approfondita',
        descrizione: 'Prompt per ottenere code review dettagliate e costruttive',
        categoria: 'Coding',
        autoreId: 'u1',
        autoreNome: '@marco_dev',
        autoreColore: 0xFF1976D2,
        punteggio: 4.8,
        numerLike: 67,
        numeroFork: 14,
        dataPubblicazione: DateTime(2026, 3, 8),
        tag: ['code-review', 'best-practices'],
        commenti: [
          Commento(id: 'c4', autoreId: 'u5', autoreNome: '@alex_design', autoreColore: 0xFF9C27B0, testo: 'Lo uso per fare self-review prima di aprire PR.', data: DateTime(2026, 3, 9)),
          Commento(id: 'c5', autoreId: 'u9', autoreNome: '@matteo_startup', autoreColore: 0xFFFF5722, testo: 'Fantastico per team piccoli senza reviewer dedicato!', data: DateTime(2026, 3, 10)),
          Commento(id: 'c6', autoreId: 'u2', autoreNome: '@sara_writes', autoreColore: 0xFFE91E63, testo: 'Anche per chi non è developer, aiuta a capire il codice.', data: DateTime(2026, 3, 12)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Codice', icona: 'code', contenuto: 'Esegui una code review approfondita del pull request fornito, analizzando il codice riga per riga. Valuta qualità, sicurezza, performance e leggibilità. Segnala bug potenziali, suggerisci miglioramenti e evidenzia anche gli aspetti positivi, assegnando un voto complessivo. Presenta i risultati come lista numerata con etichette [CRITICO], [SUGGERIMENTO], [POSITIVO] per ogni punto. Mantieni un tono costruttivo e educativo, spiegando sempre il perché di ogni osservazione.', colore: 0xFF7C3AED),
        ],
      ),

      // --- @sara_writes ---
      PromptPubblico(
        id: 'p4',
        titolo: 'Post LinkedIn virale',
        descrizione: 'Crea post LinkedIn che generano engagement',
        categoria: 'Marketing',
        autoreId: 'u2',
        autoreNome: '@sara_writes',
        autoreColore: 0xFFE91E63,
        punteggio: 4.5,
        numerLike: 89,
        numeroFork: 22,
        dataPubblicazione: DateTime(2026, 3, 13),
        tag: ['linkedin', 'social', 'engagement'],
        commenti: [
          Commento(id: 'c7', autoreId: 'u4', autoreNome: '@giulia_mkt', autoreColore: 0xFFFF9800, testo: 'I miei post hanno raddoppiato le impressions!', data: DateTime(2026, 3, 14)),
          Commento(id: 'c8', autoreId: 'u11', autoreNome: '@davide_pm', autoreColore: 0xFF795548, testo: 'Struttura perfetta per raccontare storie di prodotto.', data: DateTime(2026, 3, 14)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Marketing', icona: 'campaign', contenuto: 'Scrivi un post LinkedIn che racconti una lezione professionale in modo coinvolgente, con un hook potente nella prima riga, una storia personale breve, una lezione pratica, una call to action e 3-5 hashtag rilevanti. Il post deve essere pronto da pubblicare, massimo 1300 caratteri, con righe corte e spazi per leggibilità mobile. Usa un tono autentico e conversazionale, evitando linguaggio corporate ed emoji eccessivi.', colore: 0xFF7C3AED),
        ],
      ),
      PromptPubblico(
        id: 'p5',
        titolo: 'Newsletter che converte',
        descrizione: 'Template per newsletter con alto tasso di apertura',
        categoria: 'Email',
        autoreId: 'u2',
        autoreNome: '@sara_writes',
        autoreColore: 0xFFE91E63,
        punteggio: 4.2,
        numerLike: 56,
        numeroFork: 11,
        dataPubblicazione: DateTime(2026, 3, 5),
        tag: ['newsletter', 'email', 'conversione'],
        commenti: [],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Email', icona: 'email', contenuto: 'Scrivi una newsletter settimanale per una lista di 5000 iscritti nel settore tech, orientata alla conversione. Crea un oggetto email accattivante, un preview text efficace, un corpo con 3 sezioni tematiche e una CTA finale. Formatta in markdown con sezioni chiare e oggetto email separato. Mantieni il testo entro le 500 parole, evita spam trigger words e usa un tono informale ma professionale.', colore: 0xFF7C3AED),
        ],
      ),

      // --- @luca_ai ---
      PromptPubblico(
        id: 'p6',
        titolo: 'Chain-of-thought avanzato',
        descrizione: 'Prompt per ragionamento step-by-step su problemi complessi',
        categoria: 'Analisi',
        autoreId: 'u3',
        autoreNome: '@luca_ai',
        autoreColore: 0xFF4CAF50,
        punteggio: 4.9,
        numerLike: 134,
        numeroFork: 30,
        dataPubblicazione: DateTime(2026, 3, 12),
        tag: ['chain-of-thought', 'ragionamento', 'analisi'],
        commenti: [
          Commento(id: 'c9', autoreId: 'u1', autoreNome: '@marco_dev', autoreColore: 0xFF1976D2, testo: 'Il miglior prompt per problemi di logica che abbia mai visto.', data: DateTime(2026, 3, 13)),
          Commento(id: 'c10', autoreId: 'u8', autoreNome: '@chiara_edu', autoreColore: 0xFFFFC107, testo: 'Lo uso con i miei studenti per insegnare il pensiero critico!', data: DateTime(2026, 3, 14)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Analisi', icona: 'analytics', contenuto: 'Analizza il problema complesso fornito scomponendolo in sotto-problemi, ragionando ad alta voce per ciascuno. Identifica assunzioni e bias, valuta alternative e sintetizza una conclusione strutturata. Presenta il ragionamento numerato con etichette [STEP], [ANALISI], [CONCLUSIONE] per ogni fase. Mostra sempre il percorso logico completo, non solo la risposta finale, e segnala esplicitamente le incertezze.', colore: 0xFF7C3AED),
        ],
      ),
      PromptPubblico(
        id: 'p7',
        titolo: 'Analisi paper scientifico',
        descrizione: 'Estrai insights chiave da paper accademici',
        categoria: 'Studio',
        autoreId: 'u3',
        autoreNome: '@luca_ai',
        autoreColore: 0xFF4CAF50,
        punteggio: 4.4,
        numerLike: 78,
        numeroFork: 16,
        dataPubblicazione: DateTime(2026, 3, 6),
        tag: ['paper', 'ricerca', 'studio'],
        commenti: [
          Commento(id: 'c11', autoreId: 'u6', autoreNome: '@emma_data', autoreColore: 0xFF00BCD4, testo: 'Indispensabile per il mio dottorato!', data: DateTime(2026, 3, 7)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Studio', icona: 'school', contenuto: 'Analizza il paper scientifico fornito estraendo le informazioni più rilevanti. Riassumi abstract e contributo principale, analizza la metodologia, valuta risultati e limiti, identifica applicazioni pratiche e suggerisci paper correlati. Presenta i risultati come scheda riassuntiva strutturata con bullet points per ogni sezione. Mantieni rigore accademico e distingui chiaramente i fatti dalle interpretazioni.', colore: 0xFF7C3AED),
        ],
      ),
      PromptPubblico(
        id: 'p8',
        titolo: 'Prompt meta-ottimizzatore',
        descrizione: 'Un prompt che migliora altri prompt automaticamente',
        categoria: 'Analisi',
        autoreId: 'u3',
        autoreNome: '@luca_ai',
        autoreColore: 0xFF4CAF50,
        punteggio: 4.7,
        numerLike: 112,
        numeroFork: 25,
        dataPubblicazione: DateTime(2026, 2, 28),
        tag: ['meta', 'ottimizzazione', 'prompt-engineering'],
        commenti: [
          Commento(id: 'c12', autoreId: 'u2', autoreNome: '@sara_writes', autoreColore: 0xFFE91E63, testo: 'Promptception! 🤯 Geniale.', data: DateTime(2026, 3, 1)),
          Commento(id: 'c13', autoreId: 'u4', autoreNome: '@giulia_mkt', autoreColore: 0xFFFF9800, testo: 'L\'ho usato per migliorare tutti i miei prompt di marketing.', data: DateTime(2026, 3, 2)),
          Commento(id: 'c14', autoreId: 'u7', autoreNome: '@paolo_code', autoreColore: 0xFF607D8B, testo: 'Incredibile come un prompt possa migliorare sé stesso.', data: DateTime(2026, 3, 3)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Analisi', icona: 'analytics', contenuto: 'Analizza il prompt fornito e ottimizzalo sistematicamente. Identifica punti deboli come vaghezza, ambiguità o mancanza di contesto, poi riscrivi ogni sezione migliorandola. Mostra il confronto prima/dopo per ogni modifica con una spiegazione chiara, e fornisci la versione finale ottimizzata completa. Non cambiare l\'intento originale del prompt, migliora solo chiarezza, specificità e struttura.', colore: 0xFF7C3AED),
        ],
      ),

      // --- @giulia_mkt ---
      PromptPubblico(
        id: 'p9',
        titolo: 'Calendario editoriale social',
        descrizione: 'Genera un mese di contenuti per i social media',
        categoria: 'Marketing',
        autoreId: 'u4',
        autoreNome: '@giulia_mkt',
        autoreColore: 0xFFFF9800,
        punteggio: 4.3,
        numerLike: 72,
        numeroFork: 18,
        dataPubblicazione: DateTime(2026, 3, 11),
        tag: ['social-media', 'calendario', 'contenuti'],
        commenti: [
          Commento(id: 'c15', autoreId: 'u12', autoreNome: '@valentina_seo', autoreColore: 0xFF3F51B5, testo: 'Perfetto per pianificare il mese in anticipo!', data: DateTime(2026, 3, 12)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Social', icona: 'share', contenuto: 'Crea un calendario editoriale social per 30 giorni per un brand tech, includendo per ogni giorno: data, piattaforma, tipo di post, copy e hashtag suggeriti. Presenta il risultato come tabella markdown con colonne Data, Piattaforma, Tipo, Copy, Hashtag. Alterna i formati tra carosello, reel, story e post, con massimo 3 post al giorno, e includi le date rilevanti del mese.', colore: 0xFF7C3AED),
        ],
      ),
      PromptPubblico(
        id: 'p10',
        titolo: 'Analisi competitor rapida',
        descrizione: 'Analizza un competitor e trova opportunità di differenziazione',
        categoria: 'Marketing',
        autoreId: 'u4',
        autoreNome: '@giulia_mkt',
        autoreColore: 0xFFFF9800,
        punteggio: 4.1,
        numerLike: 38,
        numeroFork: 6,
        dataPubblicazione: DateTime(2026, 3, 2),
        tag: ['competitor', 'analisi', 'strategia'],
        commenti: [],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Marketing', icona: 'campaign', contenuto: 'Analizza il competitor diretto fornito per trovare punti di differenziazione. Valuta punti di forza e debolezza, identifica gap nel mercato, suggerisci strategie di differenziazione e proponi una unique selling proposition. Presenta i risultati come SWOT analysis seguita da raccomandazioni strategiche numerate. Basati solo su informazioni pubblicamente disponibili, senza speculazioni non supportate.', colore: 0xFF7C3AED),
        ],
      ),

      // --- @alex_design ---
      PromptPubblico(
        id: 'p11',
        titolo: 'Concept art fantasy',
        descrizione: 'Genera descrizioni dettagliate per concept art in stile fantasy',
        categoria: 'Immagini',
        autoreId: 'u5',
        autoreNome: '@alex_design',
        autoreColore: 0xFF9C27B0,
        punteggio: 4.6,
        numerLike: 98,
        numeroFork: 20,
        dataPubblicazione: DateTime(2026, 3, 9),
        tag: ['concept-art', 'fantasy', 'midjourney'],
        commenti: [
          Commento(id: 'c16', autoreId: 'u10', autoreNome: '@francesca_art', autoreColore: 0xFFE040FB, testo: 'I risultati su Midjourney sono pazzeschi con questo prompt!', data: DateTime(2026, 3, 10)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Descrizione Immagine', icona: 'image', contenuto: 'Genera un\'immagine di concept art per un gioco fantasy RPG, descrivendo in dettaglio soggetto, ambiente, illuminazione, stile artistico, palette colori e atmosfera. Ottimizza il prompt per Midjourney v6 includendo parametri --ar, --style e --chaos. Mantieni uno stile coerente con un\'art direction fantasy epica, senza elementi moderni o anacronistici.', colore: 0xFF7C3AED),
        ],
      ),
      PromptPubblico(
        id: 'p12',
        titolo: 'UI mockup con AI',
        descrizione: 'Genera descrizioni per mockup di interfacce utente',
        categoria: 'Immagini',
        autoreId: 'u5',
        autoreNome: '@alex_design',
        autoreColore: 0xFF9C27B0,
        punteggio: 4.0,
        numerLike: 41,
        numeroFork: 7,
        dataPubblicazione: DateTime(2026, 3, 1),
        tag: ['ui', 'mockup', 'design'],
        commenti: [],
        sezioni: [
          const SezionePrompt(titolo: 'Descrizione Immagine', icona: 'image', contenuto: 'Genera un\'immagine di mockup per un\'app mobile seguendo le linee guida Material Design 3. Descrivi il layout completo della schermata includendo header, body, footer, componenti, colori, tipografia e spaziature. Produci sia una descrizione testuale strutturata sia un prompt ottimizzato per DALL-E o Stable Diffusion. Rispetta le linee guida WCAG 2.1 AA, supporta dark e light mode e adotta un approccio mobile-first.', colore: 0xFF7C3AED),
        ],
      ),

      // --- @emma_data ---
      PromptPubblico(
        id: 'p13',
        titolo: 'Dashboard dati con Python',
        descrizione: 'Genera codice per dashboard interattive con Plotly/Dash',
        categoria: 'Analisi',
        autoreId: 'u6',
        autoreNome: '@emma_data',
        autoreColore: 0xFF00BCD4,
        punteggio: 4.4,
        numerLike: 64,
        numeroFork: 9,
        dataPubblicazione: DateTime(2026, 3, 7),
        tag: ['dashboard', 'plotly', 'dati'],
        commenti: [
          Commento(id: 'c17', autoreId: 'u1', autoreNome: '@marco_dev', autoreColore: 0xFF1976D2, testo: 'Combo perfetta coding + analisi dati!', data: DateTime(2026, 3, 8)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Analisi', icona: 'analytics', contenuto: 'Crea una dashboard interattiva per visualizzare KPI aziendali a partire da un dataset CSV. Analizza la struttura del dataset, identifica i KPI principali, genera codice Plotly/Dash con filtri interattivi ed esportazione in HTML. Fornisci codice Python completo con commenti, pronto da eseguire. Usa esclusivamente Plotly e Dash, con design responsive e palette colori coerente.', colore: 0xFF7C3AED),
        ],
      ),

      // --- @paolo_code ---
      PromptPubblico(
        id: 'p14',
        titolo: 'Dockerfile ottimizzato',
        descrizione: 'Genera Dockerfile multi-stage con best practices',
        categoria: 'Coding',
        autoreId: 'u7',
        autoreNome: '@paolo_code',
        autoreColore: 0xFF607D8B,
        punteggio: 4.5,
        numerLike: 53,
        numeroFork: 10,
        dataPubblicazione: DateTime(2026, 3, 4),
        tag: ['docker', 'devops', 'infrastruttura'],
        commenti: [
          Commento(id: 'c18', autoreId: 'u9', autoreNome: '@matteo_startup', autoreColore: 0xFFFF5722, testo: 'Ci ha ridotto il tempo di build del 60%!', data: DateTime(2026, 3, 5)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Codice', icona: 'code', contenuto: 'Genera un Dockerfile multi-stage ottimizzato per containerizzare un\'applicazione web con backend API e frontend statico. Includi stage di build e produzione con layer caching e security hardening. Fornisci il Dockerfile completo con commenti per ogni istruzione e un docker-compose.yml se necessario. Usa immagine base Alpine, non eseguire come root e minimizza layer e dimensione finale.', colore: 0xFF7C3AED),
        ],
      ),
      PromptPubblico(
        id: 'p15',
        titolo: 'Test unitari Go',
        descrizione: 'Genera test table-driven per funzioni Go',
        categoria: 'Coding',
        autoreId: 'u7',
        autoreNome: '@paolo_code',
        autoreColore: 0xFF607D8B,
        punteggio: 4.2,
        numerLike: 34,
        numeroFork: 4,
        dataPubblicazione: DateTime(2026, 2, 25),
        tag: ['go', 'testing', 'tdd'],
        commenti: [],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Codice', icona: 'code', contenuto: 'Scrivi test unitari completi per la funzione Go fornita usando il pattern table-driven. Analizza la funzione, identifica gli edge cases, genera test table-driven con subtests e helper, includi benchmark se rilevanti e aggiungi test di errore. Produci un file _test.go completo con commenti. Usa solo la libreria standard testing, assicura una copertura minima del 90% e utilizza nomi test descrittivi.', colore: 0xFF7C3AED),
        ],
      ),

      // --- @chiara_edu ---
      PromptPubblico(
        id: 'p16',
        titolo: 'Piano lezione interattivo',
        descrizione: 'Genera piani lezione coinvolgenti per studenti',
        categoria: 'Studio',
        autoreId: 'u8',
        autoreNome: '@chiara_edu',
        autoreColore: 0xFFFFC107,
        punteggio: 4.3,
        numerLike: 89,
        numeroFork: 21,
        dataPubblicazione: DateTime(2026, 3, 3),
        tag: ['educazione', 'lezione', 'didattica'],
        commenti: [
          Commento(id: 'c19', autoreId: 'u3', autoreNome: '@luca_ai', autoreColore: 0xFF4CAF50, testo: 'Ottimo anche per workshop aziendali!', data: DateTime(2026, 3, 4)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Studio', icona: 'school', contenuto: 'Crea un piano lezione interattivo per una classe di studenti delle superiori con approccio di didattica attiva. Definisci obiettivi di apprendimento, crea un\'attività di warm-up, sviluppa il contenuto principale con attività pratiche, includi un momento di riflessione e prepara una valutazione formativa. Struttura il piano con tempistiche, materiali necessari e note per l\'insegnante. La lezione deve durare 60 minuti, essere inclusiva per diversi stili di apprendimento e non richiedere materiali costosi.', colore: 0xFF7C3AED),
        ],
      ),

      // --- @matteo_startup ---
      PromptPubblico(
        id: 'p17',
        titolo: 'Pitch deck per investitori',
        descrizione: 'Struttura una presentazione convincente per fundraising',
        categoria: 'Marketing',
        autoreId: 'u9',
        autoreNome: '@matteo_startup',
        autoreColore: 0xFFFF5722,
        punteggio: 4.1,
        numerLike: 45,
        numeroFork: 6,
        dataPubblicazione: DateTime(2026, 2, 20),
        tag: ['pitch', 'startup', 'fundraising'],
        commenti: [
          Commento(id: 'c20', autoreId: 'u4', autoreNome: '@giulia_mkt', autoreColore: 0xFFFF9800, testo: 'Struttura chiara e persuasiva. Bravo!', data: DateTime(2026, 2, 21)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Marketing', icona: 'campaign', contenuto: 'Crea la struttura di un pitch deck per un round seed di una startup SaaS B2B, con 12 slide che coprano problema, soluzione, mercato, modello di business, traction, team, roadmap, financials e ask. Per ogni slide fornisci titolo, bullet point chiave e note per il presenter. Usa uno storytelling coinvolgente e includi dati e metriche concrete dove possibile, mantenendo il massimo di 12 slide.', colore: 0xFF7C3AED),
        ],
      ),

      // --- @francesca_art ---
      PromptPubblico(
        id: 'p18',
        titolo: 'Ritratto fotografico AI',
        descrizione: 'Prompt ottimizzato per ritratti realistici con Stable Diffusion',
        categoria: 'Immagini',
        autoreId: 'u10',
        autoreNome: '@francesca_art',
        autoreColore: 0xFFE040FB,
        punteggio: 4.7,
        numerLike: 156,
        numeroFork: 35,
        dataPubblicazione: DateTime(2026, 3, 15),
        tag: ['ritratto', 'stable-diffusion', 'fotografia'],
        commenti: [
          Commento(id: 'c21', autoreId: 'u5', autoreNome: '@alex_design', autoreColore: 0xFF9C27B0, testo: 'Risultati incredibilmente realistici!', data: DateTime(2026, 3, 15)),
          Commento(id: 'c22', autoreId: 'u2', autoreNome: '@sara_writes', autoreColore: 0xFFE91E63, testo: 'Lo uso per le immagini dei miei articoli di blog.', data: DateTime(2026, 3, 16)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Descrizione Immagine', icona: 'image', contenuto: 'Genera un\'immagine di ritratto fotografico realistico con illuminazione naturale, descrivendo in dettaglio soggetto, espressione, postura, illuminazione (direzione, temperatura, intensità), sfondo, profondità di campo, lens type e mood generale. Ottimizza il prompt per Stable Diffusion XL includendo negative prompt, steps, CFG scale e sampler. Mantieni uno stile fotografico realistico, non illustrativo, evitando l\'uncanny valley, con risoluzione 4K.', colore: 0xFF7C3AED),
        ],
      ),
      PromptPubblico(
        id: 'p19',
        titolo: 'Logo design minimalista',
        descrizione: 'Crea brief per loghi minimalisti con AI generativa',
        categoria: 'Immagini',
        autoreId: 'u10',
        autoreNome: '@francesca_art',
        autoreColore: 0xFFE040FB,
        punteggio: 4.3,
        numerLike: 67,
        numeroFork: 12,
        dataPubblicazione: DateTime(2026, 2, 15),
        tag: ['logo', 'branding', 'minimalismo'],
        commenti: [],
        sezioni: [
          const SezionePrompt(titolo: 'Descrizione Immagine', icona: 'image', contenuto: 'Genera un\'immagine di logo minimalista per un brand tech/startup, descrivendo forma geometrica, tipografia, simbolismo, palette colori (massimo 2 colori) e varianti (positivo, negativo, monochrome). Produci un brief creativo e un prompt ottimizzato per DALL-E 3 con stile flat, vettoriale e sfondo bianco. Il logo deve essere scalabile da favicon a billboard, leggibile in bianco e nero, senza clipart generici.', colore: 0xFF7C3AED),
        ],
      ),

      // --- @davide_pm ---
      PromptPubblico(
        id: 'p20',
        titolo: 'User story efficaci',
        descrizione: 'Genera user story INVEST per il backlog di prodotto',
        categoria: 'Analisi',
        autoreId: 'u11',
        autoreNome: '@davide_pm',
        autoreColore: 0xFF795548,
        punteggio: 4.0,
        numerLike: 56,
        numeroFork: 7,
        dataPubblicazione: DateTime(2026, 2, 28),
        tag: ['agile', 'user-story', 'product'],
        commenti: [
          Commento(id: 'c23', autoreId: 'u1', autoreNome: '@marco_dev', autoreColore: 0xFF1976D2, testo: 'Finalmente user story chiare dal product manager! 😄', data: DateTime(2026, 3, 1)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Analisi', icona: 'analytics', contenuto: 'Scrivi user story chiare e implementabili per il prossimo sprint, usando il formato "Come [persona], voglio [azione], così che [beneficio]". Per ogni story includi criteri di accettazione GIVEN-WHEN-THEN, story points stimati e dipendenze identificate. Presenta ogni story come card con titolo, descrizione, criteri di accettazione, priority e story points. Segui i criteri INVEST, assicura che ogni story sia completabile in uno sprint e usa linguaggio non tecnico.', colore: 0xFF7C3AED),
        ],
      ),

      // --- @valentina_seo ---
      PromptPubblico(
        id: 'p21',
        titolo: 'Articolo SEO-optimized',
        descrizione: 'Genera articoli blog ottimizzati per i motori di ricerca',
        categoria: 'Scrittura',
        autoreId: 'u12',
        autoreNome: '@valentina_seo',
        autoreColore: 0xFF3F51B5,
        punteggio: 4.4,
        numerLike: 78,
        numeroFork: 11,
        dataPubblicazione: DateTime(2026, 3, 10),
        tag: ['seo', 'blog', 'content-marketing'],
        commenti: [
          Commento(id: 'c24', autoreId: 'u2', autoreNome: '@sara_writes', autoreColore: 0xFFE91E63, testo: 'Combinazione perfetta di SEO e leggibilità!', data: DateTime(2026, 3, 11)),
          Commento(id: 'c25', autoreId: 'u4', autoreNome: '@giulia_mkt', autoreColore: 0xFFFF9800, testo: 'Il nostro blog ha aumentato il traffico del 40% usando questo approccio.', data: DateTime(2026, 3, 12)),
        ],
        sezioni: [
          const SezionePrompt(titolo: 'Istruzione Testo', icona: 'edit_note', contenuto: 'Scrivi un articolo blog SEO-optimized per posizionarsi in prima pagina per una keyword specifica. Struttura il contenuto con heading gerarchici H1-H2-H3, un\'introduzione con hook, corpo con sottosezioni e FAQ, meta title, meta description e suggerimenti di internal linking. Formatta in markdown con meta tag separati e keyword density target dell\'1-2%. L\'articolo deve avere minimo 1500 parole, leggibilità Flesch-Kincaid inferiore a 60, senza keyword stuffing, con contenuto originale e utile.', colore: 0xFF7C3AED),
        ],
      ),
    ];
  }
}
