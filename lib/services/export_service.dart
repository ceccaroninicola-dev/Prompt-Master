import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:prompt_master/models/prompt_generato.dart';
import 'package:prompt_master/services/download_helper.dart' as download;

/// Servizio per l'esportazione dei prompt in vari formati.
/// Su web usa il download diretto nel browser.
class ExportService {
  /// Copia il testo del prompt negli appunti del sistema
  static Future<void> copiaTestoNegliAppunti(PromptGenerato prompt) async {
    await Clipboard.setData(ClipboardData(text: prompt.testoCompleto));
  }

  /// Condivide il prompt come testo — su web copia negli appunti
  static Future<void> condividiTesto(PromptGenerato prompt) async {
    await Clipboard.setData(ClipboardData(text: prompt.testoCompleto));
  }

  /// Genera un PDF del prompt e lo scarica nel browser
  static Future<void> esportaPdf(
    PromptGenerato prompt, {
    String? nomeAiDestinazione,
  }) async {
    final pdfBytes = await _generaPdf(
      prompt,
      nomeAiDestinazione: nomeAiDestinazione,
    );
    await download.scaricaFile(
      bytes: pdfBytes,
      nomeFile: 'prompt_master.pdf',
      mimeType: 'application/pdf',
    );
  }

  /// Genera un TXT del prompt e lo scarica nel browser
  static Future<void> esportaTxt(
    PromptGenerato prompt, {
    String? nomeAiDestinazione,
  }) async {
    final contenuto = _generaTxt(
      prompt,
      nomeAiDestinazione: nomeAiDestinazione,
    );
    final bytes = Uint8List.fromList(contenuto.codeUnits);
    await download.scaricaFile(
      bytes: bytes,
      nomeFile: 'prompt_master.txt',
      mimeType: 'text/plain',
    );
  }

  // -- Metodi privati di generazione --

  /// Genera i bytes del PDF con il contenuto del prompt strutturato
  static Future<Uint8List> _generaPdf(
    PromptGenerato prompt, {
    String? nomeAiDestinazione,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          final widgets = <pw.Widget>[];

          // Intestazione
          widgets.add(
            pw.Header(
              level: 0,
              child: pw.Text(
                'Prompt Master',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF0D9488),
                ),
              ),
            ),
          );

          // Info AI destinazione se presente
          if (nomeAiDestinazione != null && nomeAiDestinazione != 'Generico') {
            widgets.add(
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                margin: const pw.EdgeInsets.only(bottom: 16),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFE0F5F3),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  'Ottimizzato per $nomeAiDestinazione',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: const PdfColor.fromInt(0xFF0D9488),
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            );
          }

          // Punteggio
          widgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Text(
                'Punteggio qualita: ${prompt.punteggioGlobale}/5',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          );

          // Sezioni del prompt
          for (final sezione in prompt.sezioni) {
            if (sezione.contenuto.isEmpty) continue;

            widgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColor.fromInt(sezione.colore),
                    width: 1,
                  ),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      sezione.titolo.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(sezione.colore),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      sezione.contenuto,
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          }

          // Footer
          widgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 20),
              child: pw.Text(
                'Generato con Prompt Master',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          );

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  /// Genera il contenuto testuale formattato per il file TXT
  static String _generaTxt(
    PromptGenerato prompt, {
    String? nomeAiDestinazione,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('========================================');
    buffer.writeln('  PROMPT MASTER');
    buffer.writeln('========================================');
    buffer.writeln();

    if (nomeAiDestinazione != null && nomeAiDestinazione != 'Generico') {
      buffer.writeln('[ Ottimizzato per $nomeAiDestinazione ]');
      buffer.writeln();
    }

    buffer.writeln('Punteggio qualita: ${prompt.punteggioGlobale}/5');
    buffer.writeln();

    // Sezioni del prompt
    for (final sezione in prompt.sezioni) {
      if (sezione.contenuto.isEmpty) continue;

      buffer.writeln('----------------------------------------');
      buffer.writeln('  ${sezione.titolo.toUpperCase()}');
      buffer.writeln('----------------------------------------');
      buffer.writeln(sezione.contenuto);
      buffer.writeln();
    }

    buffer.writeln('========================================');
    buffer.writeln('  Generato con Prompt Master');
    buffer.writeln('========================================');

    return buffer.toString();
  }
}
