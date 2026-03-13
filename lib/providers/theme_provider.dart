import 'package:flutter/material.dart';

/// Provider per la gestione del tema (chiaro/scuro).
/// Utilizza ChangeNotifier per notificare i widget quando il tema cambia.
class ThemeProvider extends ChangeNotifier {
  // Modalità scura attiva o meno (default: segue il sistema)
  ThemeMode _modalitaTema = ThemeMode.system;

  /// Restituisce la modalità del tema corrente
  ThemeMode get modalitaTema => _modalitaTema;

  /// Verifica se la modalità scura è attiva
  bool get isModaScura => _modalitaTema == ThemeMode.dark;

  /// Alterna tra tema chiaro e scuro
  void cambiaTema() {
    _modalitaTema =
        _modalitaTema == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Imposta una modalità tema specifica
  void impostaModalitaTema(ThemeMode modalita) {
    _modalitaTema = modalita;
    notifyListeners();
  }
}
