import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servizio centralizzato per le chiamate all'API OpenAI (GPT-4o-mini).
/// La API key viene letta dalla configurazione — MAI hardcoded nel codice.
class ApiService {
  /// Singleton del servizio
  static final ApiService _istanza = ApiService._interno();
  factory ApiService() => _istanza;
  ApiService._interno();

  /// Endpoint API OpenAI
  static const _baseUrl = 'https://api.openai.com/v1/chat/completions';

  /// Modello da utilizzare
  static const _modello = 'gpt-4o-mini';

  /// API key — impostata dall'esterno (variabile d'ambiente o configurazione)
  String? _apiKey;

  /// Imposta la API key
  void impostaApiKey(String key) {
    _apiKey = key;
  }

  /// Verifica se la API key è configurata
  bool get apiKeyConfigurata => _apiKey != null && _apiKey!.isNotEmpty;

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

    try {
      final risposta = await http
          .post(
            Uri.parse(_baseUrl),
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

      if (risposta.statusCode == 200) {
        final json = jsonDecode(risposta.body);
        return json['choices'][0]['message']['content'] as String;
      } else if (risposta.statusCode == 401) {
        throw ApiException('API key non valida. Verificala nelle impostazioni.');
      } else if (risposta.statusCode == 429) {
        throw ApiException(
            'Troppe richieste. Riprova tra qualche secondo.');
      } else {
        throw ApiException(
            'Errore dal server (${risposta.statusCode}). Riprova più tardi.');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
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

    try {
      final risposta = await http
          .post(
            Uri.parse(_baseUrl),
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

      if (risposta.statusCode == 200) {
        final json = jsonDecode(risposta.body);
        final contenuto = json['choices'][0]['message']['content'] as String;
        return jsonDecode(contenuto) as Map<String, dynamic>;
      } else if (risposta.statusCode == 401) {
        throw ApiException('API key non valida. Verificala nelle impostazioni.');
      } else if (risposta.statusCode == 429) {
        throw ApiException(
            'Troppe richieste. Riprova tra qualche secondo.');
      } else {
        throw ApiException(
            'Errore dal server (${risposta.statusCode}). Riprova più tardi.');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
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
