import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../models/app_track.dart';

class AudioPlayerService {
  AudioPlayerService() {
    _player.playerStateStream.listen((_) {
      _stateController.add(null);
    });
    _player.currentIndexStream.listen((_) {
      _stateController.add(null);
    });
    _player.positionStream.listen((_) {
      _stateController.add(null);
    });
    _player.durationStream.listen((_) {
      _stateController.add(null);
    });
    _player.sequenceStateStream.listen((_) {
      _stateController.add(null);
    });
  }

  final AudioPlayer _player = AudioPlayer();
  final StreamController<void> _stateController = StreamController<void>.broadcast();
  List<AppTrack> _queue = const <AppTrack>[];

  AudioPlayer get player => _player;
  Stream<void> get changes => _stateController.stream;
  List<AppTrack> get queue => List.unmodifiable(_queue);
  int? get currentIndex => _player.currentIndex;
  AppTrack? get currentTrack {
    final index = currentIndex;
    if (index == null || index < 0 || index >= _queue.length) {
      return null;
    }
    return _queue[index];
  }

  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  bool get isPlaying => _player.playing;

  Future<void> playQueue(List<AppTrack> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) {
      return;
    }

    _queue = tracks;

    final sources = tracks.map(_buildSource).toList();

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: startIndex,
    );
    await _player.play();
    _stateController.add(null);
  }

  Future<void> playSingle(AppTrack track) async {
    await playQueue(<AppTrack>[track]);
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    _stateController.add(null);
  }

  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> next() => _player.seekToNext();
  Future<void> previous() => _player.seekToPrevious();

  AudioSource _buildSource(AppTrack track) {
    final mediaItem = MediaItem(
      id: track.id,
      title: track.title,
      artist: track.artist,
      album: track.album,
      artUri: track.artworkUrl == null ? null : Uri.tryParse(track.artworkUrl!),
      extras: {
        'source': track.sourceType.name,
        'externalUrl': track.externalUrl,
      },
    );

    if (track.filePath != null && track.filePath!.isNotEmpty) {
      return AudioSource.file(track.filePath!, tag: mediaItem);
    }

    if (track.streamUrl != null && track.streamUrl!.isNotEmpty) {
      return AudioSource.uri(Uri.parse(track.streamUrl!), tag: mediaItem);
    }

    throw StateError('Track is not playable: ${track.title}');
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _stateController.close();
  }
}
