import express from 'express';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 4000;
const QURAN_API_BASE = 'https://api.alquran.cloud/v1';

// ── Supported translation editions ──────────────────────────────────────────
const SUPPORTED_EDITIONS = new Set(['en.asad', 'id.indonesian']);
const DEFAULT_EDITION = 'en.asad';

// ── In-memory cache ──────────────────────────────────────────────────────────
const cache = new Map();
const CACHE_TTL_MS = 24 * 60 * 60 * 1000;

function cacheGet(key) {
  const entry = cache.get(key);
  if (!entry) return null;
  if (Date.now() - entry.ts > CACHE_TTL_MS) { cache.delete(key); return null; }
  return entry.data;
}
function cacheSet(key, data) { cache.set(key, { data, ts: Date.now() }); }

const FETCH_TIMEOUT_MS = 10_000;

async function fetchJson(url) {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), FETCH_TIMEOUT_MS);
  try {
    const res = await fetch(url, { signal: ctrl.signal });
    if (!res.ok) {
      const text = await res.text().catch(() => '');
      throw new Error(`Upstream ${res.status} ${res.statusText}: ${text}`);
    }
    return res.json();
  } finally {
    clearTimeout(timer);
  }
}

function staticCacheHeaders(res) {
  res.set('Cache-Control', 'public, max-age=3600, s-maxage=86400');
}

app.get('/health', (_req, res) => res.json({ ok: true }));

app.get('/surah', async (_req, res) => {
  const key = 'surah_list';
  const cached = cacheGet(key);
  if (cached) { staticCacheHeaders(res); return res.json(cached); }

  try {
    const data = await fetchJson(`${QURAN_API_BASE}/surah`);
    cacheSet(key, data);
    staticCacheHeaders(res);
    res.json(data);
  } catch (err) {
    res.status(502).json({ error: 'Failed to fetch surah list', detail: String(err?.message || err) });
  }
});

app.get('/surah/:id', async (req, res) => {
  const { id } = req.params;

  const edition = SUPPORTED_EDITIONS.has(req.query.edition)
    ? req.query.edition
    : DEFAULT_EDITION;

  const key = `surah_${id}_${edition}`;
  const cached = cacheGet(key);
  if (cached) { staticCacheHeaders(res); return res.json(cached); }

  try {
    const [arabic, translation, transliteration] = await Promise.all([
      fetchJson(`${QURAN_API_BASE}/surah/${encodeURIComponent(id)}`),
      fetchJson(`${QURAN_API_BASE}/surah/${encodeURIComponent(id)}/${encodeURIComponent(edition)}`),
      fetchJson(`${QURAN_API_BASE}/surah/${encodeURIComponent(id)}/en.transliteration`),
    ]);

    const payload = { arabic, translation, transliteration, edition };
    cacheSet(key, payload);
    staticCacheHeaders(res);
    res.json(payload);
  } catch (err) {
    res.status(502).json({ error: 'Failed to fetch surah detail', detail: String(err?.message || err) });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend listening on http://0.0.0.0:${PORT}`);
});