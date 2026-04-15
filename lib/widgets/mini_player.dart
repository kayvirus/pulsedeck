import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';
import '../providers/player_provider.dart';
import '../models/song_model.dart';
import '../theme/app_theme.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final song = provider.currentSong;
    if (song == null) return const SizedBox.shrink();

    final isPlaying = provider.player.playing;

    return GestureDetector(
      onTap: () => _openPlayer(context),
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
          _openPlayer(context);
        }
      },
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: BeatFlowTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BeatFlowTheme.border),
          boxShadow: [
            BoxShadow(
              color: BeatFlowTheme.accentGlow.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Progress bar background
              _buildProgressBar(provider),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Artwork
                    _buildArtwork(song),
                    const SizedBox(width: 12),

                    // Info
                    Expanded(child: _buildInfo(song)),

                    // Controls
                    _buildControls(context, provider, isPlaying),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(PlayerProvider provider) {
    return StreamBuilder(
      stream: provider.player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = provider.player.duration ?? Duration.zero;
        final progress = duration.inMilliseconds > 0
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0;

        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: BeatFlowTheme.border,
            valueColor: const AlwaysStoppedAnimation<Color>(BeatFlowTheme.accent),
            minHeight: 2,
          ),
        );
      },
    );
  }

  Widget _buildArtwork(Song song) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: BeatFlowTheme.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: song.source == SongSource.local
          ? QueryArtworkWidget(
              id: song.localId ?? 0,
              type: ArtworkType.AUDIO,
              artworkBorderRadius: BorderRadius.circular(10),
              artworkFit: BoxFit.cover,
              nullArtworkWidget: const Icon(
                Icons.music_note_rounded,
                color: BeatFlowTheme.textMuted,
                size: 20,
              ),
              keepOldArtwork: true,
            )
          : (song.albumArt != null
              ? CachedNetworkImage(
                  imageUrl: song.albumArt!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.music_note_rounded,
                    color: BeatFlowTheme.textMuted,
                  ),
                )
              : const Icon(
                  Icons.music_note_rounded,
                  color: BeatFlowTheme.textMuted,
                )),
    );
  }

  Widget _buildInfo(Song song) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          child: song.title.length > 25
              ? Marquee(
                  text: song.title,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: BeatFlowTheme.textPrimary,
                  ),
                  scrollAxis: Axis.horizontal,
                  blankSpace: 40,
                  velocity: 30,
                  pauseAfterRound: const Duration(seconds: 2),
                )
              : Text(
                  song.title,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: BeatFlowTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
        const SizedBox(height: 2),
        Text(
          song.artist,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 11,
            color: BeatFlowTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControls(
      BuildContext context, PlayerProvider provider, bool isPlaying) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 28,
          ),
          color: BeatFlowTheme.textPrimary,
          onPressed: provider.togglePlay,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded, size: 26),
          color: BeatFlowTheme.textSecondary,
          onPressed: provider.skipNext,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  void _openPlayer(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const PlayerScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}
