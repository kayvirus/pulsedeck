import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final bool showSource;
  final bool isActive;
  final List<Song>? queue;
  final int? queueIndex;
  final VoidCallback? onMorePressed;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.showSource = false,
    this.isActive = false,
    this.queue,
    this.queueIndex,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final isCurrent = provider.currentSong?.id == song.id;

    return InkWell(
      onTap: onTap ?? () => _handleTap(context),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent ? BeatFlowTheme.accentGlow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Artwork
            _buildArtwork(context, isCurrent),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCurrent
                          ? BeatFlowTheme.accent
                          : BeatFlowTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (showSource) _buildSourceBadge(),
                      Expanded(
                        child: Text(
                          '${song.artist} • ${song.durationFormatted}',
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 12,
                            color: BeatFlowTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Equalizer animation when playing
            if (isCurrent && provider.player.playing)
              _buildEqualizer()
            else
              _buildMoreButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildArtwork(BuildContext context, bool isCurrent) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: BeatFlowTheme.card,
        border: isCurrent
            ? Border.all(color: BeatFlowTheme.accent, width: 2)
            : null,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: BeatFlowTheme.accentGlow,
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: _getArtworkWidget(),
    );
  }

  Widget _getArtworkWidget() {
    if (song.source == SongSource.local) {
      return QueryArtworkWidget(
        id: song.localId ?? 0,
        type: ArtworkType.AUDIO,
        artworkBorderRadius: BorderRadius.circular(10),
        artworkFit: BoxFit.cover,
        nullArtworkWidget: _defaultArtwork(),
        keepOldArtwork: true,
      );
    } else if (song.albumArt != null) {
      return CachedNetworkImage(
        imageUrl: song.albumArt!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _defaultArtwork(),
        errorWidget: (_, __, ___) => _defaultArtwork(),
      );
    }
    return _defaultArtwork();
  }

  Widget _defaultArtwork() {
    return Container(
      color: BeatFlowTheme.card,
      child: const Icon(
        Icons.music_note_rounded,
        color: BeatFlowTheme.textMuted,
        size: 24,
      ),
    );
  }

  Widget _buildSourceBadge() {
    if (song.source == SongSource.local) return const SizedBox.shrink();

    Color badgeColor;
    String label;

    switch (song.source) {
      case SongSource.youtube:
        badgeColor = BeatFlowTheme.youtubeRed;
        label = 'YT';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: badgeColor,
          fontFamily: 'Satoshi',
        ),
      ),
    );
  }

  Widget _buildEqualizer() {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: SizedBox(
        width: 24,
        height: 24,
        child: EqualizerBars(),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert, size: 20),
      color: BeatFlowTheme.textMuted,
      onPressed: onMorePressed ?? () => _showOptions(context),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
    );
  }

  void _handleTap(BuildContext context) {
    final provider = context.read<PlayerProvider>();
    if (song.source == SongSource.youtube) {
      provider.playYoutubeSong(song, queue: queue, index: queueIndex);
    } else {
      provider.playSong(song, queue: queue, index: queueIndex);
    }
  }

  void _showOptions(BuildContext context) {
    final provider = context.read<PlayerProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: BeatFlowTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SongOptionsSheet(
        song: song,
        provider: provider,
      ),
    );
  }
}

class _SongOptionsSheet extends StatelessWidget {
  final Song song;
  final PlayerProvider provider;

  const _SongOptionsSheet({required this.song, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isFav = provider.isFavorite(song);
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        const SizedBox(height: 16),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: BeatFlowTheme.card,
            child: Icon(Icons.music_note_rounded, color: BeatFlowTheme.accent),
          ),
          title: Text(song.title,
              style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w600,
                  color: BeatFlowTheme.textPrimary)),
          subtitle: Text(song.artist,
              style: const TextStyle(
                  fontFamily: 'Satoshi', color: BeatFlowTheme.textSecondary)),
        ),
        const Divider(color: BeatFlowTheme.border),
        _optionTile(
          context,
          icon: isFav ? Icons.favorite : Icons.favorite_border,
          iconColor: isFav ? BeatFlowTheme.accent : null,
          label: isFav ? 'Remove from Favorites' : 'Add to Favorites',
          onTap: () {
            provider.toggleFavorite(song);
            Navigator.pop(context);
          },
        ),
        _optionTile(
          context,
          icon: Icons.queue_music_rounded,
          label: 'Add to Queue',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to queue')),
            );
          },
        ),
        _optionTile(
          context,
          icon: Icons.playlist_add_rounded,
          label: 'Add to Playlist',
          onTap: () {
            Navigator.pop(context);
            _showAddToPlaylist(context);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _optionTile(BuildContext context,
      {required IconData icon,
      Color? iconColor,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? BeatFlowTheme.textSecondary),
      title: Text(label,
          style: const TextStyle(
              fontFamily: 'Satoshi', color: BeatFlowTheme.textPrimary)),
      onTap: onTap,
    );
  }

  void _showAddToPlaylist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BeatFlowTheme.surface,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text('Add to Playlist',
              style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: BeatFlowTheme.textPrimary)),
          const SizedBox(height: 8),
          ...provider.playlists.map((pl) => ListTile(
                leading: const Icon(Icons.queue_music_rounded,
                    color: BeatFlowTheme.accent),
                title: Text(pl.name,
                    style: const TextStyle(
                        fontFamily: 'Satoshi',
                        color: BeatFlowTheme.textPrimary)),
                onTap: () {
                  provider.addSongToPlaylist(pl.id, song);
                  Navigator.pop(context);
                },
              )),
          if (provider.playlists.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No playlists yet',
                  style: TextStyle(color: BeatFlowTheme.textSecondary)),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Animated equalizer bars
class EqualizerBars extends StatefulWidget {
  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
        3,
        (i) => AnimationController(
              vsync: this,
              duration: Duration(milliseconds: 300 + i * 100),
            )..repeat(reverse: true));
    _animations = _controllers
        .map((c) => Tween(begin: 0.2, end: 1.0).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Container(
            width: 3,
            height: 16 * _animations[i].value,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: BeatFlowTheme.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
