import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/player_provider.dart';
import '../providers/search_provider.dart';
import '../services/external_streaming_service.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  late TabController _tabController;
  final _externalService = ExternalStreamingService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<SearchProvider>().setTab(
            SearchTab.values[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeatFlowTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _LocalSearchTab(),
                  _YouTubeSearchTab(searchController: _controller),
                  _PlatformsTab(
                    externalService: _externalService,
                    query: _controller.text,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SEARCH',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: BeatFlowTheme.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: BeatFlowTheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BeatFlowTheme.border),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                color: BeatFlowTheme.textPrimary,
                fontSize: 15,
              ),
              decoration: const InputDecoration(
                hintText: 'Songs, artists, albums...',
                hintStyle: TextStyle(
                  fontFamily: 'Satoshi',
                  color: BeatFlowTheme.textMuted,
                ),
                prefixIcon: Icon(Icons.search_rounded,
                    color: BeatFlowTheme.textMuted),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (q) {
                setState(() {});
                final searchProvider = context.read<SearchProvider>();
                final playerProvider = context.read<PlayerProvider>();

                // Local search
                final localResults = playerProvider.searchLocal(q);
                searchProvider.setLocalResults(localResults);

                // YouTube search with debounce
                if (_tabController.index == 1) {
                  searchProvider.searchYoutube(q);
                }
              },
              onSubmitted: (q) {
                final searchProvider = context.read<SearchProvider>();
                if (_tabController.index == 1) {
                  searchProvider.searchYoutube(q);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: BeatFlowTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: BeatFlowTheme.accent,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 12,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: BeatFlowTheme.textMuted,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Local'),
          Tab(text: 'YouTube'),
          Tab(text: 'Platforms'),
        ],
      ),
    );
  }
}

class _LocalSearchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        final results = searchProvider.localResults;

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.folder_open_rounded,
                    color: BeatFlowTheme.textMuted, size: 56),
                const SizedBox(height: 12),
                const Text('Search your local library',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BeatFlowTheme.textPrimary,
                    )),
                const SizedBox(height: 6),
                Text(
                  searchProvider.query.isEmpty
                      ? 'Type something to search'
                      : 'No results for "${searchProvider.query}"',
                  style: const TextStyle(
                      fontFamily: 'Satoshi',
                      color: BeatFlowTheme.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          itemCount: results.length,
          itemBuilder: (context, i) => SongTile(
            song: results[i],
            queue: results,
            queueIndex: i,
          ),
        );
      },
    );
  }
}

class _YouTubeSearchTab extends StatelessWidget {
  final TextEditingController searchController;

  const _YouTubeSearchTab({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        if (searchProvider.isSearching) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: BeatFlowTheme.youtubeRed),
                SizedBox(height: 16),
                Text('Searching YouTube...',
                    style: TextStyle(
                        fontFamily: 'Satoshi',
                        color: BeatFlowTheme.textSecondary)),
              ],
            ),
          );
        }

        if (searchProvider.searchError != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    color: BeatFlowTheme.textMuted, size: 56),
                const SizedBox(height: 12),
                Text(searchProvider.searchError!,
                    style: const TextStyle(
                        fontFamily: 'Satoshi',
                        color: BeatFlowTheme.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      searchProvider.searchYoutube(searchController.text),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: BeatFlowTheme.youtubeRed),
                  child: const Text('Retry',
                      style: TextStyle(
                          fontFamily: 'Satoshi', color: Colors.white)),
                ),
              ],
            ),
          );
        }

        if (searchProvider.youtubeResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: BeatFlowTheme.youtubeRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_circle_outline_rounded,
                      color: BeatFlowTheme.youtubeRed, size: 48),
                ),
                const SizedBox(height: 16),
                const Text('Search YouTube',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: BeatFlowTheme.textPrimary,
                    )),
                const SizedBox(height: 8),
                const Text('Stream any song from YouTube',
                    style: TextStyle(
                        fontFamily: 'Satoshi',
                        color: BeatFlowTheme.textSecondary)),
              ],
            ),
          );
        }

        return Consumer<PlayerProvider>(
          builder: (context, playerProvider, _) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: searchProvider.youtubeResults.length,
              itemBuilder: (context, i) {
                final song = searchProvider.youtubeResults[i];
                return SongTile(
                  song: song,
                  showSource: true,
                  queue: searchProvider.youtubeResults,
                  queueIndex: i,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PlatformsTab extends StatelessWidget {
  final ExternalStreamingService externalService;
  final String query;

  const _PlatformsTab({required this.externalService, required this.query});

  @override
  Widget build(BuildContext context) {
    final platforms = externalService.getAllPlatforms();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (query.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BeatFlowTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BeatFlowTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      color: BeatFlowTheme.accent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search "$query" on all platforms',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 14,
                        color: BeatFlowTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            'STREAMING PLATFORMS',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: BeatFlowTheme.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          ...platforms.map((p) => _PlatformCard(
                platform: p,
                searchQuery: query,
                externalService: externalService,
              )),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BeatFlowTheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BeatFlowTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: BeatFlowTheme.accent, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'How platform streaming works',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: BeatFlowTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'BeatFlow opens the platform\'s app or website with your search. You\'ll need active subscriptions to stream from paid platforms.',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12,
                    color: BeatFlowTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  final PlatformInfo platform;
  final String searchQuery;
  final ExternalStreamingService externalService;

  const _PlatformCard({
    required this.platform,
    required this.searchQuery,
    required this.externalService,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(platform.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => searchQuery.isNotEmpty
              ? externalService.searchOnPlatform(platform.platform, searchQuery)
              : externalService.openPlatform(platform.platform),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BeatFlowTheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(platform.platform),
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        platform.name,
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: BeatFlowTheme.textPrimary,
                        ),
                      ),
                      Text(
                        searchQuery.isNotEmpty
                            ? 'Search "$searchQuery"'
                            : 'Open ${platform.name}',
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12,
                          color: BeatFlowTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  color: color.withOpacity(0.7),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(StreamingPlatform platform) {
    switch (platform) {
      case StreamingPlatform.spotify:
        return Icons.queue_music_rounded;
      case StreamingPlatform.appleMusic:
        return Icons.apple_rounded;
      case StreamingPlatform.audiomack:
        return Icons.headphones_rounded;
      case StreamingPlatform.soundcloud:
        return Icons.cloud_rounded;
      case StreamingPlatform.deezer:
        return Icons.music_note_rounded;
      case StreamingPlatform.tidal:
        return Icons.waves_rounded;
    }
  }
}
