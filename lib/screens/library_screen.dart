import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';
import '../models/song_model.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['All Songs', 'Artists', 'Albums', 'Favorites'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PlayerProvider>();
      if (provider.localSongs.isEmpty && !provider.localLoading) {
        provider.loadLocalSongs();
      }
    });
  }

  @override
  void dispose() {
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
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AllSongsTab(),
                  _ArtistsTab(),
                  _AlbumsTab(),
                  _FavoritesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MY LIBRARY',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: BeatFlowTheme.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              Consumer<PlayerProvider>(
                builder: (_, p, __) => Text(
                  '${p.localSongs.length} songs',
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: BeatFlowTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Refresh button
          Consumer<PlayerProvider>(
            builder: (_, p, __) => IconButton(
              icon: p.localLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: BeatFlowTheme.accent,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
              color: BeatFlowTheme.textSecondary,
              onPressed: p.localLoading ? null : p.loadLocalSongs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          fontWeight: FontWeight.w500,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: BeatFlowTheme.textMuted,
        dividerColor: Colors.transparent,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

class _AllSongsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        if (provider.localLoading) {
          return const Center(
            child: CircularProgressIndicator(color: BeatFlowTheme.accent),
          );
        }

        if (provider.localError != null) {
          return _errorView(context, provider);
        }

        if (provider.localSongs.isEmpty) {
          return _emptyView(context, provider);
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: provider.localSongs.length,
            itemBuilder: (context, i) {
              final song = provider.localSongs[i];
              return AnimationConfiguration.staggeredList(
                position: i,
                duration: const Duration(milliseconds: 300),
                child: SlideAnimation(
                  verticalOffset: 20,
                  child: FadeInAnimation(
                    child: SongTile(
                      song: song,
                      queue: provider.localSongs,
                      queueIndex: i,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _errorView(BuildContext context, PlayerProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: BeatFlowTheme.textMuted, size: 48),
          const SizedBox(height: 12),
          Text(provider.localError!,
              style: const TextStyle(
                  color: BeatFlowTheme.textSecondary, fontFamily: 'Satoshi')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.loadLocalSongs,
            style: ElevatedButton.styleFrom(
                backgroundColor: BeatFlowTheme.accent),
            child: const Text('Retry',
                style: TextStyle(fontFamily: 'Satoshi', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _emptyView(BuildContext context, PlayerProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.library_music_rounded,
              color: BeatFlowTheme.textMuted, size: 64),
          const SizedBox(height: 16),
          const Text(
            'No music found',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: BeatFlowTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Grant storage permission to\naccess your music files',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Satoshi', color: BeatFlowTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: provider.loadLocalSongs,
            style: ElevatedButton.styleFrom(
                backgroundColor: BeatFlowTheme.accent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12)),
            child: const Text('Grant Permission',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ArtistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        final artists = provider.localSongs
            .map((s) => s.artist)
            .toSet()
            .toList()
          ..sort();

        if (artists.isEmpty) {
          return const Center(
            child: Text('No artists found',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    color: BeatFlowTheme.textSecondary)),
          );
        }

        return ListView.builder(
          itemCount: artists.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, i) {
            final artist = artists[i];
            final count = provider.localSongs
                .where((s) => s.artist == artist)
                .length;

            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: BeatFlowTheme.card,
                child: Text(
                  artist.isNotEmpty ? artist[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w700,
                    color: BeatFlowTheme.accent,
                  ),
                ),
              ),
              title: Text(artist,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w600,
                    color: BeatFlowTheme.textPrimary,
                  )),
              subtitle: Text(
                '$count ${count == 1 ? 'song' : 'songs'}',
                style: const TextStyle(
                    fontFamily: 'Satoshi',
                    color: BeatFlowTheme.textSecondary),
              ),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: BeatFlowTheme.textMuted),
              onTap: () => _showArtistSongs(context, artist, provider),
            );
          },
        );
      },
    );
  }

  void _showArtistSongs(
      BuildContext context, String artist, PlayerProvider provider) {
    final songs =
        provider.localSongs.where((s) => s.artist == artist).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: BeatFlowTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: BeatFlowTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(artist,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: BeatFlowTheme.textPrimary,
                  )),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: songs.length,
                itemBuilder: (ctx, i) => SongTile(
                  song: songs[i],
                  queue: songs,
                  queueIndex: i,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        final albumMap = <String, List<Song>>{};
        for (final song in provider.localSongs) {
          albumMap.putIfAbsent(song.album, () => []).add(song);
        }
        final albums = albumMap.keys.toList()..sort();

        if (albums.isEmpty) {
          return const Center(
            child: Text('No albums found',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    color: BeatFlowTheme.textSecondary)),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: albums.length,
          itemBuilder: (context, i) {
            final album = albums[i];
            final songs = albumMap[album]!;
            return _AlbumCard(
              albumName: album,
              songs: songs,
              onTap: () => _showAlbumSongs(context, album, songs),
            );
          },
        );
      },
    );
  }

  void _showAlbumSongs(
      BuildContext context, String album, List<Song> songs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BeatFlowTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: BeatFlowTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(album,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: BeatFlowTheme.textPrimary,
                  )),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: songs.length,
                itemBuilder: (ctx, i) => SongTile(
                  song: songs[i],
                  queue: songs,
                  queueIndex: i,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final String albumName;
  final List<Song> songs;
  final VoidCallback onTap;

  const _AlbumCard(
      {required this.albumName, required this.songs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: BeatFlowTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BeatFlowTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: BeatFlowTheme.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: songs.first.localId != null
                      ? QueryArtworkWidget(
                          id: songs.first.localId!,
                          type: ArtworkType.AUDIO,
                          artworkFit: BoxFit.cover,
                          artworkBorderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          nullArtworkWidget: const Icon(
                              Icons.album_rounded,
                              color: BeatFlowTheme.textMuted,
                              size: 48),
                          keepOldArtwork: true,
                        )
                      : const Icon(Icons.album_rounded,
                          color: BeatFlowTheme.textMuted, size: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    albumName,
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: BeatFlowTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${songs.length} songs',
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11,
                      color: BeatFlowTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        final favs = provider.favorites;
        if (favs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_border_rounded,
                    color: BeatFlowTheme.textMuted, size: 64),
                SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: BeatFlowTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Heart a song to save it here',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      color: BeatFlowTheme.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          itemCount: favs.length,
          itemBuilder: (context, i) => SongTile(
            song: favs[i],
            queue: favs,
            queueIndex: i,
          ),
        );
      },
    );
  }
}
