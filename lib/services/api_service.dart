import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

/// Servizio centralizzato per le chiamate all'API OpenAI (GPT-4o-mini).
///
/// Usa SEMPRE il proxy Cloudflare Worker come endpoint di default
/// (sia su web per CORS, sia su mobile per nascondere la key).
/// Il worker ha una API key di default configurata come secret, così
/// i beta tester possono usare l'AI senza configurare nulla manualmente.
class ApiService {
  /// Singleton del servizio
  static final ApiService _istanza = ApiService._interno();
  factory ApiService() => _istanza;
  ApiService._interno();

  /// URL del proxy Cloudflare Worker di default — usato da tutte le
  /// piattaforme quando l'utente NON ha inserito una sua API key.
  /// Il worker inietta automaticamente la sua key di default.
  static const _proxyDefault =
      'https://prompt-master-proxy.prompt-master-proxy.workers.dev';

  /// Proxy CORS — URL del Cloudflare Worker (personalizzabile dall'utente).
  /// Se vuoto, usa _proxyDefault.
  String _corsProxy = '';

  /// Modello da utilizzare
  static const _modello = 'gpt-4o-mini';

  /// API key opzionale dell'utente — se impostata, viene inviata al proxy
  /// tramite header Authorization (il proxy la userà al posto della sua key).
  /// Se null, il proxy userà la sua key di default.
  String? _apiKey;

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

  /// Verifica se la API key utente è configurata (opzionale)
  bool get apiKeyConfigurata => _apiKey != null && _apiKey!.isNotEmpty;

  /// Verifica se un proxy CORS personalizzato è configurato
  bool get proxyConfigurato => _corsProxy.isNotEmpty;

  /// Restituisce l'URL base per le chiamate API.
  /// Usa il proxy personalizzato se configurato, altrimenti il proxy
  /// di default (che inietta automaticamente la API key).
  String get _urlBase {
    if (_corsProxy.isNotEmpty) {
      return _corsProxy;
    }
    return _proxyDefault;
  }

  /// Costruisce gli header per la richiesta.
  /// Se l'utente ha inserito una sua API key, la invia al proxy;
  /// altrimenti il proxy userà la sua key di default (beta tester).
  Map<String, String> _costruisciHeader() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (apiKeyConfigurata) {
      headers['Authorization'] = 'Bearer $_apiKey';
    }
    return headers;
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
    final url = '$_urlBase/v1/chat/completions';
    debugPrint('[ApiService] chiamaAI → $url (userKey: $apiKeyConfigurata)');

    try {
      final risposta = await http
          .post(
            Uri.parse(url),
            headers: _costruisciHeader(),
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
      throw ApiException(
          'Errore di connessione. Verifica la tua connessione internet '
          'e riprova.');
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
    final url = '$_urlBase/v1/chat/completions';
    debugPrint('[ApiService] chiamaAIJson → $url (userKey: $apiKeyConfigurata)');

    try {
      final risposta = await http
          .post(
            Uri.parse(url),
            headers: _costruisciHeader(),
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
      throw ApiException(
          'Errore di connessione. Verifica la tua connessione internet '
          'e riprova.');
    }
  }

  /// Testa la connessione al proxy inviando una richiesta minima.
  /// Restituisce un messaggio di successo o errore user-friendly.
  Future<String> testaProxy() async {
    try {
      final url = '$_urlBase/v1/chat/completions';
      final risposta = await http
          .post(
            Uri.parse(url),
            headers: _costruisciHeader(),
            body: jsonEncode({
              'model': _modello,
              'messages': [
                {'role': 'user', 'content': 'ping'},
              ],
              'max_tokens': 1,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (risposta.statusCode == 200) {
        return 'Proxy funzionante! Connessione perfetta.';
      }
      if (risposta.statusCode == 401) {
        return 'Proxy raggiungibile ma API key non valida.';
      }
      return 'Proxy raggiungibile (codice ${risposta.statusCode}).';
    } catch (e) {
      return 'Impossibile raggiungere il proxy: $e';
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
