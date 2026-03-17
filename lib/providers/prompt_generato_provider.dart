import 'package:flutter/material.dart';
import 'package:prompt_master/models/prompt_generato.dart';
import 'package:prompt_master/models/prompt_template.dart';
import 'package:prompt_master/services/api_service.dart';
import 'package:prompt_master/services/ai_prompts.dart';

/// Provider per la gestione del prompt generato.
/// Usa GPT-4o-mini per la generazione, con fallback ai dati fittizi.
class PromptGeneratoProvider extends ChangeNotifier {
  /// Il prompt generato corrente
  PromptGenerato? _prompt;

  /// Indica se la generazione è in corso
  bool _staGenerando = false;

  /// Eventuale errore durante la generazione
  String? _errore;

  /// Prompt ottimizzato per un'AI specifica (cache)
  String? _promptOttimizzato;

  /// AI per cui è stato ottimizzato il prompt
  String? _aiOttimizzata;

  // -- Getter --

  PromptGenerato? get prompt => _prompt;
  bool get staGenerando => _staGenerando;
  String? get errore => _errore;
  String? get promptOttimizzato => _promptOttimizzato;
  String? get aiOttimizzata => _aiOttimizzata;

  /// Genera un prompt a partire dalle risposte della sessione.
  /// Usa l'AI se disponibile, altrimenti crea dati fittizi.
  Future<void> generaPrompt({
    required String fraseIniziale,
    required String categoria,
    required Map<String, String> risposte,
  }) async {
    _staGenerando = true;
    _errore = null;
    _promptOttimizzato = null;
    _aiOttimizzata = null;
    notifyListeners();

    final api = ApiService();

    if (api.apiKeyConfigurata) {
      try {
        // Costruisci il messaggio con tutte le informazioni raccolte
        final messaggioUtente = _costruisciMessaggio(
            fraseIniziale, categoria, risposte);

        final json = await api.chiamaAIJson(
          systemPrompt: AiPrompts.generazionePrompt,
          messaggioUtente: messaggioUtente,
          temperature: 0.7,
          maxTokens: 3000,
        );

        _prompt = _parsaPromptDaJson(json);
      } on ApiException catch (e) {
        _errore = e.messaggio;
        // Fallback ai dati fittizi
        _prompt = _creaPromptFittizio(fraseIniziale, categoria, risposte);
      }
    } else {
      // Senza API key, usa i dati fittizi
      await Future.delayed(const Duration(milliseconds: 800));
      _prompt = _creaPromptFittizio(fraseIniziale, categoria, risposte);
    }

    _staGenerando = false;
    notifyListeners();
  }

  /// Ottimizza il prompt per un'AI di destinazione specifica.
  /// Restituisce il testo ottimizzato.
  Future<String?> ottimizzaPerAI(String nomeAI) async {
    if (_prompt == null) return null;

    // Se è già ottimizzato per la stessa AI, usa la cache
    if (_aiOttimizzata == nomeAI && _promptOttimizzato != null) {
      return _promptOttimizzato;
    }

    final api = ApiService();

    if (api.apiKeyConfigurata) {
      try {
        final risultato = await api.chiamaAI(
          systemPrompt: AiPrompts.ottimizzazionePerAI,
          messaggioUtente: 'AI di destinazione: $nomeAI\n\n'
              'Prompt originale:\n${_prompt!.testoCompleto}',
          temperature: 0.5,
          maxTokens: 2000,
        );
        _promptOttimizzato = risultato;
        _aiOttimizzata = nomeAI;
        notifyListeners();
        return risultato;
      } on ApiException {
        // Fallback: restituisci il prompt originale
        return _prompt!.testoCompleto;
      }
    }

    // Senza API key, restituisci il prompt originale
    return _prompt!.testoCompleto;
  }

  /// Aggiorna il contenuto di una sezione specifica
  void aggiornaSezione(int indice, String nuovoContenuto) {
    if (_prompt == null) return;
    _prompt = _prompt!.conSezioneAggiornata(indice, nuovoContenuto);
    _promptOttimizzato = null; // Invalida la cache
    _aiOttimizzata = null;
    _ricalcolaPunteggi();
    notifyListeners();
  }

  /// Applica un suggerimento di miglioramento
  void applicaSuggerimento(SuggerimentoMiglioramento suggerimento) {
    if (_prompt == null) return;

    _prompt = _prompt!.conSezioneAggiornata(
      suggerimento.sezioneIndice,
      suggerimento.testoDopo,
    );

    final nuoviSuggerimenti = List<SuggerimentoMiglioramento>.from(
      _prompt!.suggerimenti,
    )..removeWhere((s) => s.etichetta == suggerimento.etichetta);

    _prompt = _prompt!.conPunteggiAggiornati(
      suggerimenti: nuoviSuggerimenti,
    );
    _promptOttimizzato = null;
    _aiOttimizzata = null;
    _ricalcolaPunteggi();
    notifyListeners();
  }

  /// Carica un prompt da un template della libreria
  void caricaDaTemplate(PromptTemplate template) {
    _prompt = PromptGenerato(
      sezioni: template.sezioni,
      punteggioGlobale: template.popolarita,
      punteggiCriteri: {
        'Chiarezza': (template.popolarita * 0.95).clamp(0.0, 5.0),
        'Specificità': (template.popolarita * 0.90).clamp(0.0, 5.0),
        'Completezza': (template.popolarita * 0.92).clamp(0.0, 5.0),
        'Struttura': (template.popolarita * 0.98).clamp(0.0, 5.0),
        'Coerenza': (template.popolarita * 0.96).clamp(0.0, 5.0),
      },
      suggerimenti: const [],
    );
    _staGenerando = false;
    _promptOttimizzato = null;
    _aiOttimizzata = null;
    notifyListeners();
  }

  /// Carica un prompt già esistente (es. dalla cronologia)
  void caricaPrompt(PromptGenerato prompt) {
    _prompt = prompt;
    _staGenerando = false;
    _promptOttimizzato = null;
    _aiOttimizzata = null;
    notifyListeners();
  }

  /// Resetta il provider
  void reset() {
    _prompt = null;
    _staGenerando = false;
    _errore = null;
    _promptOttimizzato = null;
    _aiOttimizzata = null;
    notifyListeners();
  }

  // -- Metodi privati --

  /// Costruisce il messaggio per l'AI con tutte le informazioni raccolte
  String _costruisciMessaggio(
    String fraseIniziale,
    String categoria,
    Map<String, String> risposte,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('Categoria: $categoria');
    buffer.writeln('Frase iniziale dell\'utente: "$fraseIniziale"');
    buffer.writeln('');
    buffer.writeln('Risposte alle domande:');
    risposte.forEach((domanda, risposta) {
      buffer.writeln('- $domanda: $risposta');
    });
    return buffer.toString();
  }

  /// Parsa il prompt dalla risposta JSON dell'AI
  PromptGenerato _parsaPromptDaJson(Map<String, dynamic> json) {
    // Parsa le sezioni
    final sezioniJson = json['sezioni'] as List<dynamic>? ?? [];
    final sezioni = sezioniJson.map((s) {
      final mappa = s as Map<String, dynamic>;
      return SezionePrompt(
        titolo: mappa['titolo'] as String? ?? 'Sezione',
        icona: mappa['icona'] as String? ?? 'article',
        contenuto: mappa['contenuto'] as String? ?? '',
        colore: (mappa['colore'] as num?)?.toInt() ?? 0xFF009688,
      );
    }).toList();

    // Se non ci sono sezioni, usa fallback
    if (sezioni.isEmpty) {
      return _creaPromptFittizio('', 'Scrittura', {});
    }

    // Parsa i punteggi
    final punteggioGlobale =
        (json['punteggioGlobale'] as num?)?.toDouble() ?? 4.0;
    final punteggiCriteriJson =
        json['punteggiCriteri'] as Map<String, dynamic>? ?? {};
    final punteggiCriteri = punteggiCriteriJson.map(
        (k, v) => MapEntry(k, (v as num).toDouble()));

    // Parsa i suggerimenti
    final suggerimentiJson = json['suggerimenti'] as List<dynamic>? ?? [];
    final suggerimenti = suggerimentiJson.map((s) {
      final mappa = s as Map<String, dynamic>;
      return SuggerimentoMiglioramento(
        etichetta: mappa['etichetta'] as String? ?? 'Suggerimento',
        icona: mappa['icona'] as String? ?? 'lightbulb',
        sezioneIndice: (mappa['sezioneIndice'] as num?)?.toInt() ?? 0,
        testoPrima: mappa['testoPrima'] as String? ?? '',
        testoDopo: mappa['testoDopo'] as String? ?? '',
        descrizione: mappa['descrizione'] as String? ?? '',
      );
    }).toList();

    return PromptGenerato(
      sezioni: sezioni,
      punteggioGlobale: punteggioGlobale,
      punteggiCriteri: punteggiCriteri,
      suggerimenti: suggerimenti,
    );
  }

  /// Ricalcola i punteggi dopo una modifica (simulato)
  void _ricalcolaPunteggi() {
    if (_prompt == null) return;

    final lunghezzaTotale = _prompt!.sezioni
        .fold<int>(0, (sum, s) => sum + s.contenuto.length);

    final fattore = (lunghezzaTotale / 800).clamp(0.5, 1.0);
    final base = 3.5;

    _prompt = _prompt!.conPunteggiAggiornati(
      punteggioGlobale: double.parse(
        (base + (1.5 * fattore)).toStringAsFixed(1),
      ),
      punteggiCriteri: {
        'Chiarezza': double.parse(
            (3.8 + (1.2 * fattore)).clamp(0.0, 5.0).toStringAsFixed(1)),
        'Specificità': double.parse(
            (3.2 + (1.5 * fattore)).clamp(0.0, 5.0).toStringAsFixed(1)),
        'Completezza': double.parse(
            (3.5 + (1.3 * fattore)).clamp(0.0, 5.0).toStringAsFixed(1)),
        'Struttura': double.parse(
            (4.0 + (0.8 * fattore)).clamp(0.0, 5.0).toStringAsFixed(1)),
        'Coerenza': double.parse(
            (3.9 + (1.0 * fattore)).clamp(0.0, 5.0).toStringAsFixed(1)),
      },
    );
  }

  /// Crea un prompt fittizio (fallback senza AI)
  PromptGenerato _creaPromptFittizio(
    String fraseIniziale,
    String categoria,
    Map<String, String> risposte,
  ) {
    final sezioni = _generaSezioni(categoria, risposte);

    return PromptGenerato(
      sezioni: sezioni,
      punteggioGlobale: 4.2,
      punteggiCriteri: const {
        'Chiarezza': 4.5,
        'Specificità': 3.8,
        'Completezza': 4.0,
        'Struttura': 4.6,
        'Coerenza': 4.3,
      },
      suggerimenti: _generaSuggerimenti(sezioni),
    );
  }

  /// Genera le sezioni del prompt in base alla categoria (fallback)
  List<SezionePrompt> _generaSezioni(
    String categoria,
    Map<String, String> risposte,
  ) {
    switch (categoria) {
      case 'Coding':
        final linguaggio = risposte['linguaggio'] ?? 'Python';
        final tipoAiuto = risposte['tipo_aiuto'] ?? 'Scrivere codice nuovo';
        return [
          SezionePrompt(
            titolo: 'Ruolo',
            icona: 'person',
            contenuto:
                'Sei un esperto sviluppatore $linguaggio con oltre 10 anni di esperienza. '
                'Scrivi codice pulito, ben documentato e seguendo le best practices.',
            colore: 0xFF0D9488,
          ),
          SezionePrompt(
            titolo: 'Contesto',
            icona: 'info',
            contenuto:
                'L\'utente ha bisogno di aiuto per: $tipoAiuto. '
                '${risposte['contesto'] ?? 'Il progetto è in fase di sviluppo.'}',
            colore: 0xFF0891B2,
          ),
          SezionePrompt(
            titolo: 'Istruzioni',
            icona: 'list',
            contenuto:
                '1. Analizza attentamente la richiesta\n'
                '2. Scrivi il codice $linguaggio richiesto\n'
                '3. Aggiungi commenti esplicativi nel codice\n'
                '4. Gestisci i casi limite e gli errori\n'
                '5. Segui le convenzioni di naming del linguaggio',
            colore: 0xFF7C3AED,
          ),
          SezionePrompt(
            titolo: 'Formato Output',
            icona: 'format_align_left',
            contenuto:
                'Fornisci il codice in un blocco formattato. '
                '${risposte['livello_dettaglio'] ?? 'Includi commenti esplicativi.'} '
                'Se necessario, aggiungi note sulle dipendenze richieste.',
            colore: 0xFFEA580C,
          ),
          SezionePrompt(
            titolo: 'Vincoli',
            icona: 'block',
            contenuto:
                'Requisiti: ${risposte['requisiti_extra'] ?? 'Performance, Sicurezza'}. '
                'Non usare librerie deprecate. '
                'Assicurati che il codice sia compatibile con le versioni recenti di $linguaggio.',
            colore: 0xFFDC2626,
          ),
          const SezionePrompt(
            titolo: 'Esempi',
            icona: 'lightbulb',
            contenuto:
                'Se la richiesta è ambigua, fornisci prima un esempio semplice '
                'e poi una versione più avanzata.',
            colore: 0xFFF59E0B,
          ),
        ];

      case 'Immagini':
        final stile = risposte['stile'] ?? 'Fotorealistico';
        return [
          SezionePrompt(
            titolo: 'Ruolo',
            icona: 'person',
            contenuto:
                'Sei un art director esperto nella creazione di prompt per immagini AI. '
                'Conosci le tecniche di composizione, illuminazione e stile visivo.',
            colore: 0xFF0D9488,
          ),
          SezionePrompt(
            titolo: 'Contesto',
            icona: 'info',
            contenuto:
                'L\'utente vuole generare un\'immagine in stile $stile. '
                '${risposte['soggetto'] ?? 'Il soggetto verrà specificato.'}',
            colore: 0xFF0891B2,
          ),
          SezionePrompt(
            titolo: 'Istruzioni',
            icona: 'list',
            contenuto:
                '1. Descrivi il soggetto principale con dettagli precisi\n'
                '2. Specifica lo stile artistico: $stile\n'
                '3. Indica l\'illuminazione e l\'atmosfera desiderata\n'
                '4. Aggiungi dettagli sulla composizione e l\'inquadratura',
            colore: 0xFF7C3AED,
          ),
          SezionePrompt(
            titolo: 'Formato Output',
            icona: 'format_align_left',
            contenuto:
                'Formato immagine: 16:9 landscape. '
                'Risoluzione alta. Atmosfera: ${risposte['atmosfera'] ?? 'Luminosa'}.',
            colore: 0xFFEA580C,
          ),
          SezionePrompt(
            titolo: 'Vincoli',
            icona: 'block',
            contenuto:
                'Colori dominanti: ${risposte['colori'] ?? 'Nessuna preferenza'}. '
                'Evita elementi testuali nell\'immagine. '
                'Mantieni uno stile coerente e professionale.',
            colore: 0xFFDC2626,
          ),
          const SezionePrompt(
            titolo: 'Esempi',
            icona: 'lightbulb',
            contenuto: '',
            colore: 0xFFF59E0B,
          ),
        ];

      default:
        final tono = risposte['tono'] ?? 'Informale';
        final tipo = risposte['tipo_contenuto'] ?? 'Post social media';
        return [
          SezionePrompt(
            titolo: 'Ruolo',
            icona: 'person',
            contenuto:
                'Sei un copywriter professionista specializzato in $tipo. '
                'Hai esperienza nella creazione di contenuti coinvolgenti e persuasivi.',
            colore: 0xFF0D9488,
          ),
          SezionePrompt(
            titolo: 'Contesto',
            icona: 'info',
            contenuto:
                'L\'utente vuole creare un $tipo con tono $tono. '
                'Il pubblico target è: ${risposte['pubblico'] ?? 'Professionisti'}.',
            colore: 0xFF0891B2,
          ),
          SezionePrompt(
            titolo: 'Istruzioni',
            icona: 'list',
            contenuto:
                '1. Scrivi un $tipo con tono $tono\n'
                '2. Adatta il linguaggio al pubblico target\n'
                '3. Includi un hook iniziale che catturi l\'attenzione\n'
                '4. Concludi con una call-to-action efficace\n'
                '5. Usa formattazione adeguata al formato scelto',
            colore: 0xFF7C3AED,
          ),
          SezionePrompt(
            titolo: 'Formato Output',
            icona: 'format_align_left',
            contenuto:
                'Lunghezza: ${risposte['lunghezza'] ?? 'Medio (3-5 paragrafi)'}. '
                'Usa paragrafi brevi e punti elenco dove appropriato. '
                'Includi emoji solo se adatti al tono scelto.',
            colore: 0xFFEA580C,
          ),
          SezionePrompt(
            titolo: 'Vincoli',
            icona: 'block',
            contenuto:
                'Mantieni un tono $tono coerente in tutto il testo. '
                'Evita jargon tecnico non necessario. '
                'Il testo deve essere originale e non generico.',
            colore: 0xFFDC2626,
          ),
          SezionePrompt(
            titolo: 'Esempi',
            icona: 'lightbulb',
            contenuto:
                risposte['dettagli_extra'] ??
                'Nessun dettaglio aggiuntivo specificato.',
            colore: 0xFFF59E0B,
          ),
        ];
    }
  }

  /// Genera suggerimenti di miglioramento contestuali (fallback)
  List<SuggerimentoMiglioramento> _generaSuggerimenti(
    List<SezionePrompt> sezioni,
  ) {
    return [
      SuggerimentoMiglioramento(
        etichetta: 'Aggiungi esempio',
        icona: 'lightbulb',
        sezioneIndice: 5,
        testoPrima: sezioni[5].contenuto,
        testoDopo:
            '${sezioni[5].contenuto}\n\n'
            'Esempio di output atteso:\n'
            '- Versione breve e diretta per social media\n'
            '- Versione estesa per blog o newsletter',
        descrizione:
            'Aggiunge un esempio concreto di output atteso '
            'per guidare meglio l\'AI nella generazione.',
      ),
      SuggerimentoMiglioramento(
        etichetta: 'Specifica formato',
        icona: 'format_align_left',
        sezioneIndice: 3,
        testoPrima: sezioni[3].contenuto,
        testoDopo:
            '${sezioni[3].contenuto}\n'
            'Struttura il contenuto con: titolo, sottotitolo, '
            'corpo principale diviso in sezioni, conclusione con CTA.',
        descrizione:
            'Aggiunge dettagli sulla struttura '
            'del formato di output per risultati più precisi.',
      ),
      SuggerimentoMiglioramento(
        etichetta: 'Definisci tono',
        icona: 'record_voice_over',
        sezioneIndice: 0,
        testoPrima: sezioni[0].contenuto,
        testoDopo:
            '${sezioni[0].contenuto} '
            'Comunica con un tono autorevole ma accessibile, '
            'come un mentore che guida con competenza e empatia.',
        descrizione:
            'Definisce meglio la personalità e il tono '
            'di voce per una risposta più coerente.',
      ),
      SuggerimentoMiglioramento(
        etichetta: 'Aggiungi vincoli',
        icona: 'block',
        sezioneIndice: 4,
        testoPrima: sezioni[4].contenuto,
        testoDopo:
            '${sezioni[4].contenuto} '
            'Limita la risposta a massimo 500 parole. '
            'Non includere riferimenti a marchi specifici senza autorizzazione.',
        descrizione:
            'Aggiunge vincoli specifici per '
            'controllare meglio l\'output generato.',
      ),
    ];
  }
}
