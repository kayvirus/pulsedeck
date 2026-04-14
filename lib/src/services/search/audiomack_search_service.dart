import '../../models/app_track.dart';
import '../../models/search_bundle.dart';

class AudiomackSearchService {
  Future<SearchBundle> search(String query) async {
    return const SearchBundle(
      provider: 'Audiomack',
      tracks: <AppTrack>[],
      message: 'Audiomack is left as an extension point because a stable public search/streaming integration is not packaged here.',
    );
  }
}
