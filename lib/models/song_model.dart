import 'package:hive/hive.dart';

part 'song_model.g.dart';

enum SongSource { local, youtube, spotify, appleMusic, audiomack, soundcloud }

@HiveType(typeId: 0)
class Song extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String album;

  @HiveField(4)
  final String? albumArt; // URI or URL

  @HiveField(5)
  final String uri; // file path or stream URL

  @HiveField(6)
  final int duration; // milliseconds

  @HiveField(7)
  final String sourceStr;

  @HiveField(8)
  final int? localId; // on_audio_query id

  @HiveField(9)
  bool isFavorite;

  @HiveField(10)
  int playCount;

  @HiveField(11)
  final String? youtubeVideoId;

  @HiveField(12)
  final String? externalUrl;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album = 'Unknown Album',
    this.albumArt,
    required this.uri,
    required this.duration,
    required this.sourceStr,
    this.localId,
    this.isFavorite = false,
    this.playCount = 0,
    this.youtubeVideoId,
    this.externalUrl,
  });

  SongSource get source {
    switch (sourceStr) {
      case 'youtube': return SongSource.youtube;
      case 'spotify': return SongSource.spotify;
      case 'appleMusic': return SongSource.appleMusic;
      case 'audiomack': return SongSource.audiomack;
      case 'soundcloud': return SongSource.soundcloud;
      default: return SongSource.local;
    }
  }

  String get durationFormatted {
    final ms = duration;
    final minutes = (ms / 60000).floor();
    final seconds = ((ms % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumArt,
    String? uri,
    int? duration,
    String? sourceStr,
    int? localId,
    bool? isFavorite,
    int? playCount,
    String? youtubeVideoId,
    String? externalUrl,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArt: albumArt ?? this.albumArt,
      uri: uri ?? this.uri,
      duration: duration ?? this.duration,
      sourceStr: sourceStr ?? this.sourceStr,
      localId: localId ?? this.localId,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      externalUrl: externalUrl ?? this.externalUrl,
    );
  }

  factory Song.fromLocal({
    required int id,
    required String title,
    required String artist,
    required String album,
    required String uri,
    required int duration,
    String? albumArt,
  }) {
    return Song(
      id: 'local_$id',
      localId: id,
      title: title,
      artist: artist,
      album: album,
      uri: uri,
      duration: duration,
      sourceStr: 'local',
      albumArt: albumArt,
    );
  }

  factory Song.fromYoutube({
    required String videoId,
    required String title,
    required String author,
    required String thumbnailUrl,
    required int durationMs,
    String? streamUrl,
  }) {
    return Song(
      id: 'yt_$videoId',
      title: title,
      artist: author,
      album: 'YouTube',
      uri: streamUrl ?? '',
      duration: durationMs,
      sourceStr: 'youtube',
      albumArt: thumbnailUrl,
      youtubeVideoId: videoId,
    );
  }
}
