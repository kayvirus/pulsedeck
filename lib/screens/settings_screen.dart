import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _volume = 1.0;
  bool _gaplessPlayback = true;
  bool _showNotification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeatFlowTheme.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverList(
              delegate: SliverChildListDelegate([
                _section('AUDIO', [
                  _volumeControl(),
                  _toggleTile(
                    icon: Icons.skip_next_rounded,
                    label: 'Gapless Playback',
                    subtitle: 'Smooth transition between songs',
                    value: _gaplessPlayback,
                    onChanged: (v) => setState(() => _gaplessPlayback = v),
                  ),
                ]),
                _section('NOTIFICATIONS', [
                  _toggleTile(
                    icon: Icons.notifications_outlined,
                    label: 'Media Notification',
                    subtitle: 'Show player controls in status bar',
                    value: _showNotification,
                    onChanged: (v) => setState(() => _showNotification = v),
                  ),
                ]),
                _section('ABOUT', [
                  _infoTile(
                    icon: Icons.music_note_rounded,
                    label: 'BeatFlow',
                    subtitle: 'Version 1.0.0',
                  ),
                  _infoTile(
                    icon: Icons.code_rounded,
                    label: 'Built for',
                    subtitle: 'Kayode — Personal Music Universe',
                  ),
                ]),
                const SizedBox(height: 80),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SETTINGS',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: BeatFlowTheme.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Preferences',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: BeatFlowTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: BeatFlowTheme.textMuted,
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: BeatFlowTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BeatFlowTheme.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _volumeControl() {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.volume_down_rounded,
                  color: BeatFlowTheme.textSecondary, size: 22),
              Expanded(
                child: Slider(
                  value: _volume,
                  min: 0,
                  max: 1,
                  onChanged: (v) {
                    setState(() => _volume = v);
                    provider.player.setVolume(v);
                  },
                ),
              ),
              const Icon(Icons.volume_up_rounded,
                  color: BeatFlowTheme.textSecondary, size: 22),
            ],
          ),
        );
      },
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: BeatFlowTheme.textSecondary, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: BeatFlowTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 12,
          color: BeatFlowTheme.textSecondary,
        ),
      ),
      value: value,
      activeColor: BeatFlowTheme.accent,
      onChanged: onChanged,
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: BeatFlowTheme.accent, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: BeatFlowTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 12,
          color: BeatFlowTheme.textSecondary,
        ),
      ),
    );
  }
}
