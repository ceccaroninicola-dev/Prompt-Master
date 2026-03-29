import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ideai/config/app_routes.dart';
import 'package:ideai/providers/community_provider.dart';
import 'package:ideai/models/prompt_pubblico.dart';

/// Schermata profilo utente — mostra avatar, statistiche e prompt pubblicati.
/// Design Apple-minimal con teal come accento.
class ProfiloScreen extends StatefulWidget {
  const ProfiloScreen({super.key});

  @override
  State<ProfiloScreen> createState() => _ProfiloScreenState();
}

class _ProfiloScreenState extends State<ProfiloScreen> {
  /// Controller per la modifica della bio
  final _bioController = TextEditingController();
  bool _modificandoBio = false;

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final community = Provider.of<CommunityProvider>(context);
    final utente = community.utenteCorrente;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final promptUtente = community.promptUtente;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Il mio profilo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // === AVATAR ===
            CircleAvatar(
              radius: 48,
              backgroundColor: Color(utente.coloreAvatar),
              child: Text(
                utente.nomeCompleto.isNotEmpty
                    ? utente.nomeCompleto[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // === NOME UTENTE ===
            Text(
              utente.nomeUtente,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              utente.nomeCompleto,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),

            // === BIO ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _modificandoBio
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _bioController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Scrivi la tua bio...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            community.aggiornaProfilo(
                                bio: _bioController.text);
                            setState(() => _modificandoBio = false);
                          },
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () {
                        _bioController.text = utente.bio;
                        setState(() => _modificandoBio = true);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              utente.bio,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // === STATISTICHE ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatistica(
                      context,
                      '${utente.promptPubblicati}',
                      'Prompt',
                      colorScheme,
                    ),
                    Container(
                      height: 32,
                      width: 1,
                      color: colorScheme.outlineVariant,
                    ),
                    _buildStatistica(
                      context,
                      '${utente.likeRicevuti}',
                      'Like',
                      colorScheme,
                    ),
                    Container(
                      height: 32,
                      width: 1,
                      color: colorScheme.outlineVariant,
                    ),
                    _buildStatistica(
                      context,
                      '${utente.forkRicevuti}',
                      'Fork',
                      colorScheme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // === MEMBRO DAL ===
            Text(
              'Membro dal ${_formatData(utente.dataIscrizione)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),

            // === I MIEI PROMPT ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'I miei prompt',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${promptUtente.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (promptUtente.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nessun prompt pubblicato',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Crea un prompt e pubblicalo nella community!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: promptUtente.length,
                itemBuilder: (context, index) {
                  return _buildPromptCard(
                    context,
                    promptUtente[index],
                    colorScheme,
                    isDark,
                  );
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Widget per una singola statistica
  Widget _buildStatistica(
    BuildContext context,
    String valore,
    String etichetta,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Text(
          valore,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          etichetta,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  /// Card per un prompt dell'utente
  Widget _buildPromptCard(
    BuildContext context,
    PromptPubblico prompt,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.dettaglioPromptPubblico,
              arguments: prompt.id,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        prompt.titolo,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    // Badge visibilità
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _coloreVisibilita(prompt.visibilita)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _testoVisibilita(prompt.visibilita),
                        style: TextStyle(
                          fontSize: 11,
                          color: _coloreVisibilita(prompt.visibilita),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  prompt.descrizione,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.favorite, size: 14, color: Colors.red[300]),
                    const SizedBox(width: 4),
                    Text('${prompt.numerLike}',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 12),
                    Icon(Icons.fork_right,
                        size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${prompt.numeroFork}',
                        style: Theme.of(context).textTheme.bodySmall),
                    const Spacer(),
                    // Stelle
                    Icon(Icons.star, size: 14, color: Colors.amber[600]),
                    const SizedBox(width: 2),
                    Text(
                      prompt.punteggio.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Colore del badge di visibilità
  Color _coloreVisibilita(Visibilita v) {
    switch (v) {
      case Visibilita.privato:
        return Colors.grey;
      case Visibilita.soloLink:
        return Colors.orange;
      case Visibilita.pubblico:
        return Colors.green;
    }
  }

  /// Testo del badge di visibilità
  String _testoVisibilita(Visibilita v) {
    switch (v) {
      case Visibilita.privato:
        return 'Privato';
      case Visibilita.soloLink:
        return 'Solo link';
      case Visibilita.pubblico:
        return 'Pubblico';
    }
  }

  /// Formatta una data in modo leggibile
  String _formatData(DateTime data) {
    const mesi = [
      'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
      'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
    ];
    return '${mesi[data.month - 1]} ${data.year}';
  }
}
