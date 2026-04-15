import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song_model.dart';

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

class BeatFlowAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  List<Song> _queue = [];
  int _currentIndex = 0;

  BeatFlowAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.durationStream.listen((duration) {
      if (duration != null && mediaItem.value != null) {
        mediaItem.add(mediaItem.value!.copyWith(duration: duration));
      }
    });
  }

  AudioPlayer get player => _player;

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );

  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _queue.isEmpty ? null : _queue[_currentIndex];
  bool get isPlaying => _player.playing;
  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _queue.length - 1;

  Future<void> playSong(Song song, {List<Song>? queue, int? index}) async {
    if (queue != null) {
      _queue = queue;
      _currentIndex = index ?? 0;
    } else {
      _queue = [song];
      _currentIndex = 0;
    }

    final mi = _songToMediaItem(song);
    mediaItem.add(mi);

    await _loadAndPlay(song);
  }

  Future<void> _loadAndPlay(Song song) async {
    try {
      if (song.source == SongSource.local) {
        await _player.setFilePath(song.uri);
      } else {
        await _player.setUrl(song.uri);
      }
      await _player.play();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateStreamUrl(String songId, String url) async {
    final idx = _queue.indexWhere((s) => s.id == songId);
    if (idx != -1) {
      _queue[idx] = _queue[idx].copyWith(uri: url);
      if (idx == _currentIndex) {
        await _player.setUrl(url);
        await _player.play();
      }
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (hasNext) {
      _currentIndex++;
      final song = _queue[_currentIndex];
      mediaItem.add(_songToMediaItem(song));
      await _loadAndPlay(song);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
    } else if (hasPrevious) {
      _currentIndex--;
      final song = _queue[_currentIndex];
      mediaItem.add(_songToMediaItem(song));
      await _loadAndPlay(song);
    }
  }

  Future<void> setRepeatMode(LoopMode mode) => _player.setLoopMode(mode);
  Future<void> setShuffle(bool enabled) => _player.setShuffleModeEnabled(enabled);
  Future<void> setVolume(double volume) => _player.setVolume(volume);
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  MediaItem _songToMediaItem(Song song) {
    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: Duration(milliseconds: song.duration),
      artUri: song.albumArt != null
          ? (song.source == SongSource.local
              ? Uri.file(song.albumArt!)
              : Uri.parse(song.albumArt!))
          : null,
    );
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    ));
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }
}
