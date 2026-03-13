# PROMPT MASTER — Prompt di Progetto Completo

---

## Contesto del Progetto

Devi aiutarmi a progettare e sviluppare "Prompt Master", un'app mobile cross-platform (iOS e Android) che guida qualsiasi utente — dal principiante all'esperto — nella creazione di prompt perfetti per qualsiasi modello AI (ChatGPT, Claude, Gemini, Midjourney, Stable Diffusion, Copilot, ecc.).

L'app funziona come un "Prompt Builder" intelligente e adattivo: attraverso una serie di domande mirate e progressive, raccoglie le intenzioni dell'utente e genera un prompt ottimizzato, pronto per essere copiato o inviato direttamente all'AI di destinazione tramite API.

---

## Profilo dello Sviluppatore

- **Competenze attuali**: HTML, CSS, JavaScript (livello base)
- **Risorse esterne**: Nessun team; sviluppo in autonomia con assistenza AI
- **Obiettivo**: Prodotto completo da lanciare sugli store (App Store + Google Play)
- **Timeline**: 1-3 mesi per la prima versione pubblica
- **Stack consigliato**: Flutter (Dart) per il cross-platform, oppure React Native se si vuole sfruttare la base JavaScript. La scelta finale va valutata insieme in base a pro e contro per questo specifico progetto.

---

## Funzionalità Core

### 1. Interazione Multimodale

L'utente può interagire con l'app in tre modi, anche combinandoli nella stessa sessione:

- **Chat testuale** — digita le risposte in un'interfaccia conversazionale
- **Input vocale** — risponde a voce (speech-to-text integrato)
- **Selezione rapida** — sceglie tra opzioni proposte dall'app (bottoni, chip, slider, menu)

### 2. Motore di Domande Adattivo — Specifica Dettagliata

Il motore di domande è il cuore dell'app. È alimentato da un modello AI che genera le domande in tempo reale, adattandosi dinamicamente all'utente e al contesto. Non si tratta di un albero decisionale fisso, ma di un sistema intelligente che ragiona su cosa chiedere dopo.

#### 2.1 Avvio della Conversazione

- L'utente inizia scrivendo (o dettando) una frase libera che descrive cosa vuole ottenere (es. "Voglio scrivere un post LinkedIn sul mio nuovo prodotto")
- L'AI analizza la frase, rileva automaticamente la categoria (in questo caso: scrittura/marketing) e la propone all'utente per conferma prima di procedere
- Se la frase iniziale contiene già molte informazioni utili, l'app salta le domande ridondanti e mostra un breve riepilogo di ciò che ha già capito (es. "Ho capito che vuoi: un post LinkedIn, tema: lancio prodotto. Proseguiamo con i dettagli!")

#### 2.2 Numero di Domande

- Il numero di domande è completamente dinamico — è l'AI a decidere quante servono in base alla complessità della richiesta e alla quantità di informazioni già raccolte
- Un bottone "Genera ora" è sempre visibile in basso, così l'utente può interrompere le domande e generare il prompt in qualsiasi momento, anche con informazioni parziali
- L'AI compensa internamente eventuali informazioni mancanti con valori di default intelligenti

#### 2.3 Presentazione delle Domande

- Le domande vengono poste una alla volta, per non sovraccaricare l'utente
- Ogni domanda è autoesplicativa — non serve spiegare perché viene posta; la formulazione stessa deve rendere chiaro lo scopo
- Una barra di avanzamento in alto mostra a che punto è la sessione. La barra si aggiorna dinamicamente (poiché il numero di domande non è fisso, l'AI stima la percentuale di completamento in base alle informazioni raccolte vs quelle necessarie)

#### 2.4 Tipi di Input per le Risposte

Per ogni domanda, l'app sceglie il formato di risposta più adatto. L'utente può sempre digitare o dettare, ma in aggiunta l'app offre:

- **Bottoni con opzioni** — per scelte discrete e chiare (es. "Tono: Formale / Informale / Ironico")
- **Chip/tag selezionabili** — per selezioni multiple (es. "Pubblico target: Manager, Startup, Developer, Designer")
- **Esempi cliccabili** — mostrano un'anteprima concreta di come apparirebbe il risultato per ciascuna opzione, così l'utente sceglie vedendo il risultato atteso (es. per il tono, mostrare un mini-esempio di frase formale vs informale)
- **Input libero (testo/voce)** — sempre disponibile come alternativa

#### 2.5 Valori di Default Intelligenti

- Se l'utente non sa cosa rispondere, l'app propone valori di default basati sul contesto della conversazione e sulla categoria
- I default non sono generici ma contestuali — cambiano in base a ciò che l'utente ha già detto (es. se sta creando un prompt per codice Python, il default per "livello di commenti" potrebbe essere "dettagliato con docstring")
- I default sono pre-selezionati ma l'utente può modificarli con un tap

#### 2.6 Rilevamento Livello Utente

- L'app NON chiede esplicitamente il livello dell'utente e non usa quiz iniziali
- Il livello viene dedotto automaticamente dall'AI analizzando il modo in cui l'utente risponde: complessità del linguaggio, uso di termini tecnici, velocità e precisione delle risposte, tipo di dettagli forniti spontaneamente
- In base al livello rilevato, l'AI adatta:
  - **Principiante**: domande più semplici, linguaggio accessibile, più suggerimenti precompilati, esempi concreti
  - **Esperto**: domande tecniche e dirette, meno suggerimenti ovvi, opzioni più granulari e avanzate
- L'adattamento avviene in modo fluido e progressivo durante la sessione, non come un cambio netto

#### 2.7 Tono della Conversazione

- Il tono dell'app è adattivo — rispecchia lo stile comunicativo dell'utente
- Se l'utente scrive in modo formale, l'app risponde formalmente; se è colloquiale, l'app diventa più informale e amichevole
- L'adattamento del tono avviene fin dalla prima risposta dell'utente e si affina durante la sessione

#### 2.8 Gestione Risposte Vaghe

- Se l'utente dà una risposta poco chiara o troppo generica, l'app non prosegue con incertezza
- Pone una sotto-domanda di chiarimento mirata e specifica (es. se l'utente dice "tono normale" → l'app chiede "Intendi un tono professionale ma accessibile, oppure colloquiale come una conversazione tra colleghi?")
- Le sotto-domande di chiarimento non fanno avanzare la barra di progresso, così l'utente non si sente rallentato

#### 2.9 Navigazione e Correzione

- L'utente può tornare indietro a qualsiasi domanda precedente e modificare la sua risposta
- La navigazione avviene tramite tap sulla barra di avanzamento o swipe indietro
- Quando una risposta viene modificata, l'AI ricalcola le domande successive (alcune potrebbero cambiare, essere aggiunte o rimosse)
- L'utente vede chiaramente quale risposta sta modificando e può confermare per tornare al punto in cui era

#### 2.10 Visualizzazione del Prompt

- Il prompt non viene mostrato durante la costruzione — l'utente vede solo le domande e le sue risposte
- Il prompt completo appare solo alla fine, nella schermata di anteprima, dopo aver premuto "Genera ora" o dopo che l'AI ha completato tutte le domande necessarie
- Questo evita distrazioni e mantiene l'utente concentrato sulle risposte

### 3. Generazione del Prompt

- Il prompt finale viene generato combinando tutte le risposte in un formato ottimizzato
- Il prompt è universale by design — viene scritto per funzionare su qualsiasi AI
- L'adattamento alla specifica piattaforma AI avviene solo in fase di export (vedi sezione 4)
- Formattazione chiara con sezioni: ruolo, contesto, istruzioni, formato output, vincoli, esempi
- Supporto per prompt semplici (one-shot) e complessi (multi-step, chain-of-thought, few-shot)

### 4. Schermata Post-Generazione — Specifica Dettagliata

La schermata post-generazione è dove l'utente perfeziona, valuta, esporta e condivide il suo prompt. È la fase dove il valore dell'app diventa concreto.

#### 4.1 Anteprima del Prompt — Due Viste

L'utente può visualizzare il prompt generato in due modalità, alternabili con un toggle:

- **Vista Semplice**: il prompt appare come testo continuo, pulito e leggibile, pronto per essere copiato così com'è
- **Vista Strutturata**: il prompt è diviso in sezioni colorate e collassabili (Ruolo, Contesto, Istruzioni, Formato Output, Vincoli, Esempi). Ogni sezione è toccabile per espanderla o comprimerla

#### 4.2 Modifica del Prompt

- L'utente modifica il prompt per sezioni: tocca una sezione nella vista strutturata per entrare in modalità editing di quella specifica parte
- La modifica è inline — l'utente edita direttamente il testo della sezione selezionata
- Dopo ogni modifica, il punteggio di qualità (stelle) si aggiorna in tempo reale
- L'utente non può modificare il prompt in vista semplice (solo lettura), deve passare alla vista strutturata

#### 4.3 Valutazione Qualità — Sistema a Stelle

- Il prompt generato riceve un punteggio a stelle (es. 4.2/5) calcolato dall'AI
- Il punteggio è basato su criteri specifici: chiarezza, specificità, completezza, struttura, coerenza
- Sotto le stelle, un breakdown per criterio mostra il punteggio di ogni singola dimensione (es. Chiarezza: 4.5, Specificità: 3.8, Completezza: 4.0)
- Il punteggio si aggiorna automaticamente quando l'utente modifica il prompt o applica suggerimenti

#### 4.4 Suggerimenti di Miglioramento

- Sotto il prompt, l'app mostra chip cliccabili con suggerimenti contestuali (es. "Aggiungi un esempio", "Specifica il formato", "Definisci il tono", "Aggiungi vincoli")
- Quando l'utente tocca un chip, vede un'anteprima prima/dopo: la versione attuale della sezione interessata e la versione migliorata, affiancate o sovrapposte
- L'utente può applicare il suggerimento con un tap di conferma, oppure scartarlo
- Dopo l'applicazione, il punteggio a stelle si aggiorna e nuovi suggerimenti possono apparire
- I suggerimenti sono generati dall'AI e sono specifici per quel prompt, non generici

---

## Export, Confronto AI e Condivisione

### 5. Export e Invio — Specifica Dettagliata

#### 5.1 Scelta dell'AI di Destinazione

- Il prompt è universale, ma al momento dell'export l'utente sceglie verso quale AI inviarlo
- Quando l'utente seleziona un'AI, il prompt viene automaticamente ottimizzato per quella piattaforma specifica: adattamento della formattazione, delle keyword, della struttura e dello stile in base alle best practices dell'AI scelta (es. uso di system prompt per Claude, di custom instructions per ChatGPT, ecc.)
- L'utente può vedere l'anteprima del prompt adattato prima di confermare l'invio

#### 5.2 Modalità di Export

L'utente ha a disposizione più modalità di export:

- **Copia negli appunti** — un tap per copiare il prompt (universale o ottimizzato per una specifica AI)
- **Invio diretto via API** — l'app invia il prompt all'AI selezionata e mostra la risposta in-app (vedi sezione 5.3 per il confronto multi-AI)
- **Condivisione come link** — genera un link condivisibile che chiunque con l'app può aprire, importare e modificare
- **Esportazione come file** — salva il prompt come PDF o TXT
- **Condivisione diretta** — tramite WhatsApp, Telegram, Email, SMS, social media (LinkedIn, X, ecc.) usando il sistema di condivisione nativo del dispositivo

#### 5.3 Confronto Risposte Multi-AI (Funzionalità Killer)

Questa è una delle funzionalità più distintive dell'app:

- Quando l'utente sceglie "Invia via API", l'app suggerisce le 2-3 AI migliori per quel tipo di prompt (es. per coding suggerisce Claude e GPT-4; per immagini suggerisce DALL-E e Stable Diffusion)
- L'utente può accettare i suggerimenti o modificare la selezione
- Il prompt viene inviato contemporaneamente a tutte le AI selezionate
- Le risposte vengono mostrate in card affiancate con swipe orizzontale — l'utente scorre lateralmente per confrontare le risposte
- Ogni card mostra: il nome/logo dell'AI, la risposta completa, e un punteggio di qualità della risposta (calcolato dall'AI interna dell'app)
- L'app evidenzia la risposta migliore con un badge o una cornice colorata, basandosi su criteri come pertinenza, completezza, chiarezza e qualità della risposta
- L'utente non continua la conversazione dentro l'app — dopo aver visto le risposte, può copiare la migliore o aprire l'app dell'AI scelta per proseguire

#### 5.4 Salvataggio e Cronologia

- Tutto viene salvato automaticamente come pacchetto completo: il prompt generato, tutte le risposte delle AI, i punteggi, e le note personali dell'utente
- La cronologia è ricercabile per parola chiave, filtrabile per categoria, data, AI di destinazione, punteggio
- L'utente può duplicare e modificare prompt precedenti
- Organizzazione in cartelle e/o tag personalizzati
- Sincronizzazione cloud tra dispositivi

---

## Community e Libreria Pubblica

### 6. Libreria di Prompt Templates

- Raccolta curata di template pronti all'uso per scenari comuni
- Categorie: marketing, coding, immagini, email, social media, analisi, studio, ecc.
- I template sono personalizzabili — l'utente li adatta alle sue esigenze
- Sezione "Più popolari" e "Nuovi" aggiornata in base all'attività della community

### 7. Community dei Prompt — Specifica Dettagliata

L'app include una dimensione social che la trasforma in una sorta di "GitHub dei prompt", dove gli utenti possono condividere, scoprire e migliorare prompt collettivamente.

#### 7.1 Account e Profilo

- L'utilizzo delle funzionalità social richiede un account obbligatorio con profilo pubblico
- Il profilo mostra: nome utente, avatar, bio, numero di prompt pubblicati, numero di like ricevuti, prompt più popolari
- L'account è necessario per pubblicare, commentare, fare fork e votare. La creazione di prompt in locale rimane possibile senza account

#### 7.2 Pubblicazione e Visibilità

Ogni prompt salvato può essere condiviso con tre livelli di visibilità, scelti dall'utente:

- **Privato** — visibile solo all'autore (default)
- **Solo link** — accessibile solo da chi ha il link diretto, non appare nella libreria pubblica
- **Pubblico** — visibile a tutti nella libreria pubblica dell'app, ricercabile e navigabile

L'utente può cambiare la visibilità in qualsiasi momento

#### 7.3 Interazioni Social

- **Like / Upvote** — gli utenti possono votare i prompt che trovano utili; i like determinano la posizione nelle classifiche
- **Commenti e suggerimenti** — sotto ogni prompt pubblico, gli utenti possono lasciare commenti, fare domande, suggerire miglioramenti
- **Classifica** — sezione con i prompt più usati, più votati, più forkati, e i "trending" della settimana
- **Fork** — qualsiasi utente può creare una versione migliorata di un prompt pubblico. Il fork è un nuovo prompt nel profilo dell'utente, ma mantiene un collegamento visibile al prompt originale

#### 7.4 Attribuzione e Fork

- L'autore originale viene sempre citato quando qualcuno fa un fork del suo prompt
- Sul prompt forkato appare un badge "Forkato da @nomeautore" con link al prompt originale
- L'autore originale riceve una notifica quando qualcuno fa un fork del suo prompt
- Il contatore di fork è visibile sul prompt originale (indicatore di popolarità e influenza)

#### 7.5 Importazione da Link Condiviso

- Quando un utente riceve un link a un prompt (via WhatsApp, email, social, ecc.), può aprirlo nell'app
- Dall'anteprima, può importare il prompt nella propria libreria personale e modificarlo liberamente
- Se l'utente non ha l'app installata, il link apre una pagina web con anteprima e invito a scaricare l'app

---

## Integrazioni

### 8. Assistenti Vocali

- **Siri (iOS)**: l'utente può avviare la creazione di un prompt dicendo "Ehi Siri, crea un prompt con Prompt Master"
- **Google Assistant (Android)**: equivalente funzionalità con comandi vocali
- Supporto per Siri Shortcuts / Google Assistant Routines

### 9. API AI Supportate

L'app deve poter inviare i prompt a (lista espandibile):

- OpenAI (GPT-4, GPT-4o, DALL-E)
- Anthropic (Claude)
- Google (Gemini)
- Stability AI (Stable Diffusion)
- Altre API future tramite architettura modulare

---

## Requisiti Tecnici

### 10. Multilingua

- L'app deve essere multilingua fin dal lancio
- Lingue minime al lancio: italiano, inglese, spagnolo, francese, tedesco
- Sistema di i18n robusto per aggiungere lingue facilmente
- I prompt generati rispettano la lingua dell'utente (ma possono essere generati in qualsiasi lingua)

### 11. Modello di Business

- Gratis con pubblicità (banner e/o interstitial non invasivi)
- Integrazione con AdMob o equivalente
- Possibilità futura di upgrade a versione premium senza pubblicità

### 12. Architettura

- **Cross-platform**: iOS + Android da un'unica codebase
- **Backend**: per gestire utenti, sincronizzazione, templates, analytics
- **Database**: per cronologia, preferenze, template personalizzati
- **AI Engine interno**: un modello AI (da definire) alimenta il motore di domande e la generazione dei prompt
- **Architettura modulare**: facile aggiungere nuove AI, nuove categorie, nuove lingue

---

## Design e UX

### 13. Principi di Design

- Interfaccia pulita e moderna — ispirazione da app come ChatGPT, Notion, Linear
- Onboarding guidato — tutorial al primo avvio che mostra come funziona l'app
- Dark mode e Light mode
- Animazioni fluide — transizioni tra le fasi della creazione del prompt
- Accessibilità — supporto VoiceOver/TalkBack, font scalabili, contrasto adeguato
- Feedback tattile — vibrazione leggera su azioni chiave

### 14. Flusso Utente Principale

1. Apertura app → Schermata Home con azioni rapide (crea nuovo, cronologia, libreria, community)
2. "Crea nuovo prompt" → L'utente scrive/detta una frase libera
3. L'AI rileva la categoria e mostra un riepilogo → L'utente conferma
4. Sessione di domande adattive → Una alla volta, multimodale, con barra di avanzamento
5. Bottone "Genera ora" (o completamento naturale) → Generazione del prompt universale
6. Schermata anteprima → Due viste (semplice/strutturata) + stelle di qualità + suggerimenti miglioramento (chip con prima/dopo)
7. Modifica per sezioni → L'utente perfeziona toccando le sezioni nella vista strutturata
8. Export → Scelta AI di destinazione → Ottimizzazione automatica del prompt per l'AI scelta
9. Azione finale → Copia / Invio API con confronto multi-AI / Condivisione (link, file, WhatsApp, email, social) / Pubblica nella community
10. Salvataggio automatico → Pacchetto completo (prompt + risposte + score) nella cronologia

---

## Piano di Sviluppo Suggerito

### Fase 1 — MVP (Mese 1)

- Setup progetto cross-platform
- Flusso base: frase libera → domande adattive AI → generazione prompt universale → copia
- Anteprima con due viste (semplice/strutturata) e modifica per sezioni
- Sistema di scoring a stelle
- 2-3 categorie (scrittura, coding, immagini)
- Interfaccia chat con bottoni, chip e input vocale base
- Multilingua (italiano + inglese)

### Fase 2 — Funzionalità Complete (Mese 2)

- Tutte le categorie
- Suggerimenti di miglioramento (chip con anteprima prima/dopo)
- Cronologia con salvataggio pacchetto completo
- Libreria template base
- Export: copia, file PDF/TXT, condivisione WhatsApp/Telegram/email/social
- Link condivisibili con importazione nell'app
- Tutte le lingue previste
- Ottimizzazione prompt per AI specifica in fase di export

### Fase 3 — Lancio (Mese 3)

- Integrazione API AI (invio diretto + confronto multi-AI con card affiancate e scoring risposte)
- Community: profili pubblici, pubblicazione prompt, like, commenti, fork con attribuzione, classifiche
- Siri / Google Assistant
- Pubblicità (AdMob)
- Testing, bug fixing, ottimizzazione performance
- Pubblicazione su App Store e Google Play

---

## Istruzioni per l'AI Assistente

Quando lavori con me su questo progetto:

1. **Guidami passo dopo passo** — ho conoscenze base di HTML/CSS/JS, quindi spiega ogni concetto nuovo
2. **Proponi la tecnologia migliore** — confronta Flutter vs React Native per questo caso specifico e consigliami
3. **Scrivi codice commentato** — ogni blocco di codice deve avere commenti chiari in italiano
4. **Anticipa i problemi** — segnalami potenziali ostacoli tecnici prima che ci arrivi
5. **Struttura modulare** — organizza il codice in modo che ogni componente sia indipendente e testabile
6. **Verifica di fattibilità** — se qualcosa non è realistico nei tempi previsti, dimmelo subito e proponi alternative
7. **Best practices** — applica sempre le migliori pratiche di sviluppo mobile, sicurezza e UX
8. **Documentazione** — genera documentazione tecnica man mano che procediamo

---

*Questo prompt è stato generato attraverso un processo di analisi guidata delle esigenze. Usalo come riferimento principale per tutto lo sviluppo del progetto "Prompt Master".*

---

## Riferimento Tecnico Rapido

### Stack Tecnologico Attuale
- **Framework**: Flutter 3.41+
- **Linguaggio**: Dart 3.11+
- **Gestione stato**: Provider
- **Piattaforme target**: Android, iOS, Web

### Struttura del Progetto
```
lib/
├── config/          → Configurazione app (temi, costanti, rotte)
├── models/          → Modelli dati (classi Dart)
├── providers/       → Provider per la gestione dello stato
├── screens/         → Schermate dell'app (una cartella per schermata)
├── services/        → Servizi (API, database, storage locale)
├── utils/           → Funzioni di utilità e helper
├── widgets/         → Widget riutilizzabili condivisi tra schermate
└── main.dart        → Entry point dell'applicazione
```

### Convenzioni di Codice
- **Lingua dei commenti**: Italiano
- **Naming convention**: camelCase per variabili/metodi, PascalCase per classi
- **Organizzazione file**: Un widget/classe principale per file
- **Temi**: Supporto obbligatorio per dark mode e light mode
- **State management**: Usare Provider per stato globale, setState per stato locale semplice

### Comandi Utili
```bash
# Eseguire l'app
flutter run

# Eseguire i test
flutter test

# Analisi statica del codice
flutter analyze

# Build per Android
flutter build apk

# Build per iOS
flutter build ios
```

### Regole per le Modifiche
1. Ogni nuovo widget deve supportare sia il tema chiaro che quello scuro
2. I commenti nel codice devono essere in italiano
3. Seguire le best practices Flutter e le linee guida Material Design 3
4. Testare sempre le modifiche con `flutter analyze` prima del commit
5. Mantenere la struttura delle cartelle organizzata per feature
