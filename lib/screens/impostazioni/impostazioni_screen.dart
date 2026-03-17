import 'package:flutter/material.dart';
import 'package:prompt_master/services/api_service.dart';

/// Schermata impostazioni — permette di configurare la API key OpenAI.
/// Design Apple-minimal con teal come accento.
class ImpostazioniScreen extends StatefulWidget {
  const ImpostazioniScreen({super.key});

  @override
  State<ImpostazioniScreen> createState() => _ImpostazioniScreenState();
}

class _ImpostazioniScreenState extends State<ImpostazioniScreen> {
  final _apiKeyController = TextEditingController();
  bool _mostraApiKey = false;

  @override
  void initState() {
    super.initState();
    // Se la API key è già configurata, mostra un placeholder
    if (ApiService().apiKeyConfigurata) {
      _apiKeyController.text = '••••••••••••••••';
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
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
                                : 'L\'app funziona con dati di esempio. Aggiungi la API key per usare l\'AI vera.',
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

              // Info sull'app
              Center(
                child: Text(
                  'Prompt Master v1.0.0 — Powered by GPT-4o-mini',
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
