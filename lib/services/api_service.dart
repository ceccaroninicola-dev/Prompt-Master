import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;

/// Servizio centralizzato per le chiamate all'API OpenAI (GPT-4o-mini).
/// La API key viene letta dalla configurazione — MAI hardcoded nel codice.
///
/// Su Flutter Web, le chiamate dirette a api.openai.com sono bloccate
/// dal browser (CORS). Il servizio usa un proxy CORS configurabile.
class ApiService {
  /// Singleton del servizio
  static final ApiService _istanza = ApiService._interno();
  factory ApiService() => _istanza;
  ApiService._interno();

  /// Endpoint API OpenAI
  static const _endpointOpenAI = 'https://api.openai.com/v1/chat/completions';

  /// Proxy CORS per Flutter Web — configurabile dall'utente.
  /// Se vuoto, le chiamate vanno direttamente a OpenAI (funziona su mobile, non su web).
  /// Formato: "https://mio-proxy.com/" — il proxy prefissa l'URL OpenAI.
  String? _corsProxy;

  /// Modello da utilizzare
  static const _modello = 'gpt-4o-mini';

  /// API key — impostata dall'esterno (variabile d'ambiente o configurazione)
  String? _apiKey;

  /// Imposta la API key
  void impostaApiKey(String key) {
    _apiKey = key;
    debugPrint('[ApiService] API key impostata (${key.substring(0, 7)}...)');
  }

  /// Imposta il proxy CORS (solo per Flutter Web)
  void impostaCorsProxy(String proxyUrl) {
    _corsProxy = proxyUrl;
    debugPrint('[ApiService] CORS proxy impostato: $proxyUrl');
  }

  /// Verifica se la API key è configurata
  bool get apiKeyConfigurata => _apiKey != null && _apiKey!.isNotEmpty;

  /// Restituisce l'URL effettivo per le chiamate API.
  /// Su web usa il proxy CORS se configurato.
  String get _urlEffettivo {
    if (kIsWeb && _corsProxy != null && _corsProxy!.isNotEmpty) {
      // Il proxy CORS prefissa l'URL di destinazione
      return '$_corsProxy$_endpointOpenAI';
    }
    return _endpointOpenAI;
  }

  /// Effettua una chiamata all'API OpenAI con il system prompt e il messaggio utente.
  /// Restituisce il contenuto testuale della risposta.
  /// Lancia [ApiException] in caso di errore.
  Future<String> chiamaAI({
    required String systemPrompt,
    required String messaggioUtente,
    double temperature = 0.7,
    int maxTokens = 2000,
  }) async {
    if (!apiKeyConfigurata) {
      throw ApiException('API key non configurata. '
          'Imposta la variabile d\'ambiente OPENAI_API_KEY.');
    }

    final url = _urlEffettivo;
    debugPrint('[ApiService] chiamaAI → $url');

    try {
      final risposta = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _modello,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': messaggioUtente},
              ],
              'temperature': temperature,
              'max_tokens': maxTokens,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[ApiService] Risposta: ${risposta.statusCode}');

      if (risposta.statusCode == 200) {
        final json = jsonDecode(risposta.body);
        return json['choices'][0]['message']['content'] as String;
      } else if (risposta.statusCode == 401) {
        throw ApiException('API key non valida. Verificala nelle impostazioni.');
      } else if (risposta.statusCode == 429) {
        throw ApiException(
            'Troppe richieste. Riprova tra qualche secondo.');
      } else {
        debugPrint('[ApiService] Errore body: ${risposta.body}');
        throw ApiException(
            'Errore dal server (${risposta.statusCode}). Riprova più tardi.');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[ApiService] Eccezione: $e');
      // Su Flutter Web, l'errore CORS appare come XMLHttpRequest error
      if (kIsWeb) {
        throw ApiException(
            'Errore CORS: il browser blocca le chiamate dirette a OpenAI. '
            'Configura un proxy CORS nelle impostazioni, '
            'oppure usa l\'app su mobile/desktop.');
      }
      throw ApiException(
          'Errore di connessione. Verifica la tua connessione internet.');
    }
  }

  /// Effettua una chiamata e restituisce la risposta come JSON parsato.
  /// Il system prompt deve istruire l'AI a rispondere in formato JSON.
  Future<Map<String, dynamic>> chiamaAIJson({
    required String systemPrompt,
    required String messaggioUtente,
    double temperature = 0.7,
    int maxTokens = 2000,
  }) async {
    if (!apiKeyConfigurata) {
      throw ApiException('API key non configurata. '
          'Imposta la variabile d\'ambiente OPENAI_API_KEY.');
    }

    final url = _urlEffettivo;
    debugPrint('[ApiService] chiamaAIJson → $url');

    try {
      final risposta = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _modello,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': messaggioUtente},
              ],
              'temperature': temperature,
              'max_tokens': maxTokens,
              'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[ApiService] Risposta JSON: ${risposta.statusCode}');

      if (risposta.statusCode == 200) {
        final json = jsonDecode(risposta.body);
        final contenuto = json['choices'][0]['message']['content'] as String;
        debugPrint('[ApiService] Contenuto ricevuto: ${contenuto.length} chars');
        return jsonDecode(contenuto) as Map<String, dynamic>;
      } else if (risposta.statusCode == 401) {
        throw ApiException('API key non valida. Verificala nelle impostazioni.');
      } else if (risposta.statusCode == 429) {
        throw ApiException(
            'Troppe richieste. Riprova tra qualche secondo.');
      } else {
        debugPrint('[ApiService] Errore body: ${risposta.body}');
        throw ApiException(
            'Errore dal server (${risposta.statusCode}). Riprova più tardi.');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[ApiService] Eccezione JSON: $e');
      if (kIsWeb) {
        throw ApiException(
            'Errore CORS: il browser blocca le chiamate dirette a OpenAI. '
            'Configura un proxy CORS nelle impostazioni, '
            'oppure usa l\'app su mobile/desktop.');
      }
      throw ApiException(
          'Errore di connessione. Verifica la tua connessione internet.');
    }
  }
}

/// Eccezione personalizzata per errori API con messaggio user-friendly
class ApiException implements Exception {
  final String messaggio;
  const ApiException(this.messaggio);

  @override
  String toString() => messaggio;
}
