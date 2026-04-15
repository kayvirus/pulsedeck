import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audio_service/audio_service.dart';

import 'models/song_model.dart';
import 'models/song_model.g.dart';
import 'models/playlist_model.dart';
import 'models/playlist_model.g.dart';
import 'providers/player_provider.dart';
import 'providers/search_provider.dart';
import 'services/audio_handler.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

late BeatFlowAudioHandler _audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: BeatFlowTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(SongAdapter());
  Hive.registerAdapter(PlaylistAdapter());

  // Audio Service
  _audioHandler = await AudioService.init(
    builder: () => BeatFlowAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.kayode.beatflow.audio',
      androidNotificationChannelName: 'BeatFlow Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      notificationColor: Color(0xFFFF4D6D),
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PlayerProvider(_audioHandler)..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: const BeatFlowApp(),
    ),
  );
}

class BeatFlowApp extends StatelessWidget {
  const BeatFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeatFlow',
      debugShowCheckedModeBanner: false,
      theme: BeatFlowTheme.dark,
      home: const MainShell(),
    );
  }
}
