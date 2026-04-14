import 'app_track.dart';

class SearchBundle {
  const SearchBundle({
    required this.provider,
    required this.tracks,
    this.message,
  });

  final String provider;
  final List<AppTrack> tracks;
  final String? message;
}
