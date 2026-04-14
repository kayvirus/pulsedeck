import '../../models/search_bundle.dart';
import 'apple_search_service.dart';
import 'audiomack_search_service.dart';
import 'spotify_search_service.dart';
import 'youtube_search_service.dart';

class FederatedSearchService {
  FederatedSearchService({
    required AppleSearchService appleSearchService,
    required YouTubeSearchService youtubeSearchService,
    required SpotifySearchService spotifySearchService,
    required AudiomackSearchService audiomackSearchService,
  })  : _apple = appleSearchService,
        _youtube = youtubeSearchService,
        _spotify = spotifySearchService,
        _audiomack = audiomackSearchService;

  final AppleSearchService _apple;
  final YouTubeSearchService _youtube;
  final SpotifySearchService _spotify;
  final AudiomackSearchService _audiomack;

  Future<List<SearchBundle>> search(String query) async {
    final results = await Future.wait<SearchBundle>([
      _youtube.search(query),
      _apple.search(query),
      _spotify.search(query),
      _audiomack.search(query),
    ]);
    return results;
  }
}
