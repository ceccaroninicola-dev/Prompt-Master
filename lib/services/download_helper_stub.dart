/// Stub per il download helper — non dovrebbe mai essere usato direttamente.
/// Viene sostituito dal file web o mobile tramite conditional import.
Future<void> scaricaFile({
  required List<int> bytes,
  required String nomeFile,
  required String mimeType,
}) async {
  throw UnsupportedError('Download non supportato su questa piattaforma');
}
