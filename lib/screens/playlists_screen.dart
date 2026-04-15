import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/playlist_model.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeatFlowTheme.bg,
      body: SafeArea(
        child: Consumer<PlayerProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                _buildHeader(context, provider),
                Expanded(
                  child: provider.playlists.isEmpty
                      ? _emptyState(context, provider)
                      : _playlistGrid(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PlayerProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PLAYLISTS',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: BeatFlowTheme.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${provider.playlists.length} playlists',
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: BeatFlowTheme.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showCreatePlaylist(context, provider),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: BFGradients.accentGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: BeatFlowTheme.accentGlow,
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, PlayerProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: BeatFlowTheme.card,
            ),
            child: const Icon(
              Icons.queue_music_rounded,
              color: BeatFlowTheme.textMuted,
              size: 56,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No playlists yet',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: BeatFlowTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first playlist',
            style: TextStyle(
                fontFamily: 'Satoshi', color: BeatFlowTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreatePlaylist(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: BeatFlowTheme.accent,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Create Playlist',
              style: TextStyle(
                  fontFamily: 'Satoshi',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playlistGrid(BuildContext context, PlayerProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: provider.playlists.length,
      itemBuilder: (context, i) {
        final playlist = provider.playlists[i];
        return _PlaylistCard(
          playlist: playlist,
          onTap: () => _openPlaylist(context, playlist, provider),
          onLongPress: () => _showPlaylistOptions(context, playlist, provider),
        );
      },
    );
  }

  void _showCreatePlaylist(BuildContext context, PlayerProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: BeatFlowTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Playlist',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: BeatFlowTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _inputField(nameController, 'Playlist name', null),
            const SizedBox(height: 12),
            _inputField(descController, 'Description (optional)', null),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isNotEmpty) {
                    await provider.createPlaylist(
                      nameController.text.trim(),
                      description: descController.text.trim().isNotEmpty
                          ? descController.text.trim()
                          : null,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BeatFlowTheme.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Create',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
      TextEditingController controller, String hint, String? label) {
    return TextField(
      controller: controller,
      style: const TextStyle(
          fontFamily: 'Satoshi', color: BeatFlowTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        hintStyle: const TextStyle(
            fontFamily: 'Satoshi', color: BeatFlowTheme.textMuted),
        labelStyle: const TextStyle(
            fontFamily: 'Satoshi', color: BeatFlowTheme.textSecondary),
        filled: true,
        fillColor: BeatFlowTheme.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BeatFlowTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BeatFlowTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BeatFlowTheme.accent),
        ),
      ),
    );
  }

  void _openPlaylist(
      BuildContext context, Playlist playlist, PlayerProvider provider) {
    final songs = provider.localSongs
        .where((s) => playlist.songIds.contains(s.id))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PlaylistDetailScreen(
          playlist: playlist,
          songs: songs,
        ),
      ),
    );
  }

  void _showPlaylistOptions(
      BuildContext context, Playlist playlist, PlayerProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BeatFlowTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent),
            title: const Text('Delete Playlist',
                style: TextStyle(
                    fontFamily: 'Satoshi', color: BeatFlowTheme.textPrimary)),
            onTap: () {
              provider.deletePlaylist(playlist.id);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _PlaylistCard({
    required this.playlist,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      [BeatFlowTheme.accent, BeatFlowTheme.accentSecondary],
      [BeatFlowTheme.accentSecondary, BeatFlowTheme.accentTertiary],
      [BeatFlowTheme.accentTertiary, BeatFlowTheme.accent],
      [const Color(0xFFFF6B35), BeatFlowTheme.accentSecondary],
    ];
    final colorPair =
        colors[playlist.name.hashCode.abs() % colors.length];

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BeatFlowTheme.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colorPair,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.queue_music_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ),
            Container(
              color: BeatFlowTheme.card,
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
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
                          '${playlist.songCount} songs',
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
          ],
        ),
      ),
    );
  }
}

class _PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;
  final List songs;

  const _PlaylistDetailScreen({required this.playlist, required this.songs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeatFlowTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(playlist.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: BeatFlowTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: songs.isEmpty
          ? const Center(
              child: Text(
              'No songs in this playlist yet',
              style: TextStyle(
                  fontFamily: 'Satoshi',
                  color: BeatFlowTheme.textSecondary),
            ))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: songs.length,
              itemBuilder: (context, i) => SongTile(
                song: songs[i],
                queue: songs.cast(),
                queueIndex: i,
              ),
            ),
    );
  }
}
