# Prompt Master - Istruzioni per Claude

## Descrizione del progetto
Prompt Master è un'app mobile cross-platform sviluppata con Flutter.
L'app aiuta gli utenti a creare, salvare e gestire prompt per interagire con modelli AI.

## Stack tecnologico
- **Framework**: Flutter 3.41+
- **Linguaggio**: Dart 3.11+
- **Gestione stato**: Provider
- **Piattaforme target**: Android, iOS, Web

## Struttura del progetto
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

## Convenzioni di codice
- **Lingua dei commenti**: Italiano
- **Naming convention**: camelCase per variabili/metodi, PascalCase per classi
- **Organizzazione file**: Un widget/classe principale per file
- **Temi**: Supporto obbligatorio per dark mode e light mode
- **State management**: Usare Provider per stato globale, setState per stato locale semplice

## Comandi utili
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

## Regole per le modifiche
1. Ogni nuovo widget deve supportare sia il tema chiaro che quello scuro
2. I commenti nel codice devono essere in italiano
3. Seguire le best practices Flutter e le linee guida Material Design 3
4. Testare sempre le modifiche con `flutter analyze` prima del commit
5. Mantenere la struttura delle cartelle organizzata per feature
