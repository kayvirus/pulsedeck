import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song_model.dart';

class LocalMusicService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> requestPermission() async {
    final status = await Permission.audio.request();
    if (!status.isGranted) {
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
    return status.isGranted;
  }

  Future<List<Song>> getAllSongs() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return [];

      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      return songs
          .where((s) => s.duration != null && s.duration! > 30000) // >30s
          .map((s) => Song.fromLocal(
                id: s.id,
                title: s.title,
                artist: s.artist ?? 'Unknown Artist',
                album: s.album ?? 'Unknown Album',
                uri: s.uri ?? '',
                duration: s.duration ?? 0,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Song>> getSongsByArtist(String artist) async {
    final all = await getAllSongs();
    return all.where((s) => s.artist.toLowerCase() == artist.toLowerCase()).toList();
  }

  Future<List<Song>> getSongsByAlbum(String album) async {
    final all = await getAllSongs();
    return all.where((s) => s.album.toLowerCase() == album.toLowerCase()).toList();
  }

  Future<List<String>> getArtists() async {
    final songs = await getAllSongs();
    final artists = songs.map((s) => s.artist).toSet().toList();
    artists.sort();
    return artists;
  }

  Future<List<String>> getAlbums() async {
    final songs = await getAllSongs();
    final albums = songs.map((s) => s.album).toSet().toList();
    albums.sort();
    return albums;
  }

  Future<List<Song>> search(String query) async {
    final all = await getAllSongs();
    final q = query.toLowerCase();
    return all
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q) ||
            s.album.toLowerCase().contains(q))
        .toList();
  }

  // Artwork query
  Future<List<int>?> getArtwork(int songId) async {
    try {
      final artwork = await _audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        quality: 100,
        size: 400,
      );
      return artwork;
    } catch (e) {
      return null;
    }
  }
}
