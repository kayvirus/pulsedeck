import 'dart:convert';

enum TrackSourceType {
  local,
  youtube,
  applePreview,
  spotify,
  audiomack,
}

class AppTrack {
  const AppTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.sourceType,
    this.album,
    this.artworkUrl,
    this.streamUrl,
    this.filePath,
    this.externalUrl,
    this.durationMs,
  });

  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? artworkUrl;
  final String? streamUrl;
  final String? filePath;
  final String? externalUrl;
  final int? durationMs;
  final TrackSourceType sourceType;

  bool get isPlayable => (filePath != null && filePath!.isNotEmpty) || (streamUrl != null && streamUrl!.isNotEmpty);

  String get subtitle {
    if (album != null && album!.trim().isNotEmpty) {
      return '$artist • $album';
    }
    return artist;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'artworkUrl': artworkUrl,
      'streamUrl': streamUrl,
      'filePath': filePath,
      'externalUrl': externalUrl,
      'durationMs': durationMs,
      'sourceType': sourceType.name,
    };
  }

  factory AppTrack.fromJson(Map<String, dynamic> json) {
    return AppTrack(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Unknown title',
      artist: json['artist'] as String? ?? 'Unknown artist',
      album: json['album'] as String?,
      artworkUrl: json['artworkUrl'] as String?,
      streamUrl: json['streamUrl'] as String?,
      filePath: json['filePath'] as String?,
      externalUrl: json['externalUrl'] as String?,
      durationMs: json['durationMs'] as int?,
      sourceType: TrackSourceType.values.firstWhere(
        (value) => value.name == json['sourceType'],
        orElse: () => TrackSourceType.local,
      ),
    );
  }

  String toEncodedJson() => jsonEncode(toJson());

  factory AppTrack.fromEncodedJson(String source) =>
      AppTrack.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
