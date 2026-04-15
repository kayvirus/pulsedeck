import 'package:url_launcher/url_launcher.dart';

enum StreamingPlatform {
  spotify,
  appleMusic,
  audiomack,
  soundcloud,
  deezer,
  tidal,
}

class ExternalStreamingService {
  static const Map<StreamingPlatform, String> _platformNames = {
    StreamingPlatform.spotify: 'Spotify',
    StreamingPlatform.appleMusic: 'Apple Music',
    StreamingPlatform.audiomack: 'Audiomack',
    StreamingPlatform.soundcloud: 'SoundCloud',
    StreamingPlatform.deezer: 'Deezer',
    StreamingPlatform.tidal: 'TIDAL',
  };

  static const Map<StreamingPlatform, String> _searchUrls = {
    StreamingPlatform.spotify: 'https://open.spotify.com/search/',
    StreamingPlatform.appleMusic: 'https://music.apple.com/search?term=',
    StreamingPlatform.audiomack: 'https://audiomack.com/search?q=',
    StreamingPlatform.soundcloud: 'https://soundcloud.com/search?q=',
    StreamingPlatform.deezer: 'https://www.deezer.com/search/',
    StreamingPlatform.tidal: 'https://listen.tidal.com/search?q=',
  };

  static const Map<StreamingPlatform, String> _appSchemes = {
    StreamingPlatform.spotify: 'spotify:search:',
    StreamingPlatform.appleMusic: 'music://music.apple.com/search?term=',
    StreamingPlatform.audiomack: 'audiomack://search?q=',
    StreamingPlatform.soundcloud: 'soundcloud://search?q=',
  };

  String getPlatformName(StreamingPlatform platform) =>
      _platformNames[platform] ?? 'Unknown';

  Future<void> searchOnPlatform(StreamingPlatform platform, String query) async {
    final encodedQuery = Uri.encodeComponent(query);

    // Try app deep link first
    final appScheme = _appSchemes[platform];
    if (appScheme != null) {
      final appUri = Uri.parse('$appScheme$encodedQuery');
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
        return;
      }
    }

    // Fallback to web
    final webUrl = _searchUrls[platform];
    if (webUrl != null) {
      final uri = Uri.parse('$webUrl$encodedQuery');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openPlatform(StreamingPlatform platform) async {
    final url = _searchUrls[platform]?.replaceAll(RegExp(r'/search.*'), '') ?? '';
    if (url.isNotEmpty) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  List<PlatformInfo> getAllPlatforms() {
    return [
      PlatformInfo(
        platform: StreamingPlatform.spotify,
        name: 'Spotify',
        color: 0xFF1DB954,
        iconAsset: 'spotify',
      ),
      PlatformInfo(
        platform: StreamingPlatform.appleMusic,
        name: 'Apple Music',
        color: 0xFFFC3C44,
        iconAsset: 'apple_music',
      ),
      PlatformInfo(
        platform: StreamingPlatform.audiomack,
        name: 'Audiomack',
        color: 0xFFFF5500,
        iconAsset: 'audiomack',
      ),
      PlatformInfo(
        platform: StreamingPlatform.soundcloud,
        name: 'SoundCloud',
        color: 0xFFFF7700,
        iconAsset: 'soundcloud',
      ),
      PlatformInfo(
        platform: StreamingPlatform.deezer,
        name: 'Deezer',
        color: 0xFF00C7F2,
        iconAsset: 'deezer',
      ),
      PlatformInfo(
        platform: StreamingPlatform.tidal,
        name: 'TIDAL',
        color: 0xFF00FFFF,
        iconAsset: 'tidal',
      ),
    ];
  }
}

class PlatformInfo {
  final StreamingPlatform platform;
  final String name;
  final int color;
  final String iconAsset;

  PlatformInfo({
    required this.platform,
    required this.name,
    required this.color,
    required this.iconAsset,
  });
}
