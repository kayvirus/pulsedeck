# PulseDeck

PulseDeck is a Flutter-based music application focused on local playback first, with federated online discovery layered on top.

## What actually works now

- Import and play local audio files stored on the device.
- Search YouTube and stream playable audio streams.
- Search Apple's public catalog via the iTunes Search API and play preview clips where available.
- Background playback with lock-screen / notification controls.
- Modern Material 3 UI.
- Riverpod-based dependency injection and controller wiring.
- Codemagic configuration for APK generation.

## What is intentionally not faked

A mobile app cannot ship "full Spotify / Apple Music / Audiomack streaming" with zero setup and zero compliance work.

Reasons:
1. Spotify access requires authorization and is not safe to implement with client secrets inside a mobile app.
2. Apple Music full catalog playback requires Apple Music API auth and subscription-aware playback handling. This project only uses the public search API plus preview URLs.
3. Audiomack does not provide the same clean, stable public search/streaming workflow expected for a production-grade no-setup mobile build.

So the project is structured with provider adapters:
- **Working out of the box:** Local library, YouTube, Apple previews
- **Prepared for extension:** Spotify, Audiomack

If you intend to distribute commercially, do a licensing and terms review before release.

## Stack

- Flutter
- Riverpod
- just_audio
- just_audio_background
- youtube_explode_dart
- Dio
- SharedPreferences
- FilePicker
- permission_handler

## Project structure

```text
lib/
  main.dart
  src/
    app.dart
    providers.dart
    models/
    screens/
    services/
    widgets/
```

## How local music works

The app imports audio files selected by the user with the system file picker and persists the imported library index locally. This avoids unreliable broad file-system crawling and behaves better with modern Android storage rules.

## Android permissions

- `READ_MEDIA_AUDIO` for Android 13+
- `READ_EXTERNAL_STORAGE` for older Android versions
- Media playback foreground service permissions for background controls

## Running locally

```bash
flutter pub get
flutter run
```

## Building APK with Codemagic

The included `codemagic.yaml`:
- installs Flutter stable
- restores packages
- generates a Gradle wrapper if missing
- runs `flutter build apk --release`

If you later add signing, wire your keystore secrets in Codemagic and update the release signing block.

## Optional future work

1. Add a backend proxy for Spotify metadata/search with PKCE-authenticated user sessions.
2. Replace simple local import with MediaStore indexing if you want automatic whole-device scanning.
3. Add playlists, favorites, and offline caching.
4. Add waveform rendering and equalizer support.
