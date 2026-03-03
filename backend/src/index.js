import express from 'express';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 4000;
const QURAN_API_BASE = 'https://api.alquran.cloud/v1';

async function fetchJson(url) {
  const res = await fetch(url);
  if (!res.ok) {
    const text = await res.text().catch(() => '');
    throw new Error(`Upstream error ${res.status} ${res.statusText}: ${text}`);
  }
  return res.json();
}

app.get('/health', (req, res) => {
  res.json({ ok: true });
});

app.get('/surah', async (req, res) => {
  try {
    const data = await fetchJson(`${QURAN_API_BASE}/surah`);
    res.json(data);
  } catch (err) {
    res.status(502).json({ error: 'Failed to fetch surah list', detail: String(err?.message || err) });
  }
});

app.get('/surah/:id', async (req, res) => {
  const { id } = req.params;
  const edition = req.query.edition || 'en.asad';

  try {
    const [arabic, translation] = await Promise.all([
      fetchJson(`${QURAN_API_BASE}/surah/${encodeURIComponent(id)}`),
      fetchJson(`${QURAN_API_BASE}/surah/${encodeURIComponent(id)}/${encodeURIComponent(edition)}`)
    ]);

    res.json({ arabic, translation, edition });
  } catch (err) {
    res.status(502).json({ error: 'Failed to fetch surah detail', detail: String(err?.message || err) });
  }
});

app.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`Backend listening on http://localhost:${PORT}`);
});
