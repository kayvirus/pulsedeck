import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import '../providers/player_provider.dart';
import '../models/song_model.dart';
import '../theme/app_theme.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeatFlowTheme.bg,
      body: Consumer<PlayerProvider>(
        builder: (context, provider, _) {
          final song = provider.currentSong;
          if (song == null) {
            return const Center(child: Text('No song playing'));
          }
          return _PlayerContent(song: song, provider: provider);
        },
      ),
    );
  }
}

class _PlayerContent extends StatefulWidget {
  final Song song;
  final PlayerProvider provider;

  const _PlayerContent({required this.song, required this.provider});

  @override
  State<_PlayerContent> createState() => _PlayerContentState();
}

class _PlayerContentState extends State<_PlayerContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _artworkController;
  bool _showQueue = false;

  @override
  void initState() {
    super.initState();
    _artworkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    if (widget.provider.player.playing) {
      _artworkController.repeat();
    }
  }

  @override
  void dispose() {
    _artworkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPlaying = widget.provider.player.playing;

    if (isPlaying) {
      _artworkController.repeat();
    } else {
      _artworkController.stop();
    }

    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A0A15), Color(0xFF0A0A0F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              const SizedBox(height: 16),

              if (_showQueue)
                Expanded(child: _buildQueuePanel())
              else ...[
                // Rotating artwork
                Expanded(
                  flex: 4,
                  child: Center(child: _buildArtwork(size)),
                ),

                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildSongInfo(),
                      const SizedBox(height: 8),
                      _buildProgressSection(),
                      const SizedBox(height: 8),
                      _buildControls(),
                      const SizedBox(height: 8),
                      _buildBottomActions(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
            color: BeatFlowTheme.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Column(
            children: [
              const Text(
                'NOW PLAYING',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: BeatFlowTheme.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              _buildSourceBadge(),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _showQueue ? Icons.queue_music : Icons.queue_music_outlined,
              size: 24,
            ),
            color: _showQueue ? BeatFlowTheme.accent : BeatFlowTheme.textSecondary,
            onPressed: () => setState(() => _showQueue = !_showQueue),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceBadge() {
    if (widget.song.source == SongSource.local) {
      return const Text(
        'LOCAL',
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 10,
          color: BeatFlowTheme.textSecondary,
          letterSpacing: 1,
        ),
      );
    } else if (widget.song.source == SongSource.youtube) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: BeatFlowTheme.youtubeRed.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: BeatFlowTheme.youtubeRed.withOpacity(0.5)),
        ),
        child: const Text(
          'YOUTUBE',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: BeatFlowTheme.youtubeRed,
            letterSpacing: 1,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildArtwork(Size size) {
    final artSize = size.width * 0.72;

    return AnimatedBuilder(
      animation: _artworkController,
      builder: (_, child) => Transform.rotate(
        angle: widget.provider.player.playing
            ? _artworkController.value * 2 * 3.14159
            : 0,
        child: child,
      ),
      child: Container(
        width: artSize,
        height: artSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: BeatFlowTheme.card,
          boxShadow: [
            BoxShadow(
              color: BeatFlowTheme.accentGlow,
              blurRadius: 40,
              spreadRadius: 10,
            ),
            const BoxShadow(
              color: Colors.black54,
              blurRadius: 20,
              spreadRadius: 5,
              offset: Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: widget.song.source == SongSource.local
            ? QueryArtworkWidget(
                id: widget.song.localId ?? 0,
                type: ArtworkType.AUDIO,
                artworkFit: BoxFit.cover,
                artworkBorderRadius: BorderRadius.circular(artSize),
                nullArtworkWidget: _defaultArtwork(artSize),
                keepOldArtwork: true,
              )
            : (widget.song.albumArt != null
                ? CachedNetworkImage(
                    imageUrl: widget.song.albumArt!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _defaultArtwork(artSize),
                  )
                : _defaultArtwork(artSize)),
      ),
    );
  }

  Widget _defaultArtwork(double size) {
    return Container(
      color: BeatFlowTheme.card,
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: BeatFlowTheme.textMuted,
          size: size * 0.35,
        ),
      ),
    );
  }

  Widget _buildSongInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 28,
                  child: widget.song.title.length > 22
                      ? Marquee(
                          text: widget.song.title,
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: BeatFlowTheme.textPrimary,
                          ),
                          blankSpace: 50,
                          velocity: 30,
                          pauseAfterRound: const Duration(seconds: 2),
                        )
                      : Text(
                          widget.song.title,
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: BeatFlowTheme.textPrimary,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.song.artist,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 15,
                    color: BeatFlowTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Favorite button
          Consumer<PlayerProvider>(
            builder: (context, provider, _) {
              final isFav = provider.isFavorite(widget.song);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 26,
                ),
                color: isFav ? BeatFlowTheme.accent : BeatFlowTheme.textMuted,
                onPressed: () => provider.toggleFavorite(widget.song),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: StreamBuilder(
        stream: widget.provider.audioHandler.positionDataStream,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final position = data?.position ?? Duration.zero;
          final duration = data?.duration ?? Duration.zero;
          final buffered = data?.bufferedPosition ?? Duration.zero;

          return Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: BeatFlowTheme.accent,
                  inactiveTrackColor: BeatFlowTheme.border,
                  thumbColor: Colors.white,
                  overlayColor: BeatFlowTheme.accentGlow,
                  secondaryActiveTrackColor:
                      BeatFlowTheme.accent.withOpacity(0.3),
                ),
                child: Slider(
                  value: position.inMilliseconds
                      .clamp(0, duration.inMilliseconds)
                      .toDouble(),
                  max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                  secondaryTrackValue: buffered.inMilliseconds
                      .clamp(0, duration.inMilliseconds)
                      .toDouble(),
                  onChanged: (v) =>
                      widget.provider.seek(Duration(milliseconds: v.toInt())),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        color: BeatFlowTheme.textSecondary,
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        color: BeatFlowTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControls() {
    return Consumer<PlayerProvider>(builder: (context, provider, _) {
      final isPlaying = provider.player.playing;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Shuffle
            IconButton(
              icon: const Icon(Icons.shuffle_rounded, size: 24),
              color: provider.shuffleEnabled
                  ? BeatFlowTheme.accent
                  : BeatFlowTheme.textMuted,
              onPressed: provider.toggleShuffle,
            ),

            // Previous
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded, size: 36),
              color: BeatFlowTheme.textPrimary,
              onPressed: provider.skipPrevious,
            ),

            // Play/Pause
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: BFGradients.accentGradient,
                boxShadow: [
                  BoxShadow(
                    color: BeatFlowTheme.accentGlow,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 36,
                ),
                color: Colors.white,
                onPressed: provider.togglePlay,
              ),
            ),

            // Next
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, size: 36),
              color: BeatFlowTheme.textPrimary,
              onPressed: provider.skipNext,
            ),

            // Repeat
            IconButton(
              icon: Icon(
                provider.loopMode == LoopMode.one
                    ? Icons.repeat_one_rounded
                    : Icons.repeat_rounded,
                size: 24,
              ),
              color: provider.loopMode != LoopMode.off
                  ? BeatFlowTheme.accent
                  : BeatFlowTheme.textMuted,
              onPressed: provider.cycleRepeatMode,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionButton(
            icon: Icons.speed_rounded,
            label: 'Speed',
            onTap: () => _showSpeedSheet(context),
          ),
          _actionButton(
            icon: Icons.equalizer_rounded,
            label: 'EQ',
            onTap: () {},
          ),
          _actionButton(
            icon: Icons.timer_outlined,
            label: 'Sleep',
            onTap: () => _showSleepTimer(context),
          ),
          _actionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: BeatFlowTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BeatFlowTheme.border),
            ),
            child: Icon(icon, color: BeatFlowTheme.textSecondary, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 10,
              color: BeatFlowTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueuePanel() {
    final queue = widget.provider.currentQueue;
    final currentIdx = widget.provider.currentIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'Up Next',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: BeatFlowTheme.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: queue.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, i) {
              final song = queue[i];
              final isActive = i == currentIdx;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                leading: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        isActive ? BeatFlowTheme.accent : BeatFlowTheme.textMuted,
                  ),
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? BeatFlowTheme.accent
                        : BeatFlowTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  song.artist,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12,
                    color: BeatFlowTheme.textSecondary,
                  ),
                ),
                onTap: () {
                  widget.provider.playSong(song,
                      queue: queue, index: i);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSpeedSheet(BuildContext context) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
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
          const Text('Playback Speed',
              style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: BeatFlowTheme.textPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: speeds.map((s) {
              return ActionChip(
                label: Text('${s}x',
                    style: const TextStyle(fontFamily: 'Satoshi')),
                backgroundColor: BeatFlowTheme.card,
                side: const BorderSide(color: BeatFlowTheme.border),
                onPressed: () {
                  widget.provider.player.setSpeed(s);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showSleepTimer(BuildContext context) {
    final options = [15, 30, 45, 60];
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
          const Text('Sleep Timer',
              style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: BeatFlowTheme.textPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: options.map((m) {
              return ActionChip(
                label: Text('$m min',
                    style: const TextStyle(fontFamily: 'Satoshi')),
                backgroundColor: BeatFlowTheme.card,
                side: const BorderSide(color: BeatFlowTheme.border),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Sleep timer set for $m minutes')),
                  );
                  Future.delayed(Duration(minutes: m), () {
                    widget.provider.audioHandler.pause();
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
