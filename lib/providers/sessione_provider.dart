import 'package:flutter/material.dart';
import 'package:ideai/models/categoria_rilevata.dart';
import 'package:ideai/models/domanda.dart';
import 'package:ideai/models/sessione_prompt.dart';
import 'package:ideai/services/api_service.dart';
import 'package:ideai/services/ai_prompts.dart';

/// Provider per la gestione della sessione di creazione prompt.
/// Gestisce il flusso completo: frase iniziale → categoria → domande → risposte.
/// Usa GPT-4o-mini per analisi e generazione domande, con fallback fittizio.
class SessioneProvider extends ChangeNotifier {
  /// Sessione corrente di creazione prompt
  SessionePrompt _sessione = const SessionePrompt(fraseIniziale: '');

  /// Indica se l'analisi della frase è in corso
  bool _staAnalizzando = false;

  /// Eventuale errore durante le chiamate API
  String? _errore;

  // -- Getter --

  SessionePrompt get sessione => _sessione;
  bool get staAnalizzando => _staAnalizzando;
  String? get errore => _errore;

  /// Restituisce la domanda corrente, o null se non ci sono domande
  Domanda? get domandaCorrente {
    if (_sessione.domande.isEmpty ||
        _sessione.domandaCorrente >= _sessione.domande.length) {
      return null;
    }
    return _sessione.domande[_sessione.domandaCorrente];
  }

  /// Verifica se siamo all'ultima domanda
  bool get isUltimaDomanda {
    return _sessione.domandaCorrente >= _sessione.domande.length - 1;
  }

  /// Verifica se si può tornare alla domanda precedente
  bool get puoTornareIndietro => _sessione.domandaCorrente > 0;

  // -- Azioni --

  /// Resetta l'errore
  void cancellaErrore() {
    _errore = null;
    notifyListeners();
  }

  /// Avvia una nuova sessione con la frase libera dell'utente.
  /// Chiama sempre l'AI (via proxy Cloudflare, che inietta la key di default);
  /// ricade sui dati fittizi solo se l'API fallisce.
  Future<void> avviaSessione(String fraseLibera) async {
    _sessione = SessionePrompt(fraseIniziale: fraseLibera);
    _staAnalizzando = true;
    _errore = null;
    notifyListeners();

    final api = ApiService();
    debugPrint('[Sessione] Avvio sessione — userKey: ${api.apiKeyConfigurata}');

    // STEP 1: Rileva la categoria con l'AI.
    // Si tenta SEMPRE la chiamata AI (via proxy con key di default).
    // Il fallback fittizio si attiva solo se l'API fallisce davvero.
    CategoriaRilevata categoria;
    bool categoriaViaAI = false;
    try {
      debugPrint('[Sessione] STEP 1: Analisi categoria via AI...');
      final json = await api.chiamaAIJson(
        systemPrompt: AiPrompts.analisiCategoria,
        messaggioUtente: fraseLibera,
        temperature: 0.3,
        maxTokens: 500,
      );
      debugPrint('[Sessione] STEP 1: Categoria ricevuta: ${json['categoria']}');
      categoria = CategoriaRilevata(
        nome: json['categoria'] as String? ?? 'Scrittura',
        icona: json['icona'] as String? ?? 'edit_note',
        riepilogo: json['riepilogo'] as String? ??
            'Vuoi creare un prompt personalizzato.',
        sottocategoria: json['sottocategoria'] as String?,
        elementiChiave: (json['elementiChiave'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            _estraiElementiChiave(fraseLibera),
      );
      categoriaViaAI = true;
    } on ApiException catch (e) {
      debugPrint('[Sessione] STEP 1: Errore API → ${e.messaggio}');
      _errore = e.messaggio;
      // Fallback ai dati fittizi in caso di errore
      categoria = _rilevaCategoria(fraseLibera);
    } catch (e, stack) {
      debugPrint('[Sessione] STEP 1: Eccezione inattesa → $e');
      debugPrint('[Sessione] STEP 1: Stack → $stack');
      _errore = 'Errore inatteso durante l\'analisi.';
      categoria = _rilevaCategoria(fraseLibera);
    }

    // STEP 2: Genera le domande con l'AI.
    // Ogni chiamata è indipendente: se la categoria ha fallito,
    // tenta comunque le domande (potrebbe essere un errore temporaneo).
    final numDomande = _sessione.numeroDomande;
    List<Domanda> domande;
    try {
      debugPrint('[Sessione] STEP 2: Generazione $numDomande domande via AI...');
      final json = await api.chiamaAIJson(
        systemPrompt: AiPrompts.generazioneDomande(numDomande),
        messaggioUtente: 'FRASE INIZIALE DELL\'UTENTE (leggi attentamente prima di generare domande):\n'
            '"$fraseLibera"\n\n'
            'Categoria rilevata: ${categoria.nome}\n'
            'Sottocategoria: ${categoria.sottocategoria ?? "N/A"}\n'
            'Elementi chiave già estratti: ${categoria.elementiChiave.join(", ")}\n\n'
            'Genera SOLO domande per informazioni NON presenti nella frase sopra.\n'
            'NUMERO DOMANDE RICHIESTO: $numDomande.',
        temperature: 0.6,
        maxTokens: 3000,
      );
      domande = _parsaDomande(json);
      debugPrint('[Sessione] STEP 2: ${domande.length} domande generate');
      // Se le domande sono arrivate via AI, azzera l'errore della categoria
      // (l'utente ha comunque un'esperienza funzionante)
      if (categoriaViaAI && _errore == null) {
        // tutto ok
      } else if (!categoriaViaAI && _errore != null) {
        debugPrint('[Sessione] Domande OK ma categoria fallback — mostro avviso');
      }
    } on ApiException catch (e) {
      debugPrint('[Sessione] STEP 2: Errore API → ${e.messaggio}');
      _errore ??= e.messaggio;
      domande = _generaDomandeFittizie(categoria.nome);
    } catch (e, stack) {
      debugPrint('[Sessione] STEP 2: Eccezione inattesa → $e');
      debugPrint('[Sessione] STEP 2: Stack → $stack');
      _errore ??= 'Errore inatteso durante la generazione delle domande.';
      domande = _generaDomandeFittizie(categoria.nome);
    }

    _sessione = _sessione.copyWith(
      categoria: categoria,
      domande: domande,
      percentualeCompletamento: 0.0,
    );
    _staAnalizzando = false;
    notifyListeners();
  }

  /// Imposta il numero di domande scelto dall'utente
  void impostaNumeroDomande(int numero) {
    _sessione = _sessione.copyWith(numeroDomande: numero);
    notifyListeners();
  }

  /// Conferma la categoria rilevata e passa alle domande
  void confermCategoria() {
    _sessione = _sessione.copyWith(
      percentualeCompletamento: 0.05,
    );
    notifyListeners();
  }

  /// Salva la risposta alla domanda corrente e passa alla successiva
  void rispondiDomanda(String risposta) {
    final nuoveRisposte = Map<String, String>.from(_sessione.risposte);
    final domanda = domandaCorrente;
    if (domanda == null) return;

    nuoveRisposte[domanda.id] = risposta;

    // Calcola la nuova percentuale di completamento
    final nuovoIndice = _sessione.domandaCorrente + 1;
    final percentuale = nuovoIndice / _sessione.domande.length;

    _sessione = _sessione.copyWith(
      risposte: nuoveRisposte,
      domandaCorrente: nuovoIndice,
      percentualeCompletamento: percentuale.clamp(0.0, 1.0),
    );
    notifyListeners();
  }

  /// Torna alla domanda precedente
  void domandaPrecedente() {
    if (!puoTornareIndietro) return;

    _sessione = _sessione.copyWith(
      domandaCorrente: _sessione.domandaCorrente - 1,
      percentualeCompletamento:
          ((_sessione.domandaCorrente - 1) / _sessione.domande.length)
              .clamp(0.0, 1.0),
    );
    notifyListeners();
  }

  /// Resetta la sessione per iniziarne una nuova
  void resetSessione() {
    _sessione = const SessionePrompt(fraseIniziale: '');
    _staAnalizzando = false;
    _errore = null;
    notifyListeners();
  }

  // -- Parsing risposta AI --

  /// Parsa le domande dalla risposta JSON dell'AI
  List<Domanda> _parsaDomande(Map<String, dynamic> json) {
    final listaDomande = json['domande'] as List<dynamic>? ?? [];
    if (listaDomande.isEmpty) return _generaDomandeFittizie('Scrittura');

    return listaDomande.map((d) {
      final mappa = d as Map<String, dynamic>;
      return Domanda(
        id: mappa['id'] as String? ?? 'q_${listaDomande.indexOf(d)}',
        testo: mappa['testo'] as String? ?? 'Domanda',
        tipoInput: _parsaTipoInput(mappa['tipoInput'] as String?),
        opzioni: (mappa['opzioni'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        placeholder: mappa['placeholder'] as String?,
        valoreDefault: mappa['valoreDefault'] as String?,
      );
    }).toList();
  }

  /// Converte la stringa del tipo input nel enum
  TipoInput _parsaTipoInput(String? tipo) {
    switch (tipo) {
      case 'testoLibero':
        return TipoInput.testoLibero;
      case 'bottoniOpzioni':
        return TipoInput.bottoniOpzioni;
      case 'chipMultipli':
        return TipoInput.chipMultipli;
      default:
        return TipoInput.testoLibero;
    }
  }

  // -- Metodi di fallback con dati fittizi --

  /// Rileva la categoria dalla frase (fallback senza AI)
  CategoriaRilevata _rilevaCategoria(String frase) {
    final fraseLower = frase.toLowerCase();

    if (fraseLower.contains('codice') ||
        fraseLower.contains('programm') ||
        fraseLower.contains('funzione') ||
        fraseLower.contains('bug') ||
        fraseLower.contains('api') ||
        fraseLower.contains('code') ||
        fraseLower.contains('python') ||
        fraseLower.contains('javascript')) {
      return CategoriaRilevata(
        nome: 'Coding',
        icona: 'code',
        riepilogo:
            'Vuoi creare un prompt per assistenza nella programmazione.',
        sottocategoria: 'Sviluppo Software',
        elementiChiave: _estraiElementiChiave(frase),
      );
    }

    if (fraseLower.contains('immagine') ||
        fraseLower.contains('foto') ||
        fraseLower.contains('disegn') ||
        fraseLower.contains('illustr') ||
        fraseLower.contains('visual')) {
      return CategoriaRilevata(
        nome: 'Immagini',
        icona: 'image',
        riepilogo:
            'Vuoi creare un prompt per generare immagini o contenuti visivi.',
        sottocategoria: 'Generazione Immagini',
        elementiChiave: _estraiElementiChiave(frase),
      );
    }

    if (fraseLower.contains('post') ||
        fraseLower.contains('linkedin') ||
        fraseLower.contains('social') ||
        fraseLower.contains('instagram') ||
        fraseLower.contains('twitter') ||
        fraseLower.contains('marketing')) {
      return CategoriaRilevata(
        nome: 'Scrittura',
        icona: 'edit_note',
        riepilogo:
            'Vuoi creare un prompt per scrivere contenuti per i social media.',
        sottocategoria: 'Social Media / Marketing',
        elementiChiave: _estraiElementiChiave(frase),
      );
    }

    if (fraseLower.contains('email') ||
        fraseLower.contains('mail') ||
        fraseLower.contains('lettera') ||
        fraseLower.contains('messaggio')) {
      return CategoriaRilevata(
        nome: 'Scrittura',
        icona: 'edit_note',
        riepilogo:
            'Vuoi creare un prompt per scrivere email o comunicazioni.',
        sottocategoria: 'Comunicazione',
        elementiChiave: _estraiElementiChiave(frase),
      );
    }

    return CategoriaRilevata(
      nome: 'Scrittura',
      icona: 'edit_note',
      riepilogo:
          'Vuoi creare un prompt per generare testo o contenuti scritti.',
      sottocategoria: 'Generale',
      elementiChiave: _estraiElementiChiave(frase),
    );
  }

  /// Estrae parole chiave dalla frase (fallback senza AI)
  List<String> _estraiElementiChiave(String frase) {
    final paroleComuni = {
      'voglio', 'vorrei', 'creare', 'fare', 'un', 'una', 'il', 'la', 'lo',
      'le', 'gli', 'di', 'a', 'da', 'in', 'con', 'su', 'per', 'tra', 'fra',
      'che', 'come', 'mi', 'ho', 'bisogno', 'aiutami', 'scrivi', 'genera',
      'crea', 'fammi', 'puoi', 'potresti', 'e', 'o', 'ma', 'non', 'del',
      'dei', 'delle', 'della', 'dello', 'al', 'alla', 'alle',
    };

    return frase
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((parola) =>
            parola.length > 2 && !paroleComuni.contains(parola))
        .take(5)
        .toList();
  }

  /// Genera domande fittizie (fallback senza AI)
  List<Domanda> _generaDomandeFittizie(String categoria) {
    switch (categoria) {
      case 'Coding':
        return const [
          Domanda(
            id: 'linguaggio',
            testo: 'In quale linguaggio di programmazione stai lavorando?',
            tipoInput: TipoInput.bottoniOpzioni,
            opzioni: ['Python', 'JavaScript', 'Dart/Flutter', 'Java', 'Altro'],
            valoreDefault: 'Python',
          ),
          Domanda(
            id: 'tipo_aiuto',
            testo: 'Che tipo di aiuto ti serve?',
            tipoInput: TipoInput.bottoniOpzioni,
            opzioni: [
              'Scrivere codice nuovo',
              'Correggere un bug',
              'Ottimizzare codice esistente',
              'Spiegare come funziona',
            ],
          ),
          Domanda(
            id: 'contesto',
            testo: 'Descrivi brevemente il contesto del tuo progetto.',
            tipoInput: TipoInput.testoLibero,
            placeholder:
                'Es. Sto costruendo un\'app web con React per gestire...',
          ),
          Domanda(
            id: 'livello_dettaglio',
            testo: 'Quanto dettagliata vuoi la risposta?',
            tipoInput: TipoInput.bottoniOpzioni,
            opzioni: [
              'Solo il codice',
              'Codice con commenti',
              'Spiegazione passo passo',
              'Tutorial completo',
            ],
            valoreDefault: 'Codice con commenti',
          ),
          Domanda(
            id: 'requisiti_extra',
            testo:
                'Ci sono requisiti specifici da rispettare? Seleziona tutti quelli applicabili.',
            tipoInput: TipoInput.chipMultipli,
            opzioni: [
              'Performance',
              'Sicurezza',
              'Test unitari',
              'Documentazione',
              'Compatibilità',
              'Semplicità',
            ],
          ),
        ];

      case 'Immagini':
        return const [
          Domanda(
            id: 'stile',
            testo: 'Quale stile visivo preferisci?',
            tipoInput: TipoInput.bottoniOpzioni,
            opzioni: [
              'Fotorealistico',
              'Illustrazione digitale',
              'Cartoon / Anime',
              'Arte astratta',
              'Minimalista',
            ],
          ),
          Domanda(
            id: 'soggetto',
            testo: 'Descrivi il soggetto principale dell\'immagine.',
            tipoInput: TipoInput.testoLibero,
            placeholder: 'Es. Un gatto che legge un libro in una libreria...',
          ),
          Domanda(
            id: 'atmosfera',
            testo: 'Che atmosfera vuoi comunicare?',
            tipoInput: TipoInput.chipMultipli,
            opzioni: [
              'Luminosa',
              'Cupa',
              'Romantica',
              'Futuristica',
              'Nostalgica',
              'Energetica',
            ],
          ),
          Domanda(
            id: 'colori',
            testo: 'Hai preferenze sui colori dominanti?',
            tipoInput: TipoInput.bottoniOpzioni,
            opzioni: [
              'Colori caldi',
              'Colori freddi',
              'Bianco e nero',
              'Pastello',
              'Nessuna preferenza',
            ],
            valoreDefault: 'Nessuna preferenza',
          ),
        ];

      default:
        return const [
          Domanda(
            id: 'tipo_contenuto',
            testo: 'Che tipo di contenuto vuoi creare?',
            tipoInput: TipoInput.bottoniOpzioni,
            opzioni: [
              'Post social media',
              'Email professionale',
              'Articolo / Blog',
              'Testo creativo',
              'Altro',
            ],
          ),
          Domanda(
            id: 'tono',
            testo: 'Quale tono vuoi usare?',
            tipoInput: TipoInput.bottoniOpzioni,
            opzioni: [
              'Formale',
              'Informale',
              'Ironico / Spiritoso',
              'Ispirazionale',
              'Tecnico',
            ],
            valoreDefault: 'Informale',
          ),
          Domanda(
            id: 'pubblico',
            testo:
                'A chi è rivolto il contenuto? Seleziona uno o più gruppi.',
            tipoInput: TipoInput.chipMultipli,
            opzioni: [
              'Professionisti',
              'Studenti',
              'Pubblico generico',
              'Manager',
              'Creativi',
              'Sviluppatori',
            ],
          ),
          Domanda(
            id: 'lunghezza',
            testo: 'Quanto lungo deve essere il risultato?',
            tipoInput: TipoInput.bottoniOpzioni,
            opzioni: [
              'Breve (1-2 paragrafi)',
              'Medio (3-5 paragrafi)',
              'Lungo (articolo completo)',
            ],
            valoreDefault: 'Medio (3-5 paragrafi)',
          ),
          Domanda(
            id: 'dettagli_extra',
            testo:
                'Ci sono dettagli specifici che vuoi includere nel contenuto?',
            tipoInput: TipoInput.testoLibero,
            placeholder:
                'Es. Menziona il lancio del prodotto, includi una call-to-action...',
          ),
        ];
    }
  }
}
