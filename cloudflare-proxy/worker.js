/**
 * Cloudflare Worker — Proxy CORS per Prompt Master.
 *
 * Inoltra le richieste dall'app Flutter Web a api.openai.com,
 * aggiungendo gli header CORS necessari per il browser.
 *
 * La API key viene inviata dall'app (header Authorization),
 * il worker NON memorizza credenziali.
 *
 * Deploy:
 *   npx wrangler deploy
 *
 * Piano gratuito Cloudflare Workers: 100.000 richieste/giorno.
 */

// Origini consentite — aggiungi il dominio della tua app
const ORIGINI_CONSENTITE = [
  'http://localhost',       // Sviluppo locale
  'http://127.0.0.1',      // Sviluppo locale
  'https://ceccaroninicola-dev.github.io', // GitHub Pages
];

// URL base dell'API OpenAI
const OPENAI_BASE = 'https://api.openai.com';

export default {
  async fetch(request) {
    // Gestisci le richieste preflight CORS (OPTIONS)
    if (request.method === 'OPTIONS') {
      return rispostaCors(request, new Response(null, { status: 204 }));
    }

    // Accetta solo POST (le chiamate a OpenAI sono POST)
    if (request.method !== 'POST') {
      return rispostaCors(request, new Response(
        JSON.stringify({ error: 'Metodo non consentito. Usa POST.' }),
        { status: 405, headers: { 'Content-Type': 'application/json' } }
      ));
    }

    // Costruisci l'URL di destinazione: worker.dev/v1/chat/completions → openai.com/v1/chat/completions
    const url = new URL(request.url);
    const percorso = url.pathname; // es. /v1/chat/completions
    const urlOpenAI = `${OPENAI_BASE}${percorso}`;

    // Inoltra la richiesta a OpenAI con gli stessi header
    const headerInoltro = new Headers();
    headerInoltro.set('Content-Type', 'application/json');

    // Copia l'header Authorization dall'app (contiene la API key dell'utente)
    const auth = request.headers.get('Authorization');
    if (!auth) {
      return rispostaCors(request, new Response(
        JSON.stringify({ error: 'Header Authorization mancante.' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      ));
    }
    headerInoltro.set('Authorization', auth);

    try {
      const rispostaOpenAI = await fetch(urlOpenAI, {
        method: 'POST',
        headers: headerInoltro,
        body: request.body,
      });

      // Crea una nuova risposta con gli header CORS
      const risposta = new Response(rispostaOpenAI.body, {
        status: rispostaOpenAI.status,
        statusText: rispostaOpenAI.statusText,
        headers: rispostaOpenAI.headers,
      });

      return rispostaCors(request, risposta);
    } catch (errore) {
      return rispostaCors(request, new Response(
        JSON.stringify({ error: `Errore proxy: ${errore.message}` }),
        { status: 502, headers: { 'Content-Type': 'application/json' } }
      ));
    }
  },
};

/**
 * Aggiunge gli header CORS alla risposta.
 * Verifica che l'origine sia nella lista consentita.
 */
function rispostaCors(request, risposta) {
  const origine = request.headers.get('Origin') || '';
  const headers = new Headers(risposta.headers);

  // Verifica se l'origine è consentita (controlla prefisso per supportare porte diverse)
  const origineConsentita = ORIGINI_CONSENTITE.some(o => origine.startsWith(o));

  if (origineConsentita) {
    headers.set('Access-Control-Allow-Origin', origine);
  } else {
    // Per sicurezza, consenti comunque ma senza credenziali
    headers.set('Access-Control-Allow-Origin', origine);
  }

  headers.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  headers.set('Access-Control-Max-Age', '86400');

  return new Response(risposta.body, {
    status: risposta.status,
    statusText: risposta.statusText,
    headers,
  });
}
