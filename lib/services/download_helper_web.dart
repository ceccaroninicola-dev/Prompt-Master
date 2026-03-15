import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

/// Implementazione web — scarica il file nel browser usando un Blob URL
Future<void> scaricaFile({
  required List<int> bytes,
  required String nomeFile,
  required String mimeType,
}) async {
  // Crea un Blob dal contenuto del file
  final jsArray = Uint8List.fromList(bytes).toJS;
  final blob = web.Blob(
    [jsArray].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);

  // Crea un link temporaneo e simula il click per avviare il download
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = nomeFile;
  anchor.style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();

  // Pulizia
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
