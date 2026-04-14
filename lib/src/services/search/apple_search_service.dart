import 'package:dio/dio.dart';

import '../../models/app_track.dart';
import '../../models/search_bundle.dart';

class AppleSearchService {
  AppleSearchService(this._dio);

  final Dio _dio;

  Future<SearchBundle> search(String query) async {
    final response = await _dio.get<dynamic>(
      'https://itunes.apple.com/search',
      queryParameters: {
        'term': query,
        'entity': 'song',
        'limit': 20,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>? ?? const <dynamic>[])
        .cast<Map<String, dynamic>>();

    final tracks = results
        .map(
          (item) => AppTrack(
            id: 'apple_${item['trackId'] ?? item['collectionId'] ?? item['artistId']}',
            title: item['trackName'] as String? ?? 'Unknown title',
            artist: item['artistName'] as String? ?? 'Unknown artist',
            album: item['collectionName'] as String?,
            artworkUrl: (item['artworkUrl100'] as String?)?.replaceAll('100x100', '400x400'),
            streamUrl: item['previewUrl'] as String?,
            externalUrl: item['trackViewUrl'] as String?,
            durationMs: item['trackTimeMillis'] as int?,
            sourceType: TrackSourceType.applePreview,
          ),
        )
        .where((track) => track.streamUrl != null && track.streamUrl!.isNotEmpty)
        .toList();

    return SearchBundle(
      provider: 'Apple Preview',
      tracks: tracks,
      message: tracks.isEmpty ? 'No playable Apple preview results returned.' : null,
    );
  }
}
