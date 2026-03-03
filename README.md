# Quran App (Flutter + Node.js)

## Structure

- `backend/` Node.js Express proxy for Quran API
- `mobile/` Flutter app

## Backend

```bash
cd backend
npm install
npm run dev
```

Runs at `http://localhost:4000`.

Endpoints:

- `GET /health`
- `GET /surah`
- `GET /surah/:id?edition=en.asad`

## Mobile (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

### Backend URL notes

- Android emulator: default is `http://10.0.2.2:4000`
- Real device (same Wi-Fi): set API base URL at runtime, e.g.

```bash
flutter run --dart-define=API_BASE_URL=http://<YOUR_LAPTOP_IP>:4000
```

### Header image

Default header image is a placeholder. You can override:

```bash
flutter run --dart-define=HEADER_IMAGE_URL=https://your-image-url
```
