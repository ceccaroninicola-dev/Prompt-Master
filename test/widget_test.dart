import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_master/main.dart';

/// Test dei widget principali dell'app Prompt Master.
void main() {
  // Verifica che la schermata Home si carichi correttamente
  testWidgets('La schermata Home mostra il titolo e i bottoni principali',
      (WidgetTester tester) async {
    // Costruisce l'app e triggera un frame
    await tester.pumpWidget(const PromptMasterApp());

    // Verifica che il titolo "Prompt Master" sia presente
    // (appare sia nella AppBar che nel corpo della pagina)
    expect(find.text('Prompt Master'), findsWidgets);

    // Verifica che i tre bottoni principali siano presenti
    expect(find.text('Crea nuovo prompt'), findsOneWidget);
    expect(find.text('Libreria'), findsOneWidget);
    expect(find.text('Cronologia'), findsOneWidget);
  });

  // Verifica che il toggle del tema funzioni
  testWidgets('Il bottone del tema alterna tra chiaro e scuro',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PromptMasterApp());

    // Cerca il bottone per cambiare tema (icona dark_mode in modalità chiara)
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    // Tocca il bottone per cambiare tema
    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    // Dopo il tap, l'icona dovrebbe cambiare a light_mode
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });

  // Verifica navigazione dalla Home alla schermata di input libero
  testWidgets('Il bottone "Crea nuovo prompt" naviga alla schermata di input',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PromptMasterApp());

    // Tocca il bottone "Crea nuovo prompt"
    await tester.tap(find.text('Crea nuovo prompt'));
    await tester.pumpAndSettle();

    // Verifica che siamo nella schermata di input libero
    expect(find.text('Cosa vuoi ottenere?'), findsOneWidget);
    expect(find.text('Analizza e prosegui'), findsOneWidget);
  });

  // Verifica che la schermata di input mostra gli esempi rapidi
  testWidgets('La schermata input mostra i chip di esempio',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PromptMasterApp());

    // Naviga alla schermata di input
    await tester.tap(find.text('Crea nuovo prompt'));
    await tester.pumpAndSettle();

    // Verifica che gli esempi rapidi siano visibili
    expect(find.text('Esempi rapidi:'), findsOneWidget);
    expect(find.text('Scrivi un\'email professionale'), findsOneWidget);
    expect(find.text('Aiutami con codice Python'), findsOneWidget);
  });

  // Verifica il flusso: input → analisi → conferma categoria
  testWidgets('L\'invio della frase porta alla schermata di conferma categoria',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PromptMasterApp());

    // Naviga alla schermata di input
    await tester.tap(find.text('Crea nuovo prompt'));
    await tester.pumpAndSettle();

    // Scrivi una frase nel campo di input
    await tester.enterText(
      find.byType(TextField),
      'Voglio scrivere un post LinkedIn sul mio nuovo prodotto',
    );
    await tester.pumpAndSettle();

    // Il bottone "Analizza e prosegui" dovrebbe essere attivo
    final bottoneInvia = find.text('Analizza e prosegui');
    expect(bottoneInvia, findsOneWidget);

    // Tocca il bottone di invio
    await tester.tap(bottoneInvia);

    // Attendi l'animazione di caricamento e la navigazione
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verifica che siamo nella schermata di conferma categoria
    expect(find.text('Conferma categoria'), findsOneWidget);
    expect(find.text('Ecco cosa ho capito'), findsOneWidget);
    expect(find.text('Scrittura'), findsOneWidget);
  });

  // Verifica navigazione dalla conferma alle domande
  testWidgets('Il bottone "Prosegui" porta alla schermata delle domande',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PromptMasterApp());

    // Naviga alla schermata di input
    await tester.tap(find.text('Crea nuovo prompt'));
    await tester.pumpAndSettle();

    // Inserisci una frase e invia
    await tester.enterText(
      find.byType(TextField),
      'Aiutami con codice Python per una funzione di ordinamento',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analizza e prosegui'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Tocca "Prosegui" nella schermata di conferma
    await tester.tap(find.text('Prosegui'));
    await tester.pumpAndSettle();

    // Verifica che siamo nella schermata delle domande
    // Dovrebbe mostrare la prima domanda per la categoria Coding
    expect(
        find.text('In quale linguaggio di programmazione stai lavorando?'),
        findsOneWidget);

    // Verifica che la barra di avanzamento sia presente
    expect(find.text('Domanda 1 di 5'), findsOneWidget);

    // Verifica che i bottoni opzione siano presenti
    expect(find.text('Python'), findsOneWidget);
    expect(find.text('JavaScript'), findsOneWidget);
  });
}
