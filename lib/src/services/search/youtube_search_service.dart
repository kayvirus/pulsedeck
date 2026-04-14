import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../models/app_track.dart';
import '../../models/search_bundle.dart';

class YouTubeSearchService {
  final YoutubeExplode _yt = YoutubeExplode();

  Future<SearchBundle> search(String query) async {
    final videoResults = await _yt.search.search(query).toList();
    final tracks = <AppTrack>[];

    for (final video in videoResults.take(8)) {
      try {
        final manifest = await _yt.videos.streamsClient.getManifest(video.id);
        final audioOnly = manifest.audioOnly;
        if (audioOnly.isEmpty) {
          continue;
        }
        final selected = audioOnly.withHighestBitrate();
        tracks.add(
          AppTrack(
            id: 'yt_${video.id.value}',
            title: video.title,
            artist: video.author,
            album: 'YouTube',
            artworkUrl: video.thumbnails.highResUrl,
            streamUrl: selected.url.toString(),
            externalUrl: 'https://www.youtube.com/watch?v=${video.id.value}',
            durationMs: video.duration?.inMilliseconds,
            sourceType: TrackSourceType.youtube,
          ),
        );
      } catch (_) {
        // Skip malformed or inaccessible entries.
      }
    }

    return SearchBundle(
      provider: 'YouTube',
      tracks: tracks,
      message: tracks.isEmpty ? 'No playable YouTube audio stream was resolved.' : null,
    );
  }

  void dispose() {
    _yt.close();
  }
}
