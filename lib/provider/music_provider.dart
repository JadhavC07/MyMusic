import 'package:flutter/material.dart';
import 'package:myapp/modal/song.dart';
import 'package:myapp/service/audio_service.dart';
import 'package:myapp/service/music_scanner.dart';

class MusicProvider extends ChangeNotifier {
  final AudioService _audioService;
  final MusicScanner _musicScanner;
  List<Song> _songs = [];
  bool _isPlaying = false;
  Song? _currentSong;
  bool _isLoading = true;
  String _searchQuery = '';

  MusicProvider({AudioService? audioService, MusicScanner? musicScanner})
    : _audioService = audioService ?? AudioService(),
      _musicScanner = musicScanner ?? MusicScanner();

  List<Song> get songs => _songs;
  bool get isPlaying => _isPlaying;
  Song? get currentSong => _currentSong;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Song> get filteredSongs {
    if (_searchQuery.isEmpty) return _songs;
    return _songs.where((song) {
      final searchLower = _searchQuery.toLowerCase();
      return song.name.toLowerCase().contains(searchLower) ||
          (song.artist?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  Future<void> scanMusic() async {
    try {
      _isLoading = true;
      notifyListeners();
      _songs = await _musicScanner.scanMusic();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playSong(Song song) async {
    try {
      await _audioService.playSong(song);
      _currentSong = song;
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null) return;
    try {
      await _audioService.togglePlayPause();
      _isPlaying = !_isPlaying;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void sortByTitle() {
    _songs.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void sortByArtist() {
    _songs.sort((a, b) => (a.artist ?? '').compareTo(b.artist ?? ''));
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
