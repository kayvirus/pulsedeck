import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BeatFlowTheme {
  // Core palette
  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF131318);
  static const Color card = Color(0xFF1C1C24);
  static const Color cardHover = Color(0xFF232330);
  static const Color border = Color(0xFF2A2A38);

  static const Color accent = Color(0xFFFF4D6D);
  static const Color accentGlow = Color(0x40FF4D6D);
  static const Color accentSecondary = Color(0xFF7C5CFC);
  static const Color accentTertiary = Color(0xFF00D2FF);

  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF8888A8);
  static const Color textMuted = Color(0xFF4A4A62);

  static const Color youtubeRed = Color(0xFFFF0000);
  static const Color spotifyGreen = Color(0xFF1DB954);
  static const Color appleMusic = Color(0xFFFC3C44);
  static const Color audiomackOrange = Color(0xFFFF5500);

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentSecondary,
        surface: surface,
        background: bg,
        error: Color(0xFFFF4444),
      ),
      fontFamily: 'Satoshi',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: textPrimary,
            letterSpacing: -1.5),
        displayMedium: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: textPrimary,
            letterSpacing: -1),
        displaySmall: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textPrimary),
        headlineMedium: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textPrimary),
        headlineSmall: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary),
        titleLarge: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary),
        titleMedium: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textSecondary),
        bodyLarge: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 15,
            color: textPrimary),
        bodyMedium: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 13,
            color: textSecondary),
        bodySmall: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 11,
            color: textMuted),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: border,
        thumbColor: accent,
        overlayColor: accentGlow,
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      iconTheme: const IconThemeData(color: textSecondary, size: 24),
      dividerColor: border,
      useMaterial3: true,
    );
  }
}

// Gradient helpers
class BFGradients {
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF4D6D), Color(0xFF7C5CFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C1C24), Color(0xFF131318)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient playerGradient(Color dominantColor) => LinearGradient(
    colors: [dominantColor.withOpacity(0.8), BeatFlowTheme.bg],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient glowGradient = RadialGradient(
    colors: [Color(0x30FF4D6D), Colors.transparent],
    radius: 0.8,
  );
}
