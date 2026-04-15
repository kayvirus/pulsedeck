# 🎵 BeatFlow

**Your personal music universe** — A premium Flutter music player for Android with local library management, YouTube streaming, and deep-link support for all major music platforms.

---

## Features

| Feature | Details |
|---|---|
| **Local Music** | Reads all audio files from device storage, sorted by title/artist/album |
| **YouTube Streaming** | Search and stream any song directly from YouTube (audio-only) |
| **Platform Deep Links** | One-tap search on Spotify, Apple Music, Audiomack, SoundCloud, Deezer, TIDAL |
| **Playlists** | Create, manage, and delete custom playlists |
| **Favorites** | Heart any song to save it instantly |
| **Full Player** | Rotating artwork, progress scrubber, shuffle, repeat, queue view |
| **Sleep Timer** | Auto-pause after 15/30/45/60 minutes |
| **Playback Speed** | 0.5× to 2.0× |
| **Background Playback** | Persistent media notification with controls |
| **Mini Player** | Always-visible, swipe up to expand |

---

## Project Structure

```
lib/
├── main.dart                    # App entry, Hive + AudioService init
├── theme/
│   └── app_theme.dart           # Dark luxury color palette, gradients
├── models/
│   ├── song_model.dart          # Song entity (local + YouTube)
│   ├── song_model.g.dart        # Hive adapter (pre-generated)
│   ├── playlist_model.dart      # Playlist entity
│   └── playlist_model.g.dart   # Hive adapter (pre-generated)
├── services/
│   ├── audio_handler.dart       # just_audio + audio_service integration
│   ├── local_music_service.dart # on_audio_query wrapper
│   ├── youtube_service.dart     # youtube_explode_dart search + stream
│   └── external_streaming_service.dart  # Platform deep links
├── providers/
│   ├── player_provider.dart     # Main state: queue, playback, favs, playlists
│   └── search_provider.dart    # Search state across local + YouTube
├── screens/
│   ├── main_shell.dart          # Bottom nav + mini player host
│   ├── library_screen.dart      # Songs / Artists / Albums / Favorites tabs
│   ├── search_screen.dart       # Local / YouTube / Platforms tabs
│   ├── playlists_screen.dart    # Grid + create/delete
│   ├── player_screen.dart       # Full-screen player with rotating art
│   └── settings_screen.dart    # Volume, gapless, about
└── widgets/
    ├── song_tile.dart           # Reusable song row with equalizer animation
    └── mini_player.dart        # Collapsible bottom player strip
```

---

## Setup Instructions

### 1. Prerequisites
- Flutter SDK ≥ 3.10.0
- Android Studio / VS Code
- Java 17 (for Codemagic builds)
- Git

### 2. Add Fonts (Required)

BeatFlow uses **Satoshi** font. Download it free from:
👉 https://www.fontshare.com/fonts/satoshi

Place these files in `assets/fonts/`:
```
assets/fonts/
├── Satoshi-Regular.ttf
├── Satoshi-Medium.ttf
├── Satoshi-Bold.ttf
└── Satoshi-Black.ttf
```

### 3. Add App Icons

Place a 1024×1024 PNG icon as:
```
assets/images/icon.png
```

Then run:
```bash
flutter pub add flutter_launcher_icons --dev
flutter pub run flutter_launcher_icons:main
```

Or manually replace the mipmap drawables in:
```
android/app/src/main/res/mipmap-*/ic_launcher.png
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run Locally

```bash
flutter run
```

---

## Codemagic Build (APK)

### Step 1 — Push to GitHub

```bash
git init
git remote add origin https://github.com/YOUR_USERNAME/beatflow.git
git add .
git commit -m "Initial BeatFlow release"
git push -u origin main
```

### Step 2 — Connect Codemagic

1. Go to [codemagic.io](https://codemagic.io)
2. Click **Add application**
3. Connect your GitHub repo
4. Select **Flutter App**
5. Codemagic detects `codemagic.yaml` automatically
6. Click **Start new build** on the `beatflow-android` workflow

### Step 3 — Download APK

After the build succeeds (~5–10 min), download the APK from the **Artifacts** tab.

---

## YouTube Streaming — How It Works

BeatFlow uses [youtube_explode_dart](https://pub.dev/packages/youtube_explode_dart) which:
- Searches YouTube without an API key
- Extracts audio-only stream URLs on demand
- Streams directly through `just_audio` with buffering

> **Note:** YouTube stream URLs expire after a few hours. If a song fails to play, searching again resolves this.

---

## Platform Streaming — How It Works

For Spotify, Apple Music, Audiomack, SoundCloud, Deezer, and TIDAL:

- BeatFlow generates a search deep link with your query
- Opens the platform's **native app** if installed, or falls back to **browser**
- You need active subscriptions on those platforms to stream

---

## Permissions

| Permission | Purpose |
|---|---|
| `READ_MEDIA_AUDIO` | Read audio files (Android 13+) |
| `READ_EXTERNAL_STORAGE` | Read audio files (Android ≤12) |
| `INTERNET` | YouTube streaming + external platforms |
| `FOREGROUND_SERVICE` | Background audio playback |
| `WAKE_LOCK` | Keep CPU awake during playback |

---

## Customization

### Change App Name
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
android:label="YourAppName"
```

### Change Package Name
Edit `android/app/build.gradle`:
```gradle
applicationId "com.yourname.yourapp"
```

Also update `android/app/src/main/kotlin/.../MainActivity.kt` package declaration.

### Theme Colors
Edit `lib/theme/app_theme.dart` — change `accent`, `accentSecondary`, etc.

---

## Tech Stack

| Package | Version | Purpose |
|---|---|---|
| `just_audio` | 0.9.36 | Audio engine |
| `audio_service` | 0.18.13 | Background playback + notification |
| `on_audio_query` | 2.9.0 | Local music library |
| `youtube_explode_dart` | 2.2.1 | YouTube search + streaming |
| `hive_flutter` | 1.1.0 | Local persistence |
| `provider` | 6.1.2 | State management |
| `permission_handler` | 11.3.0 | Runtime permissions |
| `url_launcher` | 6.2.5 | Platform deep links |
| `marquee` | 2.2.3 | Scrolling text for long titles |

---

## Known Limitations

1. **YouTube streams** are extracted at runtime — there is a small delay (~1–3s) before playback starts
2. **Apple Music / Spotify** require the native app installed for deep links; falls back to browser
3. **Gapless playback** between YouTube tracks has a natural buffering gap
4. Fonts must be added manually (licensing prevents bundling)

---

## License

Private — built for personal use by Kayode. All rights reserved.
Contact for licensing inquiries if distributing commercially.
