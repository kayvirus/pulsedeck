import 'package:flutter/foundation.dart';
import '../models/song_model.dart';
import '../services/youtube_service.dart';

enum SearchTab { local, youtube, platforms }

class SearchProvider extends ChangeNotifier {
  final YouTubeService _ytService = YouTubeService();

  String _query = '';
  SearchTab _activeTab = SearchTab.local;
  bool _isSearching = false;

  List<Song> _youtubeResults = [];
  List<Song> _localResults = [];
  String? _searchError;

  String get query => _query;
  SearchTab get activeTab => _activeTab;
  bool get isSearching => _isSearching;
  List<Song> get youtubeResults => _youtubeResults;
  List<Song> get localResults => _localResults;
  String? get searchError => _searchError;

  void setTab(SearchTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void setLocalResults(List<Song> results) {
    _localResults = results;
    notifyListeners();
  }

  Future<void> searchYoutube(String query) async {
    if (query.trim().isEmpty) {
      _youtubeResults = [];
      notifyListeners();
      return;
    }

    _query = query;
    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      _youtubeResults = await _ytService.search(query);
      _searchError = null;
    } catch (e) {
      _searchError = 'Search failed. Check your connection.';
      _youtubeResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _youtubeResults = [];
    _localResults = [];
    _searchError = null;
    notifyListeners();
  }
}
