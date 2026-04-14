import '../../models/app_track.dart';
import '../../models/search_bundle.dart';

class SpotifySearchService {
  Future<SearchBundle> search(String query) async {
    return const SearchBundle(
      provider: 'Spotify',
      tracks: <AppTrack>[],
      message: 'Spotify search is intentionally disabled in this build. A production-safe implementation requires OAuth and should be proxied through a backend, not hard-coded in a mobile app.',
    );
  }
}
