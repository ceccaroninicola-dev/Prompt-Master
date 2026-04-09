import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ideai/services/api_service.dart';

/// Schermata impostazioni — permette di configurare la API key OpenAI
/// e il proxy CORS per Flutter Web.
/// Design Apple-minimal con teal come accento.
class ImpostazioniScreen extends StatefulWidget {
  const ImpostazioniScreen({super.key});

  @override
  State<ImpostazioniScreen> createState() => _ImpostazioniScreenState();
}

class _ImpostazioniScreenState extends State<ImpostazioniScreen> {
  final _apiKeyController = TextEditingController();
  final _corsProxyController = TextEditingController();
  bool _mostraApiKey = false;
  bool _staTesting = false;
  bool _staTestandoProxy = false;
  String? _risultatoTest;
  String? _risultatoTestProxy;

  /// Versione dell'app letta dal pacchetto (es. "1.0.5+6").
  /// Inizializzata in initState per aggiornarsi automaticamente
  /// ad ogni release senza toccare il codice.
  String _versioneApp = '';

  @override
  void initState() {
    super.initState();
    // Se la API key è già configurata, mostra un placeholder
    if (ApiService().apiKeyConfigurata) {
      _apiKeyController.text = '••••••••••••••••';
    }
    // Pre-compila il proxy se già configurato
    if (ApiService().corsProxy.isNotEmpty) {
      _corsProxyController.text = ApiService().corsProxy;
    }
    // Carica la versione dell'app (asincrono)
    _caricaVersione();
  }

  /// Legge la versione dell'app da package_info_plus.
  /// Su errore o piattaforme non supportate, lascia il campo vuoto.
  Future<void> _caricaVersione() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _versioneApp = info.version);
      }
    } catch (_) {
      // Silenzioso: mostreremo solo "IdeAI" senza versione
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _corsProxyController.dispose();
    super.dispose();
  }

  /// Testa la connessione al proxy CORS
  Future<void> _testaProxy() async {
    setState(() {
      _staTestandoProxy = true;
      _risultatoTestProxy = null;
    });

    final risultato = await ApiService().testaProxy();
    setState(() {
      _risultatoTestProxy = risultato;
      _staTestandoProxy = false;
    });
  }

  /// Testa la connessione API con una chiamata reale
  Future<void> _testaConnessione() async {
    setState(() {
      _staTesting = true;
      _risultatoTest = null;
    });

    try {
      final risultato = await ApiService().chiamaAI(
        systemPrompt: 'Rispondi solo con "OK" senza altro testo.',
        messaggioUtente: 'Test di connessione.',
        temperature: 0.0,
        maxTokens: 10,
      );
      setState(() {
        _risultatoTest = 'Connessione riuscita! Risposta: $risultato';
      });
    } on ApiException catch (e) {
      setState(() {
        _risultatoTest = 'Errore: ${e.messaggio}';
      });
    }

    setState(() => _staTesting = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final apiConfigurata = ApiService().apiKeyConfigurata;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === STATO API ===
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: apiConfigurata
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: apiConfigurata
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      apiConfigurata
                          ? Icons.check_circle
                          : Icons.info_outline,
                      color: apiConfigurata ? Colors.green : Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apiConfigurata
                                ? 'AI connessa'
                                : 'Modalità offline',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: apiConfigurata
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            apiConfigurata
                                ? 'GPT-4o-mini attivo per analisi e generazione'
                                : 'L\'app funziona con dati di esempio. '
                                    'Aggiungi la API key per usare l\'AI vera.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // === API KEY ===
              Text(
                'API Key OpenAI',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Inserisci la tua API key per attivare GPT-4o-mini. '
                'La chiave resta solo sul tuo dispositivo.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),

              // Campo API key
              TextField(
                controller: _apiKeyController,
                obscureText: !_mostraApiKey,
                decoration: InputDecoration(
                  hintText: 'sk-...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  suffixIcon: IconButton(
                    icon: Icon(_mostraApiKey
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() => _mostraApiKey = !_mostraApiKey);
                    },
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // Bottone salva
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _apiKeyController.text.isNotEmpty &&
                          _apiKeyController.text != '••••••••••••••••'
                      ? () {
                          final key = _apiKeyController.text.trim();
                          if (key.isNotEmpty && key.startsWith('sk-')) {
                            ApiService().impostaApiKey(key);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('API key salvata! L\'AI è attiva.'),
                                  ],
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'La API key deve iniziare con "sk-"'),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salva API Key'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // === PROXY CORS (solo su web) ===
              if (kIsWeb) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ApiService().proxyConfigurato
                        ? Colors.green.withValues(alpha: 0.08)
                        : Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ApiService().proxyConfigurato
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            ApiService().proxyConfigurato
                                ? Icons.cloud_done
                                : Icons.cloud_off,
                            size: 18,
                            color: ApiService().proxyConfigurato
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ApiService().proxyConfigurato
                                ? 'Proxy CORS attivo'
                                : 'Proxy CORS richiesto',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: ApiService().proxyConfigurato
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Su web, il browser blocca le chiamate dirette a OpenAI (CORS). '
                        'Inserisci l\'URL del tuo Cloudflare Worker proxy.\n'
                        'Es: https://prompt-master-proxy.tuoaccount.workers.dev',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _corsProxyController,
                        decoration: InputDecoration(
                          hintText:
                              'https://prompt-master-proxy.tuoaccount.workers.dev',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _corsProxyController.text.isNotEmpty
                                  ? () {
                                      ApiService().impostaCorsProxy(
                                          _corsProxyController.text.trim());
                                      setState(() {});
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              'Proxy CORS salvato!'),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.save_outlined, size: 18),
                              label: const Text('Salva'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: ApiService().proxyConfigurato &&
                                      !_staTestandoProxy
                                  ? _testaProxy
                                  : null,
                              icon: _staTestandoProxy
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.wifi_find, size: 18),
                              label: Text(_staTestandoProxy
                                  ? 'Testando...'
                                  : 'Testa proxy'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Risultato test proxy
                      if (_risultatoTestProxy != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _risultatoTestProxy!.contains('funzionante')
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _risultatoTestProxy!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _risultatoTestProxy!
                                              .contains('funzionante')
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                    ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // === TESTA CONNESSIONE ===
              if (apiConfigurata)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _staTesting ? null : _testaConnessione,
                    icon: _staTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_find, size: 18),
                    label: Text(
                        _staTesting ? 'Testando...' : 'Testa connessione'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

              // Risultato test
              if (_risultatoTest != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _risultatoTest!.startsWith('Connessione')
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _risultatoTest!.startsWith('Connessione')
                            ? Icons.check_circle
                            : Icons.error_outline,
                        size: 18,
                        color: _risultatoTest!.startsWith('Connessione')
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _risultatoTest!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: _risultatoTest!
                                        .startsWith('Connessione')
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // === INFO ===
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline,
                            size: 18, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Come ottenere una API key',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Vai su platform.openai.com\n'
                      '2. Crea un account o accedi\n'
                      '3. Vai su API Keys\n'
                      '4. Crea una nuova chiave\n'
                      '5. Copiala qui',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info sull'app — la versione viene letta dinamicamente
              // da package_info_plus (aggiornata ad ogni release)
              Center(
                child: Text(
                  _versioneApp.isEmpty
                      ? 'IdeAI — Powered by GPT-4o-mini'
                      : 'IdeAI v$_versioneApp — Powered by GPT-4o-mini',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
