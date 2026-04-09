import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;

/// Servizio centralizzato per le chiamate all'API OpenAI (GPT-4o-mini).
///
/// Su Flutter Web, le chiamate dirette a api.openai.com sono bloccate
/// dal browser (CORS). Il servizio usa automaticamente un proxy CORS
/// configurabile (Cloudflare Worker) per aggirare il problema.
class ApiService {
  /// Singleton del servizio
  static final ApiService _istanza = ApiService._interno();
  factory ApiService() => _istanza;
  ApiService._interno();

  /// Endpoint API OpenAI (usato su mobile/desktop)
  static const _endpointOpenAI = 'https://api.openai.com';

  /// Proxy CORS per Flutter Web — URL del Cloudflare Worker.
  /// Su web è OBBLIGATORIO per evitare il blocco CORS del browser.
  /// Formato: "https://prompt-master-proxy.TUOACCOUNT.workers.dev"
  String _corsProxy = '';

  /// Modello da utilizzare
  static const _modello = 'gpt-4o-mini';

  /// API key di default letta a compile-time da --dart-define=OPENAI_API_KEY=...
  /// Su GitHub Actions viene passata automaticamente dal secret OPENAI_API_KEY.
  /// Se vuota, l'utente può inserirla manualmente dalle Impostazioni.
  /// Permette all'AI di funzionare SENZA configurazione manuale per i beta
  /// tester, senza mai esporre la key nel codice sorgente del repository.
  static const _apiKeyDefault =
      String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

  /// API key attuale — inizializzata con la key di default da --dart-define,
  /// può essere sovrascritta tramite impostaApiKey() dalle impostazioni.
  String? _apiKey = _apiKeyDefault.isNotEmpty ? _apiKeyDefault : null;

  /// Imposta la API key
  void impostaApiKey(String key) {
    _apiKey = key;
    debugPrint('[ApiService] API key impostata (${key.substring(0, 7)}...)');
  }

  /// Imposta il proxy CORS (solo per Flutter Web)
  void impostaCorsProxy(String proxyUrl) {
    // Rimuovi trailing slash per evitare doppie barre
    _corsProxy = proxyUrl.endsWith('/')
        ? proxyUrl.substring(0, proxyUrl.length - 1)
        : proxyUrl;
    debugPrint('[ApiService] CORS proxy impostato: $_corsProxy');
  }

  /// Restituisce il proxy CORS attuale
  String get corsProxy => _corsProxy;

  /// Verifica se la API key è configurata
  bool get apiKeyConfigurata => _apiKey != null && _apiKey!.isNotEmpty;

  /// Verifica se il proxy CORS è configurato (necessario su web)
  bool get proxyConfigurato => _corsProxy.isNotEmpty;

  /// Restituisce l'URL base per le chiamate API.
  /// Su web usa il proxy CORS, su mobile/desktop va diretto a OpenAI.
  String get _urlBase {
    if (kIsWeb && _corsProxy.isNotEmpty) {
      return _corsProxy;
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

    _verificaProxy();

    final url = '$_urlBase/v1/chat/completions';
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
      if (kIsWeb && !proxyConfigurato) {
        throw ApiException(
            'Errore CORS: configura il proxy nelle impostazioni. '
            'Su Flutter Web è necessario un proxy CORS (Cloudflare Worker) '
            'per comunicare con OpenAI.');
      }
      if (kIsWeb) {
        throw ApiException(
            'Errore di connessione al proxy CORS. '
            'Verifica che l\'URL del proxy sia corretto: $_corsProxy');
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

    _verificaProxy();

    final url = '$_urlBase/v1/chat/completions';
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
      if (kIsWeb && !proxyConfigurato) {
        throw ApiException(
            'Errore CORS: configura il proxy nelle impostazioni. '
            'Su Flutter Web è necessario un proxy CORS (Cloudflare Worker) '
            'per comunicare con OpenAI.');
      }
      if (kIsWeb) {
        throw ApiException(
            'Errore di connessione al proxy CORS. '
            'Verifica che l\'URL del proxy sia corretto: $_corsProxy');
      }
      throw ApiException(
          'Errore di connessione. Verifica la tua connessione internet.');
    }
  }

  /// Testa la connessione al proxy CORS (solo su web).
  /// Restituisce un messaggio di successo o errore.
  Future<String> testaProxy() async {
    if (!kIsWeb) return 'Non necessario: non sei su web.';
    if (!proxyConfigurato) return 'Proxy non configurato.';

    try {
      // Invia una richiesta OPTIONS al proxy per verificare i CORS
      final url = '$_corsProxy/v1/chat/completions';
      final risposta = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer test-connection',
            },
            body: jsonEncode({
              'model': _modello,
              'messages': [
                {'role': 'user', 'content': 'test'},
              ],
              'max_tokens': 1,
            }),
          )
          .timeout(const Duration(seconds: 10));

      // 401 = il proxy funziona, ma la API key "test-connection" è invalida
      // Questo è il risultato atteso: il proxy ha inoltrato correttamente
      if (risposta.statusCode == 401) {
        return 'Proxy CORS funzionante! La connessione è OK.';
      }
      if (risposta.statusCode == 200) {
        return 'Proxy CORS funzionante! Connessione perfetta.';
      }
      return 'Proxy raggiungibile ma ha risposto con errore ${risposta.statusCode}.';
    } catch (e) {
      return 'Impossibile raggiungere il proxy: $e';
    }
  }

  /// Verifica che il proxy sia configurato su web, altrimenti lancia eccezione.
  void _verificaProxy() {
    if (kIsWeb && !proxyConfigurato) {
      throw ApiException(
          'Su Flutter Web è necessario configurare il proxy CORS. '
          'Vai nelle impostazioni e inserisci l\'URL del tuo Cloudflare Worker.');
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
