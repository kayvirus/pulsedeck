import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _libraryKey = 'local_library';

  Future<List<String>> readLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_libraryKey) ?? <String>[];
  }

  Future<void> saveLibrary(List<String> encodedTracks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_libraryKey, encodedTracks);
  }
}
