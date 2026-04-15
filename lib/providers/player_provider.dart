import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';
import '../services/audio_handler.dart';
import '../services/local_music_service.dart';
import '../services/youtube_service.dart';

enum PlayerState { idle, loading, playing, paused, error }

class PlayerProvider extends ChangeNotifier {
  final BeatFlowAudioHandler _audioHandler;
  final LocalMusicService _localService = LocalMusicService();
  final YouTubeService _youtubeService = YouTubeService();

  // Local library
  List<Song> _localSongs = [];
  bool _localLoading = false;
  String? _localError;

  // Current queue display
  bool _queueVisible = false;
  bool _isMiniPlayerExpanded = false;

  // Repeat & Shuffle
  LoopMode _loopMode = LoopMode.off;
  bool _shuffleEnabled = false;

  // Favorites - cached from Hive
  late Box<Song> _favoritesBox;
  late Box<Playlist> _playlistsBox;
  bool _initialized = false;

  PlayerProvider(this._audioHandler);

  // Getters
  List<Song> get localSongs => _localSongs;
  bool get localLoading => _localLoading;
  String? get localError => _localError;
  bool get queueVisible => _queueVisible;
  bool get isMiniPlayerExpanded => _isMiniPlayerExpanded;
  LoopMode get loopMode => _loopMode;
  bool get shuffleEnabled => _shuffleEnabled;
  BeatFlowAudioHandler get audioHandler => _audioHandler;
  AudioPlayer get player => _audioHandler.player;
  Song? get currentSong => _audioHandler.currentSong;
  List<Song> get currentQueue => _audioHandler.queue;
  int get currentIndex => _audioHandler.currentIndex;

  List<Song> get favorites {
    if (!_initialized) return [];
    return _favoritesBox.values.toList();
  }

  List<Playlist> get playlists {
    if (!_initialized) return [];
    return _playlistsBox.values.toList();
  }

  Future<void> initialize() async {
    _favoritesBox = await Hive.openBox<Song>('favorites');
    _playlistsBox = await Hive.openBox<Playlist>('playlists');
    _initialized = true;

    // Listen to player events
    _audioHandler.player.playerStateStream.listen((_) => notifyListeners());
    _audioHandler.player.positionStream.listen((_) => notifyListeners());
    _audioHandler.mediaItem.listen((_) => notifyListeners());

    // Auto-advance
    _audioHandler.player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleSongComplete();
      }
    });

    notifyListeners();
  }

  Future<void> loadLocalSongs() async {
    _localLoading = true;
    _localError = null;
    notifyListeners();

    try {
      _localSongs = await _localService.getAllSongs();
      _localError = null;
    } catch (e) {
      _localError = 'Failed to load local songs';
    }

    _localLoading = false;
    notifyListeners();
  }

  Future<void> playSong(Song song, {List<Song>? queue, int? index}) async {
    await _audioHandler.playSong(song, queue: queue, index: index);
    notifyListeners();
  }

  Future<void> playYoutubeSong(Song song, {List<Song>? queue, int? index}) async {
    // First show loading state with metadata
    await _audioHandler.playSong(song, queue: queue, index: index);
    notifyListeners();

    // Get stream URL
    if (song.youtubeVideoId != null) {
      final streamUrl = await _youtubeService.getStreamUrl(song.youtubeVideoId!);
      if (streamUrl != null) {
        await _audioHandler.updateStreamUrl(song.id, streamUrl);
        notifyListeners();
      }
    }
  }

  Future<void> togglePlay() async {
    if (_audioHandler.isPlaying) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
    notifyListeners();
  }

  Future<void> skipNext() async {
    await _audioHandler.skipToNext();
    notifyListeners();
  }

  Future<void> skipPrevious() async {
    await _audioHandler.skipToPrevious();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
  }

  Future<void> cycleRepeatMode() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    await _audioHandler.setRepeatMode(_loopMode);
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    _shuffleEnabled = !_shuffleEnabled;
    await _audioHandler.setShuffle(_shuffleEnabled);
    notifyListeners();
  }

  void _handleSongComplete() {
    if (_loopMode == LoopMode.one) {
      _audioHandler.seek(Duration.zero);
      _audioHandler.play();
    } else if (_audioHandler.hasNext) {
      _audioHandler.skipToNext();
    } else if (_loopMode == LoopMode.all && currentQueue.isNotEmpty) {
      // Play from beginning
      playSong(currentQueue.first, queue: currentQueue, index: 0);
    }
    notifyListeners();
  }

  // Favorites
  Future<void> toggleFavorite(Song song) async {
    if (!_initialized) return;
    if (_favoritesBox.containsKey(song.id)) {
      await _favoritesBox.delete(song.id);
    } else {
      await _favoritesBox.put(song.id, song);
    }
    notifyListeners();
  }

  bool isFavorite(Song song) {
    if (!_initialized) return false;
    return _favoritesBox.containsKey(song.id);
  }

  // Playlists
  Future<Playlist> createPlaylist(String name, {String? description}) async {
    final playlist = Playlist.create(name, description: description);
    await _playlistsBox.put(playlist.id, playlist);
    notifyListeners();
    return playlist;
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final playlist = _playlistsBox.get(playlistId);
    if (playlist != null && !playlist.songIds.contains(song.id)) {
      playlist.songIds.add(song.id);
      playlist.updatedAt = DateTime.now();
      await playlist.save();
      notifyListeners();
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlist = _playlistsBox.get(playlistId);
    if (playlist != null) {
      playlist.songIds.remove(songId);
      playlist.updatedAt = DateTime.now();
      await playlist.save();
      notifyListeners();
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _playlistsBox.delete(playlistId);
    notifyListeners();
  }

  void toggleQueueVisible() {
    _queueVisible = !_queueVisible;
    notifyListeners();
  }

  void toggleMiniPlayerExpanded() {
    _isMiniPlayerExpanded = !_isMiniPlayerExpanded;
    notifyListeners();
  }

  List<Song> searchLocal(String query) {
    if (query.isEmpty) return _localSongs;
    final q = query.toLowerCase();
    return _localSongs
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q) ||
            s.album.toLowerCase().contains(q))
        .toList();
  }
}
