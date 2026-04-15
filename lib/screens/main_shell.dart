import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import 'library_screen.dart';
import 'search_screen.dart';
import 'playlists_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    LibraryScreen(),
    SearchScreen(),
    PlaylistsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeatFlowTheme.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player
          Consumer<PlayerProvider>(
            builder: (context, provider, _) {
              if (provider.currentSong == null) return const SizedBox.shrink();
              return const MiniPlayer();
            },
          ),

          // Bottom nav
          Container(
            decoration: const BoxDecoration(
              color: BeatFlowTheme.surface,
              border: Border(
                top: BorderSide(color: BeatFlowTheme.border, width: 0.5),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              backgroundColor: Colors.transparent,
              selectedItemColor: BeatFlowTheme.accent,
              unselectedItemColor: BeatFlowTheme.textMuted,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedLabelStyle: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 11,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music_outlined),
                  activeIcon: Icon(Icons.library_music_rounded),
                  label: 'Library',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  activeIcon: Icon(Icons.search_rounded),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.queue_music_outlined),
                  activeIcon: Icon(Icons.queue_music_rounded),
                  label: 'Playlists',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.tune_outlined),
                  activeIcon: Icon(Icons.tune_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
