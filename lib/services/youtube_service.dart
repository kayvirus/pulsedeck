import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/song_model.dart';

class YouTubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  Future<List<Song>> search(String query) async {
    try {
      final results = await _yt.search.search(query);
      return results
          .whereType<Video>()
          .take(20)
          .map((v) => Song.fromYoutube(
                videoId: v.id.value,
                title: v.title,
                author: v.author,
                thumbnailUrl: v.thumbnails.highResUrl,
                durationMs: v.duration?.inMilliseconds ?? 0,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> getStreamUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      // Prefer audio-only streams
      final audioStreams = manifest.audioOnly.sortByBitrate();
      if (audioStreams.isNotEmpty) {
        return audioStreams.last.url.toString();
      }
      // Fallback to muxed
      final muxed = manifest.muxed.sortByVideoQuality();
      if (muxed.isNotEmpty) {
        return muxed.first.url.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Video?> getVideoInfo(String videoId) async {
    try {
      return await _yt.videos.get(videoId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Song>> getRelatedVideos(String videoId) async {
    try {
      final related = await _yt.videos.getRelatedVideos(videoId);
      if (related == null) return [];
      return related
          .take(10)
          .map((v) => Song.fromYoutube(
                videoId: v.id.value,
                title: v.title,
                author: v.author,
                thumbnailUrl: v.thumbnails.highResUrl,
                durationMs: v.duration?.inMilliseconds ?? 0,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  void dispose() => _yt.close();
}
