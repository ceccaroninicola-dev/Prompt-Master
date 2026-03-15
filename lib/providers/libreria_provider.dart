import 'package:flutter/material.dart';
import 'package:prompt_master/models/prompt_template.dart';
import 'package:prompt_master/models/prompt_generato.dart';

/// Provider per la gestione della libreria di template.
/// Contiene i template fittizi, la logica di ricerca e filtro per categoria.
class LibreriaProvider extends ChangeNotifier {
  /// Categoria selezionata per il filtro ("Tutti" = nessun filtro)
  String _categoriaSelezionata = 'Tutti';
  String get categoriaSelezionata => _categoriaSelezionata;

  /// Testo di ricerca corrente
  String _testoRicerca = '';
  String get testoRicerca => _testoRicerca;

  /// Lista completa delle categorie disponibili
  static const List<String> categorie = [
    'Tutti',
    'Marketing',
    'Coding',
    'Immagini',
    'Email',
    'Social Media',
    'Analisi',
    'Studio',
  ];

  /// Mappa icone per categoria
  static const Map<String, IconData> iconeCategorie = {
    'Tutti': Icons.apps,
    'Marketing': Icons.campaign_outlined,
    'Coding': Icons.code,
    'Immagini': Icons.image_outlined,
    'Email': Icons.email_outlined,
    'Social Media': Icons.share_outlined,
    'Analisi': Icons.analytics_outlined,
    'Studio': Icons.school_outlined,
  };

  /// Template filtrati in base a categoria e ricerca
  List<PromptTemplate> get templateFiltrati {
    var risultati = _templateFittizi;

    // Filtra per categoria
    if (_categoriaSelezionata != 'Tutti') {
      risultati = risultati
          .where((t) => t.categoria == _categoriaSelezionata)
          .toList();
    }

    // Filtra per testo di ricerca
    if (_testoRicerca.isNotEmpty) {
      final query = _testoRicerca.toLowerCase();
      risultati = risultati.where((t) {
        return t.titolo.toLowerCase().contains(query) ||
            t.descrizione.toLowerCase().contains(query) ||
            t.tag.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    return risultati;
  }

  /// Template più popolari (top 4 per popolarità)
  List<PromptTemplate> get piuPopolari {
    final ordinati = List<PromptTemplate>.from(_templateFittizi)
      ..sort((a, b) => b.popolarita.compareTo(a.popolarita));
    return ordinati.take(4).toList();
  }

  /// Cambia la categoria selezionata
  void selezionaCategoria(String categoria) {
    _categoriaSelezionata = categoria;
    notifyListeners();
  }

  /// Aggiorna il testo di ricerca
  void cercaTemplate(String testo) {
    _testoRicerca = testo;
    notifyListeners();
  }

  /// Resetta tutti i filtri
  void resetFiltri() {
    _categoriaSelezionata = 'Tutti';
    _testoRicerca = '';
    notifyListeners();
  }

  // =====================================================
  // DATI FITTIZI — 10 template di esempio
  // =====================================================

  final List<PromptTemplate> _templateFittizi = const [
    // 1. Email professionale
    PromptTemplate(
      id: 'tpl_email_pro',
      titolo: 'Email professionale',
      descrizione: 'Scrivi email formali e convincenti per il lavoro',
      categoria: 'Email',
      icona: 'email',
      popolarita: 4.7,
      utilizzi: 1243,
      tag: ['email', 'lavoro', 'formale', 'business'],
      sezioni: [
        SezionePrompt(
          titolo: 'Ruolo',
          icona: 'person',
          contenuto:
              'Sei un esperto di comunicazione aziendale con anni di esperienza nella redazione di email professionali efficaci.',
          colore: 0xFF2196F3,
        ),
        SezionePrompt(
          titolo: 'Contesto',
          icona: 'info',
          contenuto:
              'L\'utente deve scrivere un\'email professionale per un contesto lavorativo. L\'email deve essere chiara, concisa e appropriata al tono aziendale.',
          colore: 0xFF4CAF50,
        ),
        SezionePrompt(
          titolo: 'Istruzioni',
          icona: 'list',
          contenuto:
              'Scrivi un\'email professionale seguendo questa struttura:\n1. Oggetto chiaro e specifico\n2. Saluto appropriato\n3. Introduzione diretta allo scopo\n4. Corpo del messaggio con i dettagli\n5. Call-to-action chiara\n6. Chiusura professionale con firma',
          colore: 0xFFFF9800,
        ),
        SezionePrompt(
          titolo: 'Formato Output',
          icona: 'format_align_left',
          contenuto:
              'Restituisci l\'email completa con oggetto separato. Usa un tono professionale ma accessibile. Lunghezza: 150-250 parole.',
          colore: 0xFF9C27B0,
        ),
        SezionePrompt(
          titolo: 'Vincoli',
          icona: 'block',
          contenuto:
              'Evita gergo troppo tecnico. Non usare emoji. Mantieni frasi brevi e paragrafi di 2-3 frasi massimo.',
          colore: 0xFFF44336,
        ),
      ],
    ),

    // 2. Post LinkedIn
    PromptTemplate(
      id: 'tpl_linkedin',
      titolo: 'Post LinkedIn virale',
      descrizione: 'Crea post coinvolgenti per LinkedIn con hook e CTA',
      categoria: 'Social Media',
      icona: 'share',
      popolarita: 4.8,
      utilizzi: 2105,
      tag: ['linkedin', 'social', 'networking', 'virale'],
      sezioni: [
        SezionePrompt(
          titolo: 'Ruolo',
          icona: 'person',
          contenuto:
              'Sei un social media strategist specializzato in LinkedIn con un track record di post virali nel settore professionale.',
          colore: 0xFF2196F3,
        ),
        SezionePrompt(
          titolo: 'Contesto',
          icona: 'info',
          contenuto:
              'L\'utente vuole pubblicare un post su LinkedIn che generi engagement (like, commenti, condivisioni) e rafforzi il proprio personal brand.',
          colore: 0xFF4CAF50,
        ),
        SezionePrompt(
          titolo: 'Istruzioni',
          icona: 'list',
          contenuto:
              'Crea un post LinkedIn seguendo la struttura:\n1. Hook potente nella prima riga (cattura l\'attenzione)\n2. Storia personale o insight professionale\n3. 3-5 punti chiave con emoji come bullet point\n4. Lezione o takeaway per il lettore\n5. Call-to-action finale (domanda al pubblico)\n6. 3-5 hashtag rilevanti',
          colore: 0xFFFF9800,
        ),
        SezionePrompt(
          titolo: 'Formato Output',
          icona: 'format_align_left',
          contenuto:
              'Post di 150-200 parole. Usa paragrafi brevi (1-2 frasi). Lascia spazi tra i paragrafi per leggibilità mobile. Tono: professionale ma autentico.',
          colore: 0xFF9C27B0,
        ),
        SezionePrompt(
          titolo: 'Vincoli',
          icona: 'block',
          contenuto:
              'No click-bait eccessivo. Non esagerare con le emoji. Evita contenuti controversi o polarizzanti.',
          colore: 0xFFF44336,
        ),
      ],
    ),

    // 3. Codice Python
    PromptTemplate(
      id: 'tpl_python',
      titolo: 'Funzione Python',
      descrizione: 'Genera codice Python pulito con docstring e test',
      categoria: 'Coding',
      icona: 'code',
      popolarita: 4.6,
      utilizzi: 1876,
      tag: ['python', 'codice', 'programmazione', 'funzione'],
      sezioni: [
        SezionePrompt(
          titolo: 'Ruolo',
          icona: 'person',
          contenuto:
              'Sei un senior Python developer con esperienza in clean code, design patterns e best practices PEP 8.',
          colore: 0xFF2196F3,
        ),
        SezionePrompt(
          titolo: 'Contesto',
          icona: 'info',
          contenuto:
              'L\'utente ha bisogno di una funzione Python ben strutturata, documentata e testata. Il codice deve essere production-ready.',
          colore: 0xFF4CAF50,
        ),
        SezionePrompt(
          titolo: 'Istruzioni',
          icona: 'list',
          contenuto:
              'Scrivi una funzione Python che:\n1. Abbia un nome descrittivo in snake_case\n2. Includa type hints per parametri e return type\n3. Abbia una docstring completa (Google style)\n4. Gestisca i casi limite e gli errori\n5. Includa 2-3 test unitari con pytest\n6. Segua le convenzioni PEP 8',
          colore: 0xFFFF9800,
        ),
        SezionePrompt(
          titolo: 'Formato Output',
          icona: 'format_align_left',
          contenuto:
              'Restituisci il codice in blocchi separati: prima la funzione, poi i test. Aggiungi commenti inline dove la logica non è ovvia.',
          colore: 0xFF9C27B0,
        ),
        SezionePrompt(
          titolo: 'Vincoli',
          icona: 'block',
          contenuto:
              'Python 3.10+. No dipendenze esterne se non richieste. Preferisci list comprehension a loop dove possibile. Nessun import inutile.',
          colore: 0xFFF44336,
        ),
      ],
    ),

    // 4. Immagine AI
    PromptTemplate(
      id: 'tpl_immagine_ai',
      titolo: 'Immagine AI fotorealistica',
      descrizione: 'Prompt per generare immagini fotorealistiche con AI',
      categoria: 'Immagini',
      icona: 'image',
      popolarita: 4.5,
      utilizzi: 1532,
      tag: ['immagine', 'midjourney', 'dall-e', 'fotorealismo'],
      sezioni: [
        SezionePrompt(
          titolo: 'Ruolo',
          icona: 'person',
          contenuto:
              'Sei un prompt engineer specializzato in generazione di immagini AI con Midjourney, DALL-E e Stable Diffusion.',
          colore: 0xFF2196F3,
        ),
        SezionePrompt(
          titolo: 'Contesto',
          icona: 'info',
          contenuto:
              'L\'utente vuole generare un\'immagine fotorealistica di alta qualità tramite un modello AI di generazione immagini.',
          colore: 0xFF4CAF50,
        ),
        SezionePrompt(
          titolo: 'Istruzioni',
          icona: 'list',
          contenuto:
              'Crea un prompt per immagine AI con questi elementi:\n1. Soggetto principale con dettagli specifici\n2. Ambientazione e sfondo\n3. Illuminazione (golden hour, studio, naturale)\n4. Stile fotografico (ritratto, paesaggio, macro)\n5. Parametri tecnici (fotocamera, lente, apertura)\n6. Mood e atmosfera',
          colore: 0xFFFF9800,
        ),
        SezionePrompt(
          titolo: 'Formato Output',
          icona: 'format_align_left',
          contenuto:
              'Prompt in inglese, una riga continua. Separa i concetti con virgole. Includi parametri stilistici alla fine (--ar 16:9, --v 6, ecc.).',
          colore: 0xFF9C27B0,
        ),
        SezionePrompt(
          titolo: 'Vincoli',
          icona: 'block',
          contenuto:
              'No contenuti inappropriati. Massimo 200 parole. Evita termini vaghi come "bello" o "carino" — sii specifico.',
          colore: 0xFFF44336,
        ),
      ],
    ),

    // 5. Analisi dati
    PromptTemplate(
      id: 'tpl_analisi_dati',
      titolo: 'Analisi dati con insight',
      descrizione: 'Analizza dataset e genera insight azionabili',
      categoria: 'Analisi',
      icona: 'analytics',
      popolarita: 4.3,
      utilizzi: 892,
      tag: ['analisi', 'dati', 'insight', 'business intelligence'],
      sezioni: [
        SezionePrompt(
          titolo: 'Ruolo',
          icona: 'person',
          contenuto:
              'Sei un data analyst senior con esperienza in business intelligence, visualizzazione dati e analisi predittiva.',
          colore: 0xFF2196F3,
        ),
        SezionePrompt(
          titolo: 'Contesto',
          icona: 'info',
          contenuto:
              'L\'utente ha un dataset e ha bisogno di un\'analisi approfondita con insight pratici per prendere decisioni di business.',
          colore: 0xFF4CAF50,
        ),
        SezionePrompt(
          titolo: 'Istruzioni',
          icona: 'list',
          contenuto:
              'Analizza i dati forniti seguendo questo approccio:\n1. Panoramica generale del dataset\n2. Statistiche descrittive principali\n3. Identificazione di trend e pattern\n4. Anomalie o outlier rilevanti\n5. 3-5 insight azionabili\n6. Raccomandazioni basate sui dati',
          colore: 0xFFFF9800,
        ),
        SezionePrompt(
          titolo: 'Formato Output',
          icona: 'format_align_left',
          contenuto:
              'Report strutturato con sezioni numerate. Usa tabelle per i numeri chiave. Includi suggerimenti per grafici da creare.',
          colore: 0xFF9C27B0,
        ),
        SezionePrompt(
          titolo: 'Vincoli',
          icona: 'block',
          contenuto:
              'Basa le conclusioni solo sui dati forniti. Indica il livello di confidenza delle previsioni. Non inventare numeri.',
          colore: 0xFFF44336,
        ),
      ],
    ),

    // 6. Piano di marketing
    PromptTemplate(
      id: 'tpl_marketing_plan',
      titolo: 'Piano marketing completo',
      descrizione: 'Strategia marketing con target, canali e KPI',
      categoria: 'Marketing',
      icona: 'campaign',
      popolarita: 4.4,
      utilizzi: 1067,
      tag: ['marketing', 'strategia', 'piano', 'kpi'],
      sezioni: [
        SezionePrompt(
          titolo: 'Ruolo',
          icona: 'person',
          contenuto:
              'Sei un marketing strategist con 10+ anni di esperienza in digital marketing, growth hacking e brand positioning.',
          colore: 0xFF2196F3,
        ),
        SezionePrompt(
          titolo: 'Contesto',
          icona: 'info',
          contenuto:
              'L\'utente sta lanciando un prodotto/servizio e ha bisogno di un piano marketing strutturato con obiettivi misurabili.',
          colore: 0xFF4CAF50,
        ),
        SezionePrompt(
          titolo: 'Istruzioni',
          icona: 'list',
          contenuto:
              'Crea un piano marketing che includa:\n1. Analisi del target (persona, bisogni, pain points)\n2. Posizionamento e value proposition\n3. Canali di distribuzione (organico e paid)\n4. Calendario editoriale (prime 4 settimane)\n5. Budget stimato per canale\n6. KPI e metriche di successo',
          colore: 0xFFFF9800,
        ),
        SezionePrompt(
          titolo: 'Formato Output',
          icona: 'format_align_left',
          contenuto:
              'Documento strutturato con sezioni chiare. Includi tabelle per budget e KPI. Usa bullet point per le azioni concrete.',
          colore: 0xFF9C27B0,
        ),
        SezionePrompt(
          titolo: 'Vincoli',
          icona: 'block',
          contenuto:
              'Budget realistico per una startup/PMI. Focus su canali digitali. Prioritizza azioni a basso costo e alto impatto.',
          colore: 0xFFF44336,
        ),
      ],
    ),

    // 7. Riassunto studio
    PromptTemplate(
      id: 'tpl_studio_riassunto',
      titolo: 'Riassunto per lo studio',
      descrizione: 'Sintetizza testi complessi in appunti chiari e mnemonici',
      categoria: 'Studio',
      icona: 'school',
      popolarita: 4.2,
      utilizzi: 756,
      tag: ['studio', 'riassunto', 'appunti', 'università'],
      sezioni: [
        SezionePrompt(
          titolo: 'Ruolo',
          icona: 'person',
          contenuto:
              'Sei un tutor universitario esperto in tecniche di apprendimento efficace, mappe mentali e metodo Cornell.',
          colore: 0xFF2196F3,
        ),
        SezionePrompt(
          titolo: 'Contesto',
          icona: 'info',
          contenuto:
              'Lo studente deve preparare un esame e ha bisogno di un riassunto efficace di un testo lungo, con concetti chiave evidenziati.',
          colore: 0xFF4CAF50,
        ),
        SezionePrompt(
          titolo: 'Istruzioni',
          icona: 'list',
          contenuto:
              'Crea un riassunto strutturato del testo seguendo questo schema:\n1. Mappa dei concetti principali (max 5-7)\n2. Definizioni chiave in formato "termine: spiegazione semplice"\n3. Relazioni causa-effetto tra i concetti\n4. Esempi pratici per ogni concetto astratto\n5. 10 domande di autoverifica\n6. Mnemotecnica per i punti più difficili',
          colore: 0xFFFF9800,
        ),
        SezionePrompt(
          titolo: 'Formato Output',
          icona: 'format_align_left',
          contenuto:
              'Appunti visivamente organizzati con titoli, sottotitoli e bullet point. Usa grassetto per i termini chiave. Max 500 parole.',
          colore: 0xFF9C27B0,
        ),
        SezionePrompt(
          titolo: 'Vincoli',
          icona: 'block',
          contenuto:
              'Linguaggio semplice e diretto. Non omettere concetti fondamentali per brevità. Segnala se il testo è ambiguo.',
          colore: 0xFFF44336,
        ),
      ],
    ),

    // 8. Newsletter email
    PromptTemplate(
      id: 'tpl_newsletter',
      titolo: 'Newsletter coinvolgente',
      descrizione: 'Scrivi newsletter che vengono aperte e lette fino in fondo',
      categoria: 'Email',
      icona: 'email',
      popolarita: 4.1,
      utilizzi: 634,
      tag: ['newsletter', 'email marketing', 'engagement'],
      sezioni: [
        SezionePrompt(
          titolo: 'Ruolo',
          icona: 'person',
          contenuto:
              'Sei un copywriter specializzato in email marketing con un tasso di apertura medio del 35% e un click-through rate del 12%.',
          colore: 0xFF2196F3,
        ),
        SezionePrompt(
          titolo: 'Contesto',
          icona: 'info',
          contenuto:
              'L\'utente invia una newsletter settimanale/mensile e vuole aumentare l\'engagement dei lettori con contenuti di valore.',
          colore: 0xFF4CAF50,
        ),
        SezionePrompt(
          titolo: 'Istruzioni',
          icona: 'list',
          contenuto:
              'Scrivi una newsletter seguendo questa struttura:\n1. Oggetto irresistibile (A/B: 2 opzioni)\n2. Preview text accattivante\n3. Saluto personalizzato\n4. Hook iniziale (storia o dato sorprendente)\n5. Contenuto principale con valore concreto\n6. CTA primaria e secondaria',
          colore: 0xFFFF9800,
        ),
        SezionePrompt(
          titolo: 'Formato Output',
          icona: 'format_align_left',
          contenuto:
              'Email completa pronta per l\'invio. 300-500 parole. Paragrafi brevi (2-3 frasi). Include suggerimenti per immagini/GIF.',
          colore: 0xFF9C27B0,
        ),
        SezionePrompt(
          titolo: 'Vincoli',
          icona: 'block',
          contenuto:
              'No spam trigger words nell\'oggetto. Rispetta il GDPR. Includi sempre il link di disiscrizione nel footer.',
          colore: 0xFFF44336,
        ),
      ],
    ),

    // 9. Post Instagram
    PromptTemplate(
      id: 'tpl_instagram',
      titolo: 'Caption Instagram',
      descrizione: 'Caption creativi con hashtag mirati per Instagram',
      categoria: 'Social Media',
      icona: 'share',
      popolarita: 4.4,
      utilizzi: 1389,
      tag: ['instagram', 'caption', 'hashtag', 'social'],
      sezioni: [
        SezionePrompt(
          titolo: 'Ruolo',
          icona: 'person',
          contenuto:
              'Sei un content creator Instagram con 100K+ follower, esperto in storytelling visivo e crescita organica.',
          colore: 0xFF2196F3,
        ),
        SezionePrompt(
          titolo: 'Contesto',
          icona: 'info',
          contenuto:
              'L\'utente deve pubblicare un post Instagram e vuole una caption che massimizzi l\'engagement (like, commenti, salvataggi).',
          colore: 0xFF4CAF50,
        ),
        SezionePrompt(
          titolo: 'Istruzioni',
          icona: 'list',
          contenuto:
              'Crea una caption Instagram con:\n1. Prima riga che cattura (hook o emoji potente)\n2. Microstoria o riflessione personale (3-4 righe)\n3. Valore per il follower (tip, insight, ispirazione)\n4. CTA conversazionale (domanda per i commenti)\n5. Blocco di 20-30 hashtag divisi per tier (5 grandi, 10 medi, 15 piccoli)',
          colore: 0xFFFF9800,
        ),
        SezionePrompt(
          titolo: 'Formato Output',
          icona: 'format_align_left',
          contenuto:
              'Caption pronta per il copia-incolla. Usa interruzioni di riga per la leggibilità. Hashtag in un commento separato.',
          colore: 0xFF9C27B0,
        ),
        SezionePrompt(
          titolo: 'Vincoli',
          icona: 'block',
          contenuto:
              'Max 2200 caratteri. Non abusare delle emoji. Hashtag pertinenti alla nicchia, non generici (#love, #instagood).',
          colore: 0xFFF44336,
        ),
      ],
    ),

    // 10. Debug codice
    PromptTemplate(
      id: 'tpl_debug',
      titolo: 'Debug e risoluzione bug',
      descrizione: 'Trova e correggi bug nel tuo codice con spiegazione',
      categoria: 'Coding',
      icona: 'code',
      popolarita: 4.5,
      utilizzi: 1654,
      tag: ['debug', 'bug', 'fix', 'errore', 'codice'],
      sezioni: [
        SezionePrompt(
          titolo: 'Ruolo',
          icona: 'person',
          contenuto:
              'Sei un senior software engineer esperto in debugging, code review e problem solving. Lavori con molteplici linguaggi e framework.',
          colore: 0xFF2196F3,
        ),
        SezionePrompt(
          titolo: 'Contesto',
          icona: 'info',
          contenuto:
              'L\'utente ha un bug nel codice e non riesce a trovarne la causa. Ha bisogno di un\'analisi sistematica del problema.',
          colore: 0xFF4CAF50,
        ),
        SezionePrompt(
          titolo: 'Istruzioni',
          icona: 'list',
          contenuto:
              'Analizza il codice seguendo questo processo:\n1. Leggi il codice e identifica il comportamento atteso vs quello reale\n2. Individua la root cause del bug\n3. Spiega PERCHÉ il bug si verifica\n4. Fornisci la correzione con il codice aggiornato\n5. Suggerisci come prevenire bug simili in futuro\n6. Se possibile, aggiungi un test che copra il caso',
          colore: 0xFFFF9800,
        ),
        SezionePrompt(
          titolo: 'Formato Output',
          icona: 'format_align_left',
          contenuto:
              'Struttura: Diagnosi → Causa → Fix → Prevenzione. Mostra il codice prima e dopo il fix con commenti che evidenziano le modifiche.',
          colore: 0xFF9C27B0,
        ),
        SezionePrompt(
          titolo: 'Vincoli',
          icona: 'block',
          contenuto:
              'Non riscrivere tutto il codice — modifica solo il minimo necessario. Spiega ogni modifica. Non assumere il linguaggio, chiedi se non specificato.',
          colore: 0xFFF44336,
        ),
      ],
    ),
  ];
}
