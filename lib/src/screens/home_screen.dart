import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_track.dart';
import '../models/search_bundle.dart';
import '../providers.dart';
import '../widgets/section_header.dart';
import '../widgets/track_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _librarySearchController = TextEditingController();
  final TextEditingController _discoverSearchController = TextEditingController();
  int _index = 0;
  String _libraryQuery = '';
  StreamSubscription<void>? _playerSubscription;

  @override
  void initState() {
    super.initState();
    final audio = ref.read(audioPlayerServiceProvider);
    _playerSubscription = audio.changes.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _librarySearchController.dispose();
    _discoverSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildLibraryPage(context),
      _buildDiscoverPage(context),
      _buildNowPlayingPage(context),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('PulseDeck'),
        actions: [
          IconButton(
            onPressed: () => ref.read(localLibraryControllerProvider.notifier).importTracks(),
            icon: const Icon(Icons.library_music_outlined),
            tooltip: 'Import local audio',
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: pages[_index],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.library_music_outlined), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.travel_explore_outlined), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.graphic_eq_outlined), label: 'Now Playing'),
        ],
      ),
    );
  }

  Widget _buildLibraryPage(BuildContext context) {
    final tracks = ref.watch(localLibraryControllerProvider);

    final filtered = tracks.where((track) {
      final q = _libraryQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return track.title.toLowerCase().contains(q) ||
          track.artist.toLowerCase().contains(q) ||
          (track.album?.toLowerCase().contains(q) ?? false);
    }).toList();

    return ListView(
      key: const ValueKey('library'),
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(
          title: 'Local Library',
          subtitle: 'Import audio files from this device and play them offline.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _librarySearchController,
          onChanged: (value) => setState(() => _libraryQuery = value),
          decoration: const InputDecoration(
            hintText: 'Search imported tracks',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => ref.read(localLibraryControllerProvider.notifier).importTracks(),
          icon: const Icon(Icons.add),
          label: const Text('Import local songs'),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const _EmptyCard(
            icon: Icons.audio_file_outlined,
            title: 'No imported songs yet',
            description: 'Use the import button to select audio files from your device.',
          )
        else
          ...filtered.asMap().entries.map(
                (entry) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: TrackTile(
                    track: entry.value,
                    onTap: () => _playLocalList(filtered, entry.key),
                    onDelete: () => ref
                        .read(localLibraryControllerProvider.notifier)
                        .removeTrack(entry.value.id),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildDiscoverPage(BuildContext context) {
    final state = ref.watch(discoveryControllerProvider);

    return ListView(
      key: const ValueKey('discover'),
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(
          title: 'Federated Search',
          subtitle: 'Working now: YouTube streams, Apple previews. Spotify and Audiomack are extension points in this build.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _discoverSearchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => ref.read(discoveryControllerProvider.notifier).search(value),
          decoration: InputDecoration(
            hintText: 'Search music across providers',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: () => ref
                  .read(discoveryControllerProvider.notifier)
                  .search(_discoverSearchController.text),
              icon: const Icon(Icons.send),
            ),
          ),
        ),
        const SizedBox(height: 16),
        state.when(
          data: (bundles) {
            if (bundles.isEmpty) {
              return const _EmptyCard(
                icon: Icons.travel_explore_outlined,
                title: 'Search online music',
                description: 'Type a song, artist, or album and submit to search across providers.',
              );
            }

            return Column(
              children: bundles.map((bundle) => _ProviderResultsCard(bundle: bundle, onPlay: _playSingle)).toList(),
            );
          },
          error: (error, _) => _EmptyCard(
            icon: Icons.error_outline,
            title: 'Search failed',
            description: error.toString(),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNowPlayingPage(BuildContext context) {
    final audio = ref.watch(audioPlayerServiceProvider);
    final current = audio.currentTrack;
    final position = audio.position;
    final duration = audio.duration;
    final maxMillis = duration.inMilliseconds <= 0 ? 1 : duration.inMilliseconds;

    return ListView(
      key: const ValueKey('now_playing'),
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(
          title: 'Now Playing',
          subtitle: 'Background playback and queue controls are enabled.',
        ),
        const SizedBox(height: 24),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF2A2F3A), Color(0xFF151922)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              image: current?.artworkUrl != null
                  ? DecorationImage(
                      image: NetworkImage(current!.artworkUrl!),
                      fit: BoxFit.cover,
                      opacity: 0.82,
                    )
                  : null,
            ),
            child: current == null
                ? const Center(
                    child: Icon(Icons.queue_music, size: 72),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          current?.title ?? 'Nothing selected',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          current?.subtitle ?? 'Import local songs or search online to begin playback.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 20),
        Slider(
          value: position.inMilliseconds.clamp(0, maxMillis).toDouble(),
          max: maxMillis.toDouble(),
          onChanged: current == null
              ? null
              : (value) => audio.seek(Duration(milliseconds: value.round())),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(position)),
            Text(_formatDuration(duration)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              onPressed: current == null ? null : audio.previous,
              icon: const Icon(Icons.skip_previous),
            ),
            const SizedBox(width: 16),
            IconButton.filled(
              onPressed: current == null ? null : audio.togglePlayPause,
              iconSize: 36,
              icon: Icon(audio.isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            const SizedBox(width: 16),
            IconButton.filledTonal(
              onPressed: current == null ? null : audio.next,
              icon: const Icon(Icons.skip_next),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Queue'),
        const SizedBox(height: 12),
        if (audio.queue.isEmpty)
          const _EmptyCard(
            icon: Icons.queue_music,
            title: 'Queue is empty',
            description: 'Start playback from Local Library or Discover.',
          )
        else
          ...audio.queue.asMap().entries.map(
                (entry) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: TrackTile(
                    track: entry.value,
                    onTap: () => audio.playQueue(audio.queue, startIndex: entry.key),
                    leadingLabel: '${entry.key + 1}',
                  ),
                ),
              ),
      ],
    );
  }

  Future<void> _playLocalList(List<AppTrack> tracks, int index) async {
    await ref.read(audioPlayerServiceProvider).playQueue(tracks, startIndex: index);
    if (mounted) {
      setState(() => _index = 2);
    }
  }

  Future<void> _playSingle(AppTrack track) async {
    if (!track.isPlayable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This result is not directly playable in the current build.')),
      );
      return;
    }

    await ref.read(audioPlayerServiceProvider).playSingle(track);
    if (mounted) {
      setState(() => _index = 2);
    }
  }

  String _formatDuration(Duration value) {
    final totalSeconds = value.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ProviderResultsCard extends StatelessWidget {
  const _ProviderResultsCard({
    required this.bundle,
    required this.onPlay,
  });

  final SearchBundle bundle;
  final Future<void> Function(AppTrack track) onPlay;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: bundle.provider,
              subtitle: bundle.message ?? '${bundle.tracks.length} result(s)',
            ),
            const SizedBox(height: 12),
            if (bundle.tracks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No playable items returned.'),
              )
            else
              ...bundle.tracks.map(
                (track) => TrackTile(
                  track: track,
                  onTap: () => onPlay(track),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 42),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
