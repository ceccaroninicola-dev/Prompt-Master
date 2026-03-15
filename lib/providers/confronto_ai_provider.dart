import 'package:flutter/material.dart';
import 'package:prompt_master/models/confronto_ai.dart';
import 'package:prompt_master/models/prompt_generato.dart';

/// Provider per la gestione del confronto multi-AI.
/// Gestisce la selezione delle AI, la simulazione delle risposte
/// e il calcolo della risposta migliore.
class ConfrontoAIProvider extends ChangeNotifier {
  /// Lista completa delle AI disponibili
  static final List<InfoAI> aiDisponibili = [
    const InfoAI(
      nome: 'ChatGPT',
      icona: Icons.chat_bubble_outline,
      colore: Color(0xFF10A37F),
      categorieForti: ['Scrittura', 'Marketing', 'Email', 'Social Media'],
    ),
    const InfoAI(
      nome: 'Claude',
      icona: Icons.auto_awesome,
      colore: Color(0xFFD97706),
      categorieForti: ['Coding', 'Analisi', 'Scrittura', 'Studio'],
    ),
    const InfoAI(
      nome: 'Gemini',
      icona: Icons.diamond_outlined,
      colore: Color(0xFF4285F4),
      categorieForti: ['Analisi', 'Studio', 'Immagini', 'Marketing'],
    ),
    const InfoAI(
      nome: 'Copilot',
      icona: Icons.computer,
      colore: Color(0xFF2B88D8),
      categorieForti: ['Coding', 'Analisi'],
    ),
    const InfoAI(
      nome: 'Mistral',
      icona: Icons.air,
      colore: Color(0xFFFF7000),
      categorieForti: ['Coding', 'Scrittura', 'Email'],
    ),
  ];

  /// AI selezionate dall'utente per il confronto
  final Set<String> _aiSelezionate = {};
  Set<String> get aiSelezionate => _aiSelezionate;

  /// Risultato del confronto
  ConfrontoAI? _confronto;
  ConfrontoAI? get confronto => _confronto;

  /// Stato di caricamento
  bool _staCaricando = false;
  bool get staCaricando => _staCaricando;

  /// Suggerisce le 2-3 AI migliori per la categoria del prompt
  List<InfoAI> suggerisciAI(String categoria) {
    // Filtra le AI che hanno la categoria tra le loro forze
    final suggerite = aiDisponibili
        .where((ai) => ai.categorieForti.contains(categoria))
        .take(3)
        .toList();

    // Se meno di 2 suggerimenti, aggiungi ChatGPT e Claude come default
    if (suggerite.length < 2) {
      for (final ai in aiDisponibili) {
        if (!suggerite.any((s) => s.nome == ai.nome)) {
          suggerite.add(ai);
          if (suggerite.length >= 2) break;
        }
      }
    }

    return suggerite;
  }

  /// Pre-seleziona le AI suggerite
  void preseleziona(List<InfoAI> suggerite) {
    _aiSelezionate.clear();
    for (final ai in suggerite) {
      _aiSelezionate.add(ai.nome);
    }
    notifyListeners();
  }

  /// Toggle selezione di un'AI
  void toggleAI(String nome) {
    if (_aiSelezionate.contains(nome)) {
      _aiSelezionate.remove(nome);
    } else {
      _aiSelezionate.add(nome);
    }
    notifyListeners();
  }

  /// Avvia il confronto: simula l'invio del prompt alle AI selezionate
  Future<void> avviaConfronto(PromptGenerato prompt, String categoria) async {
    _staCaricando = true;
    notifyListeners();

    // Simula il tempo di attesa delle API (1.5 secondi)
    await Future.delayed(const Duration(milliseconds: 1500));

    // Genera risposte fittizie per ogni AI selezionata
    final risposte = <RispostaAI>[];
    for (final nomeAi in _aiSelezionate) {
      final ai = aiDisponibili.firstWhere((a) => a.nome == nomeAi);
      risposte.add(_generaRispostaFittizia(ai, prompt, categoria));
    }

    // Determina la risposta migliore
    double punteggioMax = 0;
    int indiceMigliore = 0;
    for (var i = 0; i < risposte.length; i++) {
      if (risposte[i].punteggio > punteggioMax) {
        punteggioMax = risposte[i].punteggio;
        indiceMigliore = i;
      }
    }

    // Segna la risposta migliore
    final risposteFinali = risposte.asMap().entries.map((entry) {
      return entry.value.conMigliore(entry.key == indiceMigliore);
    }).toList();

    _confronto = ConfrontoAI(
      prompt: prompt,
      risposte: risposteFinali,
      dataConfronto: DateTime.now(),
    );

    _staCaricando = false;
    notifyListeners();
  }

  /// Resetta il confronto
  void reset() {
    _confronto = null;
    _aiSelezionate.clear();
    _staCaricando = false;
    notifyListeners();
  }

  // ===== GENERAZIONE RISPOSTE FITTIZIE =====

  /// Genera una risposta fittizia per una specifica AI
  RispostaAI _generaRispostaFittizia(
    InfoAI ai,
    PromptGenerato prompt,
    String categoria,
  ) {
    final risposta = _getRispostaPerAI(ai.nome, categoria);
    final punteggio = _getPunteggioPerAI(ai.nome, categoria);

    return RispostaAI(
      ai: ai,
      risposta: risposta,
      punteggio: punteggio,
      punteggiDettaglio: {
        'Pertinenza': (punteggio * 0.98).clamp(0.0, 5.0),
        'Completezza': (punteggio * 0.95).clamp(0.0, 5.0),
        'Chiarezza': (punteggio * 1.02).clamp(0.0, 5.0),
        'Qualità': (punteggio * 0.97).clamp(0.0, 5.0),
      },
    );
  }

  /// Restituisce un punteggio fittizio basato sull'AI e la categoria
  double _getPunteggioPerAI(String nomeAi, String categoria) {
    final ai = aiDisponibili.firstWhere((a) => a.nome == nomeAi);
    final isForte = ai.categorieForti.contains(categoria);

    switch (nomeAi) {
      case 'ChatGPT':
        return isForte ? 4.7 : 4.2;
      case 'Claude':
        return isForte ? 4.8 : 4.3;
      case 'Gemini':
        return isForte ? 4.5 : 4.0;
      case 'Copilot':
        return isForte ? 4.4 : 3.8;
      case 'Mistral':
        return isForte ? 4.3 : 3.9;
      default:
        return 4.0;
    }
  }

  /// Restituisce risposte fittizie diverse per ogni AI
  String _getRispostaPerAI(String nomeAi, String categoria) {
    switch (nomeAi) {
      case 'ChatGPT':
        return _risposteChatGPT[categoria] ?? _risposteChatGPT['default']!;
      case 'Claude':
        return _risposteClaude[categoria] ?? _risposteClaude['default']!;
      case 'Gemini':
        return _risposteGemini[categoria] ?? _risposteGemini['default']!;
      case 'Copilot':
        return _risposteCopilot[categoria] ?? _risposteCopilot['default']!;
      case 'Mistral':
        return _risposteMistral[categoria] ?? _risposteMistral['default']!;
      default:
        return 'Risposta generata dall\'AI.';
    }
  }

  // -- Mappe di risposte fittizie per AI --

  static const _risposteChatGPT = {
    'Coding':
        'Ecco la soluzione implementata in modo chiaro e modulare:\n\n'
        '```python\ndef soluzione(dati: list[int]) -> list[int]:\n'
        '    """Elabora i dati con algoritmo ottimizzato."""\n'
        '    risultato = []\n'
        '    for elemento in sorted(dati):\n'
        '        if elemento not in risultato:\n'
        '            risultato.append(elemento)\n'
        '    return risultato\n```\n\n'
        'La funzione gestisce duplicati e ordinamento in un solo passaggio. '
        'Complessità temporale: O(n log n) per il sorting.\n\n'
        'Test consigliati:\n'
        '- Lista vuota → []\n'
        '- Lista con duplicati → rimozione corretta\n'
        '- Lista già ordinata → nessun cambiamento',
    'Scrittura':
        'Ecco il testo richiesto, ottimizzato per il tuo pubblico target:\n\n'
        '---\n\n'
        'In un mondo dove l\'informazione è ovunque, distinguersi richiede autenticità. '
        'Il tuo messaggio deve risuonare con chi lo legge, non solo informare ma ispirare.\n\n'
        'Tre pilastri per una comunicazione efficace:\n'
        '1. **Chiarezza** — Ogni parola ha un peso\n'
        '2. **Empatia** — Scrivi per chi legge, non per chi scrive\n'
        '3. **Azione** — Ogni testo deve portare a un passo successivo\n\n'
        '---\n\n'
        'Questo approccio garantisce un tasso di engagement superiore del 40% rispetto alla media.',
    'default':
        'Ho analizzato la tua richiesta con attenzione. Ecco la mia risposta strutturata:\n\n'
        '**Analisi del contesto:**\n'
        'La tua richiesta tocca diversi aspetti che ho organizzato per priorità.\n\n'
        '**Soluzione proposta:**\n'
        '1. Primo passo: definire gli obiettivi chiari\n'
        '2. Secondo passo: identificare le risorse disponibili\n'
        '3. Terzo passo: implementare e iterare\n\n'
        '**Nota:** Questa soluzione è ottimizzata per il massimo impatto con il minimo sforzo.',
  };

  static const _risposteClaude = {
    'Coding':
        'Analizziamo il problema in modo sistematico.\n\n'
        '**Approccio:** Ho scelto un algoritmo che bilancia leggibilità e performance.\n\n'
        '```python\nfrom typing import TypeVar\n\nT = TypeVar(\'T\')\n\n'
        'def elabora_dati(dati: list[T], *, ordina: bool = True) -> list[T]:\n'
        '    """Rimuove duplicati mantenendo l\'ordine originale.\n\n'
        '    Args:\n'
        '        dati: Lista di elementi da elaborare\n'
        '        ordina: Se True, ordina il risultato\n\n'
        '    Returns:\n'
        '        Lista senza duplicati\n'
        '    """\n'
        '    visti: set[T] = set()\n'
        '    risultato = [x for x in dati if x not in visti and not visti.add(x)]\n'
        '    return sorted(risultato) if ordina else risultato\n```\n\n'
        '**Perché questa soluzione:**\n'
        '- Preserva l\'ordine originale (a differenza di `set()`)\n'
        '- Type hints generici per riusabilità\n'
        '- Parametro opzionale per flessibilità\n'
        '- Complessità: O(n) senza ordinamento, O(n log n) con ordinamento',
    'Scrittura':
        'Ho riflettuto sul tono e il contesto che hai descritto. Ecco la mia proposta:\n\n'
        '---\n\n'
        'Le parole migliori sono quelle che non cercano di impressionare, ma di connettere.\n\n'
        'Quando scrivi per un pubblico professionale, ricorda che dietro ogni schermo c\'è '
        'una persona con poco tempo e tante distrazioni. Il tuo testo deve rispettare entrambe le cose.\n\n'
        '**La regola del "e quindi?":**\n'
        'Dopo ogni frase, chiediti: "e quindi? Perché dovrebbe importare al lettore?". '
        'Se non hai una risposta immediata, quella frase probabilmente non serve.\n\n'
        'Il risultato è un testo che respira: breve dove serve, dettagliato dove conta.\n\n'
        '---\n\n'
        'Ho mantenuto un tono che bilancia professionalità e calore umano, come richiesto.',
    'default':
        'Ho letto attentamente la tua richiesta. Ecco il mio ragionamento e la proposta:\n\n'
        '**Comprensione:** La tua esigenza principale è ottenere un risultato di qualità '
        'che sia immediatamente utilizzabile.\n\n'
        '**Il mio approccio:**\n'
        'Ho strutturato la risposta in modo che ogni sezione sia autonoma e utile.\n\n'
        '1. **Contesto** — Ho inquadrato il problema nel suo scenario reale\n'
        '2. **Soluzione** — Proposta concreta con passi actionable\n'
        '3. **Alternative** — Opzioni B e C nel caso la principale non funzioni\n\n'
        '**Considerazione finale:**\n'
        'La qualità sta nei dettagli. Ho prestato attenzione a ogni sfumatura della tua richiesta '
        'per fornirti qualcosa che funzioni davvero, non solo sulla carta.',
  };

  static const _risposteGemini = {
    'Coding':
        '🔧 Ecco l\'implementazione richiesta con un approccio moderno:\n\n'
        '```python\ndef processa(dati: list) -> list:\n'
        '    # Utilizzo dict.fromkeys per preservare l\'ordine e rimuovere duplicati\n'
        '    return list(dict.fromkeys(sorted(dati)))\n```\n\n'
        'Questa soluzione sfrutta una proprietà dei dizionari Python 3.7+: '
        'mantengono l\'ordine di inserimento. È una one-liner elegante.\n\n'
        'Alternativa per dataset grandi: usa `pandas.Series.unique()` per performance migliori '
        'su milioni di elementi.',
    'default':
        'Basandomi sulla tua richiesta, ho preparato una risposta che combina ricerca e praticità.\n\n'
        '📌 **Punti chiave:**\n\n'
        '• Il contesto suggerisce un approccio graduale piuttosto che una soluzione unica\n'
        '• Ho identificato 3 aree di intervento prioritarie\n'
        '• Ogni suggerimento include un esempio pratico\n\n'
        '**Raccomandazione:** Inizia dal punto 1, valuta i risultati dopo una settimana, '
        'poi procedi con gli step successivi.\n\n'
        'Posso approfondire qualsiasi aspetto se necessario.',
  };

  static const _risposteCopilot = {
    'Coding':
        '// Ecco il codice ottimizzato:\n\n'
        '```python\ndef soluzione_ottimizzata(dati):\n'
        '    return sorted(set(dati))\n```\n\n'
        'Semplice ed efficiente. Usa `set()` per O(n) dedup e `sorted()` per O(n log n) ordinamento.\n\n'
        'Se ti serve preservare l\'ordine originale:\n'
        '```python\ndef mantieni_ordine(dati):\n'
        '    return list(dict.fromkeys(dati))\n```\n\n'
        'Entrambe le soluzioni sono production-ready e testate.',
    'default':
        'Ho analizzato la tua richiesta. Ecco la soluzione:\n\n'
        '**Step 1:** Definisci chiaramente l\'obiettivo finale\n'
        '**Step 2:** Scomponi in sotto-task gestibili\n'
        '**Step 3:** Esegui in ordine di priorità\n\n'
        'Consiglio: utilizza un approccio iterativo per ottenere feedback rapidi e correggere il corso.',
  };

  static const _risposteMistral = {
    'Coding':
        'Voici mon implémentation — pardon, ecco la mia implementazione! 🇫🇷\n\n'
        '```python\nfrom functools import reduce\n\ndef deduplica_e_ordina(dati: list[int]) -> list[int]:\n'
        '    """Approccio funzionale alla deduplicazione."""\n'
        '    return sorted(\n'
        '        reduce(\n'
        '            lambda acc, x: acc | {x},\n'
        '            dati,\n'
        '            set()\n'
        '        )\n'
        '    )\n```\n\n'
        'Ho utilizzato un approccio funzionale con `reduce` per mostrare un pattern diverso. '
        'Per uso in produzione, `sorted(set(dati))` resta la scelta migliore per semplicità.',
    'default':
        'Ho elaborato la tua richiesta con il mio approccio analitico.\n\n'
        '**Sintesi:**\n'
        'La soluzione ottimale richiede di bilanciare qualità ed efficienza.\n\n'
        '**Piano d\'azione:**\n'
        '1. Analisi preliminare dei requisiti (completata)\n'
        '2. Proposta strutturata con alternative\n'
        '3. Validazione e raffinamento\n\n'
        'Il mio suggerimento è di procedere in modo incrementale, validando ogni passaggio.',
  };
}
