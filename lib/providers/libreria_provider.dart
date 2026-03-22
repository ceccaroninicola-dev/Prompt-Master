import 'package:flutter/material.dart';
import 'package:ideai/models/prompt_template.dart';
import 'package:ideai/models/prompt_generato.dart';

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
          titolo: 'Istruzione Email',
          icona: 'email',
          contenuto:
              'Scrivi un\'email professionale per un contesto lavorativo, con oggetto chiaro e specifico, saluto appropriato, introduzione diretta allo scopo, corpo del messaggio con i dettagli necessari, call-to-action chiara e chiusura professionale con firma. Usa un tono professionale ma accessibile e restituisci l\'email completa con oggetto separato, per una lunghezza di 150-250 parole. Mantieni frasi brevi e paragrafi di 2-3 frasi massimo, evitando gergo troppo tecnico e senza usare emoji.',
          colore: 0xFF7C3AED,
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
          titolo: 'Istruzione Social',
          icona: 'share',
          contenuto:
              'Crea un post LinkedIn di 150-200 parole che generi engagement e rafforzi il personal brand. Apri con un hook potente nella prima riga per catturare l\'attenzione, poi sviluppa una storia personale o un insight professionale. Includi 3-5 punti chiave con emoji come bullet point, una lezione o takeaway per il lettore, una call-to-action finale sotto forma di domanda al pubblico e 3-5 hashtag rilevanti. Usa paragrafi brevi di 1-2 frasi con spazi tra di essi per la leggibilità mobile, mantenendo un tono professionale ma autentico. Evita click-bait eccessivo, contenuti controversi e un uso esagerato delle emoji.',
          colore: 0xFF7C3AED,
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
          titolo: 'Istruzione Codice',
          icona: 'code',
          contenuto:
              'Scrivi una funzione Python 3.10+ production-ready con nome descrittivo in snake_case, type hints per parametri e return type, e una docstring completa in Google style. Gestisci i casi limite e gli errori, e includi 2-3 test unitari con pytest. Restituisci il codice in blocchi separati: prima la funzione, poi i test, aggiungendo commenti inline dove la logica non è ovvia. Segui le convenzioni PEP 8, preferisci le list comprehension ai loop dove possibile, ed evita dipendenze esterne e import inutili.',
          colore: 0xFF7C3AED,
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
          titolo: 'Descrizione Immagine',
          icona: 'image',
          contenuto:
              'Genera un\'immagine fotorealistica di alta qualità descrivendo il soggetto principale con dettagli specifici, l\'ambientazione e lo sfondo, il tipo di illuminazione (golden hour, studio, naturale), lo stile fotografico (ritratto, paesaggio, macro), i parametri tecnici (fotocamera, lente, apertura) e il mood o atmosfera desiderati. Scrivi il prompt in inglese su una riga continua, separando i concetti con virgole e includendo i parametri stilistici alla fine (--ar 16:9, --v 6, ecc.). Mantieni il testo entro 200 parole, evitando termini vaghi come "bello" o "carino" e contenuti inappropriati.',
          colore: 0xFF7C3AED,
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
          titolo: 'Istruzione Analisi',
          icona: 'analytics',
          contenuto:
              'Analizza il dataset fornito producendo un report strutturato con sezioni numerate che includa: una panoramica generale del dataset, le statistiche descrittive principali, l\'identificazione di trend e pattern, le anomalie o outlier rilevanti, 3-5 insight azionabili e raccomandazioni basate sui dati. Usa tabelle per i numeri chiave e includi suggerimenti per grafici da creare. Basa le conclusioni esclusivamente sui dati forniti, indica il livello di confidenza delle previsioni e non inventare numeri.',
          colore: 0xFF7C3AED,
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
          titolo: 'Istruzione Marketing',
          icona: 'campaign',
          contenuto:
              'Crea un piano marketing strutturato per il lancio di un prodotto o servizio, con obiettivi misurabili e un budget realistico per una startup/PMI. Includi: analisi del target (persona, bisogni, pain points), posizionamento e value proposition, canali di distribuzione organici e paid con focus sul digitale, un calendario editoriale per le prime 4 settimane, budget stimato per canale e KPI con metriche di successo. Presenta il tutto in un documento con sezioni chiare, tabelle per budget e KPI, e bullet point per le azioni concrete. Prioritizza azioni a basso costo e alto impatto.',
          colore: 0xFF7C3AED,
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
          titolo: 'Istruzione Studio',
          icona: 'school',
          contenuto:
              'Crea un riassunto strutturato del testo fornito per la preparazione di un esame, utilizzando tecniche di apprendimento efficace come mappe mentali e metodo Cornell. Includi: una mappa dei concetti principali (max 5-7), definizioni chiave in formato "termine: spiegazione semplice", relazioni causa-effetto tra i concetti, esempi pratici per ogni concetto astratto, 10 domande di autoverifica e mnemotecniche per i punti più difficili. Organizza gli appunti con titoli, sottotitoli e bullet point, usando il grassetto per i termini chiave, in massimo 500 parole. Usa un linguaggio semplice e diretto, non omettere concetti fondamentali per brevità e segnala eventuali ambiguità nel testo.',
          colore: 0xFF7C3AED,
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
          titolo: 'Istruzione Email',
          icona: 'email',
          contenuto:
              'Scrivi una newsletter settimanale/mensile ottimizzata per massimizzare aperture e click-through, seguendo questa struttura: oggetto irresistibile con 2 opzioni A/B, preview text accattivante, saluto personalizzato, hook iniziale con una storia o dato sorprendente, contenuto principale con valore concreto, e CTA primaria e secondaria. Restituisci l\'email completa pronta per l\'invio in 300-500 parole con paragrafi brevi di 2-3 frasi, includendo suggerimenti per immagini o GIF. Evita spam trigger words nell\'oggetto, rispetta il GDPR e includi sempre il link di disiscrizione nel footer.',
          colore: 0xFF7C3AED,
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
          titolo: 'Istruzione Social',
          icona: 'share',
          contenuto:
              'Crea una caption Instagram che massimizzi l\'engagement (like, commenti, salvataggi) con: una prima riga hook che cattura l\'attenzione, una microstoria o riflessione personale di 3-4 righe, valore concreto per il follower (tip, insight o ispirazione), una CTA conversazionale sotto forma di domanda per stimolare i commenti, e un blocco di 20-30 hashtag divisi per tier (5 grandi, 10 medi, 15 piccoli) da inserire in un commento separato. Restituisci la caption pronta per il copia-incolla con interruzioni di riga per la leggibilità, in massimo 2200 caratteri. Non abusare delle emoji e usa solo hashtag pertinenti alla nicchia, evitando quelli generici come #love o #instagood.',
          colore: 0xFF7C3AED,
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
          titolo: 'Istruzione Codice',
          icona: 'code',
          contenuto:
              'Analizza il codice fornito per individuare e risolvere il bug seguendo un processo sistematico: identifica il comportamento atteso rispetto a quello reale, individua la root cause del problema, spiega perché il bug si verifica, fornisci la correzione con il codice aggiornato e suggerisci come prevenire bug simili in futuro, aggiungendo se possibile un test che copra il caso. Presenta il risultato con la struttura Diagnosi, Causa, Fix, Prevenzione, mostrando il codice prima e dopo il fix con commenti che evidenziano le modifiche. Modifica solo il minimo necessario senza riscrivere tutto il codice, spiega ogni modifica e chiedi il linguaggio se non specificato.',
          colore: 0xFF7C3AED,
        ),
      ],
    ),
  ];
}
