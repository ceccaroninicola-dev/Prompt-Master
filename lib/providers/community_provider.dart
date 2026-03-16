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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un senior Python developer con 15 anni di esperienza nel debugging di applicazioni complesse.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo analizzare un bug in un\'applicazione Python che si manifesta solo in produzione. Il codice funziona correttamente in ambiente di sviluppo.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: '1. Analizza il traceback fornito\n2. Identifica le possibili cause root\n3. Suggerisci fix con codice\n4. Proponi test per prevenire regressioni', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Rispondi con: diagnosi breve, causa probabile, codice fix, test suggeriti.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Usa solo librerie standard Python. Il fix deve essere retrocompatibile con Python 3.8+.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un esperto di architettura API REST e FastAPI.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Sto creando un\'API REST per un\'app di gestione progetti con autenticazione JWT.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: 'Genera gli endpoint CRUD completi con validazione Pydantic, gestione errori e documentazione OpenAPI.', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Codice Python con type hints, docstring e commenti inline.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Usa async/await. Segui le best practice di sicurezza OWASP.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un tech lead esperto che conduce code review approfondite ma costruttive.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo fare review di un pull request. Voglio feedback su qualità, sicurezza, performance e leggibilità.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: '1. Analizza il codice riga per riga\n2. Segnala bug potenziali\n3. Suggerisci miglioramenti\n4. Evidenzia aspetti positivi\n5. Dai un voto complessivo', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Lista numerata con: [CRITICO], [SUGGERIMENTO], [POSITIVO] per ogni punto.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Tono costruttivo e educativo. Non solo criticare, anche spiegare il perché.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un copywriter specializzato in LinkedIn con esperienza nel personal branding.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Voglio creare un post LinkedIn che racconti una lezione professionale in modo coinvolgente.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: '1. Hook potente nella prima riga\n2. Storia personale breve\n3. Lezione pratica\n4. Call to action\n5. 3-5 hashtag rilevanti', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Post pronto da pubblicare, max 1300 caratteri, con righe corte e spazi per leggibilità mobile.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'No linguaggio corporate. Tono autentico e conversazionale. No emoji eccessivi.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un email marketer esperto con focus sulla conversione.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo scrivere una newsletter settimanale per una lista di 5000 iscritti nel settore tech.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: 'Crea oggetto email accattivante, preview text, corpo con 3 sezioni tematiche e CTA finale.', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Formato markdown con sezioni chiare. Oggetto email separato.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Max 500 parole. Niente spam trigger words. Tono informale ma professionale.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un analista logico che risolve problemi complessi attraverso ragionamento strutturato.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Ho un problema complesso che richiede analisi multi-dimensionale e ragionamento step-by-step.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: '1. Scomponi il problema in sotto-problemi\n2. Per ogni sotto-problema, ragiona ad alta voce\n3. Identifica assunzioni e bias\n4. Valuta alternative\n5. Sintetizza la conclusione', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Ragionamento numerato con [STEP], [ANALISI], [CONCLUSIONE] per ogni fase.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Mostra sempre il ragionamento, non solo la risposta. Segnala incertezze.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un ricercatore accademico esperto nell\'analisi di paper scientifici.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo analizzare un paper scientifico e estrarre le informazioni più rilevanti per la mia ricerca.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: '1. Riassumi abstract e contributo principale\n2. Analizza metodologia\n3. Valuta risultati e limiti\n4. Identifica applicazioni pratiche\n5. Suggerisci paper correlati', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Scheda riassuntiva strutturata con bullet points per ogni sezione.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Mantieni rigore accademico. Distingui fatti da interpretazioni.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un prompt engineer esperto che analizza e ottimizza prompt per qualsiasi AI.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Ho un prompt che funziona ma non produce risultati ottimali. Voglio migliorarlo sistematicamente.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: '1. Analizza il prompt fornito\n2. Identifica punti deboli (vaghezza, ambiguità, mancanza di contesto)\n3. Riscrivi ogni sezione migliorandola\n4. Spiega ogni modifica\n5. Fornisci versione finale ottimizzata', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Prima/dopo per ogni sezione, con spiegazione della modifica. Prompt finale completo alla fine.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Non cambiare l\'intento originale. Migliora solo chiarezza, specificità e struttura.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un social media manager esperto con focus sulla pianificazione strategica dei contenuti.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Gestisco i social di un brand tech. Devo pianificare i contenuti del prossimo mese.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: 'Crea un calendario editoriale per 30 giorni con: data, piattaforma, tipo di post, copy, hashtag suggeriti.', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Tabella markdown con colonne: Data, Piattaforma, Tipo, Copy, Hashtag.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Alterna formati (carosello, reel, story, post). Max 3 post al giorno. Includi date rilevanti del mese.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un consulente di strategia aziendale specializzato in analisi competitiva.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo analizzare un competitor diretto del mio prodotto per trovare punti di differenziazione.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: '1. Analizza punti di forza e debolezza\n2. Identifica gap nel mercato\n3. Suggerisci strategie di differenziazione\n4. Proponi unique selling proposition', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'SWOT analysis seguita da raccomandazioni strategiche numerate.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Basati solo su informazioni pubblicamente disponibili. No speculazioni non supportate.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un concept artist specializzato in mondi fantasy e creature mitologiche.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo creare concept art per un gioco fantasy RPG con un\'estetica unica.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: 'Genera una descrizione dettagliata per immagine: soggetto, ambiente, illuminazione, stile artistico, palette colori, atmosfera, dettagli tecnici per AI generativa.', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Prompt ottimizzato per Midjourney v6 con parametri --ar, --style, --chaos.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Stile coerente con art direction fantasy epico. No elementi moderni o anacronistici.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un UI designer esperto con focus su design system moderni e accessibilità.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo creare un mockup rapido per un\'app mobile seguendo le linee guida Material Design 3.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: 'Descrivi il layout della schermata: header, body, footer, componenti, colori, tipografia, spaziature.', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Descrizione testuale strutturata + prompt per DALL-E o Stable Diffusion.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Segui WCAG 2.1 AA. Supporta dark e light mode. Mobile-first.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un data analyst senior esperto in visualizzazione dati con Python.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo creare una dashboard interattiva per visualizzare KPI aziendali da un dataset CSV.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: '1. Analizza la struttura del dataset\n2. Identifica KPI principali\n3. Genera codice Plotly/Dash per la dashboard\n4. Aggiungi filtri interattivi\n5. Esporta in HTML', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Codice Python completo con commenti, pronto da eseguire.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Usa solo Plotly e Dash. Design responsive. Palette colori coerente.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un DevOps engineer esperto in containerizzazione e ottimizzazione Docker.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo containerizzare un\'applicazione web con backend API e frontend statico.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: 'Genera un Dockerfile multi-stage ottimizzato: stage di build, stage di produzione, con layer caching e security hardening.', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Dockerfile completo con commenti per ogni istruzione. Docker-compose.yml se necessario.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Immagine base Alpine. Non eseguire come root. Minimizza layer e dimensione finale.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un Go developer senior con forte focus sulla qualità del codice e testing.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo scrivere test unitari completi per una funzione Go usando il pattern table-driven.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: '1. Analizza la funzione\n2. Identifica edge cases\n3. Genera test table-driven\n4. Includi benchmark se rilevanti\n5. Aggiungi test di errore', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'File _test.go completo con subtests, helper e commenti.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Solo libreria standard testing. Copertura minima 90%. Nomi test descrittivi.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un pedagogista esperto con specializzazione in didattica attiva e apprendimento cooperativo.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo creare un piano lezione interattivo per una classe di studenti delle superiori.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: '1. Definisci obiettivi di apprendimento\n2. Crea attività di warm-up\n3. Sviluppa il contenuto principale con attività pratiche\n4. Includi momento di riflessione\n5. Prepara valutazione formativa', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Piano lezione strutturato con tempistiche, materiali necessari e note per l\'insegnante.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Durata 60 minuti. Inclusivo per diversi stili di apprendimento. No materiali costosi.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un advisor di startup con esperienza nel fundraising seed e Series A.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Sto preparando un pitch deck per un round seed di una startup SaaS B2B.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: 'Crea la struttura di 12 slide: problema, soluzione, mercato, modello di business, traction, team, roadmap, financials, ask.', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Una sezione per slide con: titolo, bullet point chiave, note per il presenter.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Max 12 slide. Storytelling coinvolgente. Dati e metriche concrete dove possibile.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un fotografo professionista specializzato in ritratti artistici con illuminazione naturale.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo generare un ritratto fotografico realistico con un\'atmosfera specifica usando AI generativa.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: 'Descrivi: soggetto, espressione, postura, illuminazione (direzione, temperatura, intensità), sfondo, profondità di campo, lens type, mood generale.', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Prompt per Stable Diffusion XL con negative prompt, steps, CFG scale, sampler.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Stile fotografico realistico, non illustrativo. Evita uncanny valley. Risoluzione 4K.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un graphic designer specializzato in brand identity e logo design minimalista.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo creare un logo minimalista per un brand tech/startup.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: 'Genera una descrizione dettagliata per: forma geometrica, tipografia, simbolismo, palette colori (max 2 colori), varianti (positivo, negativo, monochrome).', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Brief creativo + prompt per DALL-E 3 con stile flat, vettoriale, sfondo bianco.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Scalabile da favicon a billboard. Leggibile in bianco e nero. No clipart generico.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un product owner certificato con esperienza in metodologie agile.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo scrivere user story chiare e implementabili per il prossimo sprint del mio team.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: '1. Formato "Come [persona], voglio [azione], così che [beneficio]"\n2. Criteri di accettazione GIVEN-WHEN-THEN\n3. Story points stimati\n4. Dipendenze identificate', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Card user story con: titolo, descrizione, criteri di accettazione, priority, story points.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Segui criteri INVEST. Ogni story completabile in uno sprint. Linguaggio non tecnico.', colore: 0xFFC62828),
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
          const SezionePrompt(titolo: 'Ruolo', icona: 'person', contenuto: 'Sei un content strategist specializzato in SEO on-page e content marketing.', colore: 0xFF1976D2),
          const SezionePrompt(titolo: 'Contesto', icona: 'info', contenuto: 'Devo scrivere un articolo blog che si posizioni in prima pagina per una keyword specifica.', colore: 0xFF388E3C),
          const SezionePrompt(titolo: 'Istruzioni', icona: 'list', contenuto: '1. Ricerca keyword e search intent\n2. Struttura H1-H2-H3 ottimizzata\n3. Introduzione con hook\n4. Corpo con sottosezioni e FAQ\n5. Meta title e meta description\n6. Internal linking suggeriti', colore: 0xFFF57C00),
          const SezionePrompt(titolo: 'Formato Output', icona: 'format_align_left', contenuto: 'Articolo in markdown con heading gerarchici. Meta tag separati. Keyword density target: 1-2%.', colore: 0xFF7B1FA2),
          const SezionePrompt(titolo: 'Vincoli', icona: 'block', contenuto: 'Min 1500 parole. Leggibilità Flesch-Kincaid < 60. No keyword stuffing. Contenuto originale e utile.', colore: 0xFFC62828),
        ],
      ),
    ];
  }
}
