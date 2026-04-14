import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/app_track.dart';
import 'models/search_bundle.dart';
import 'services/audio_player_service.dart';
import 'services/local_library_service.dart';
import 'services/search/apple_search_service.dart';
import 'services/search/audiomack_search_service.dart';
import 'services/search/federated_search_service.dart';
import 'services/search/spotify_search_service.dart';
import 'services/search/youtube_search_service.dart';
import 'services/settings_service.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
});

final settingsServiceProvider = Provider<SettingsService>((ref) => SettingsService());

final localLibraryServiceProvider = Provider<LocalLibraryService>((ref) {
  return LocalLibraryService(ref.watch(settingsServiceProvider));
});

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

final youtubeSearchServiceProvider = Provider<YouTubeSearchService>((ref) {
  final service = YouTubeSearchService();
  ref.onDispose(service.dispose);
  return service;
});

final appleSearchServiceProvider = Provider<AppleSearchService>((ref) {
  return AppleSearchService(ref.watch(dioProvider));
});

final spotifySearchServiceProvider = Provider<SpotifySearchService>((ref) {
  return SpotifySearchService();
});

final audiomackSearchServiceProvider = Provider<AudiomackSearchService>((ref) {
  return AudiomackSearchService();
});

final federatedSearchServiceProvider = Provider<FederatedSearchService>((ref) {
  return FederatedSearchService(
    appleSearchService: ref.watch(appleSearchServiceProvider),
    youtubeSearchService: ref.watch(youtubeSearchServiceProvider),
    spotifySearchService: ref.watch(spotifySearchServiceProvider),
    audiomackSearchService: ref.watch(audiomackSearchServiceProvider),
  );
});

class LocalLibraryController extends Notifier<List<AppTrack>> {
  @override
  List<AppTrack> build() {
    Future<void>.microtask(load);
    return <AppTrack>[];
  }

  Future<void> load() async {
    state = await ref.read(localLibraryServiceProvider).loadSavedLibrary();
  }

  Future<void> importTracks() async {
    state = await ref.read(localLibraryServiceProvider).importTracks();
  }

  Future<void> removeTrack(String id) async {
    await ref.read(localLibraryServiceProvider).removeTrack(id);
    await load();
  }
}

final localLibraryControllerProvider =
    NotifierProvider<LocalLibraryController, List<AppTrack>>(LocalLibraryController.new);

class DiscoveryController extends Notifier<AsyncValue<List<SearchBundle>>> {
  @override
  AsyncValue<List<SearchBundle>> build() => const AsyncValue.data(<SearchBundle>[]);

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data(<SearchBundle>[]);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(federatedSearchServiceProvider).search(query.trim()),
    );
  }
}

final discoveryControllerProvider =
    NotifierProvider<DiscoveryController, AsyncValue<List<SearchBundle>>>(DiscoveryController.new);
