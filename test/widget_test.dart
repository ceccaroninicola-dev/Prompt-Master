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
}
