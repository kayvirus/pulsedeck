import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

import '../models/app_track.dart';
import 'settings_service.dart';

class LocalLibraryService {
  LocalLibraryService(this._settingsService);

  final SettingsService _settingsService;

  static const _extensions = <String>[
    'mp3',
    'm4a',
    'aac',
    'wav',
    'flac',
    'ogg',
    'opus',
  ];

  Future<bool> requestLibraryAccess() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final audioStatus = await Permission.audio.request();
      if (audioStatus.isGranted || audioStatus.isLimited) {
        return true;
      }
    } catch (_) {
      // Ignore and fall back.
    }

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted || storageStatus.isLimited;
  }

  Future<List<AppTrack>> loadSavedLibrary() async {
    final encoded = await _settingsService.readLibrary();
    return encoded.map(AppTrack.fromEncodedJson).toList();
  }

  Future<List<AppTrack>> importTracks() async {
    await requestLibraryAccess();

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: _extensions,
    );

    if (result == null || result.files.isEmpty) {
      return loadSavedLibrary();
    }

    final existing = await loadSavedLibrary();
    final byId = <String, AppTrack>{for (final track in existing) track.id: track};

    for (final file in result.files) {
      final path = file.path;
      if (path == null || path.trim().isEmpty) {
        continue;
      }

      final basename = p.basenameWithoutExtension(path);
      final artistTitle = _splitArtistTitle(basename);

      final track = AppTrack(
        id: path,
        title: artistTitle.$2,
        artist: artistTitle.$1,
        album: 'Imported file',
        filePath: path,
        sourceType: TrackSourceType.local,
      );

      byId[track.id] = track;
    }

    final merged = byId.values.toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    await _settingsService.saveLibrary(
      merged.map((track) => track.toEncodedJson()).toList(),
    );

    return merged;
  }

  Future<void> removeTrack(String id) async {
    final current = await loadSavedLibrary();
    final filtered = current.where((track) => track.id != id).toList();
    await _settingsService.saveLibrary(
      filtered.map((track) => track.toEncodedJson()).toList(),
    );
  }

  (String, String) _splitArtistTitle(String raw) {
    final normalized = raw.replaceAll('_', ' ').trim();
    if (normalized.contains(' - ')) {
      final parts = normalized.split(' - ');
      if (parts.length >= 2) {
        return (parts.first.trim(), parts.sublist(1).join(' - ').trim());
      }
    }
    return ('Local file', normalized);
  }
}
