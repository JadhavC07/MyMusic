import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:myapp/modal/song.dart';
import 'package:myapp/screen/now_playing.dart';
import 'package:myapp/screen/playlist.dart';
import 'package:myapp/screen/settings.dart';
import 'package:myapp/widget/mini_player.dart';
import 'package:myapp/widget/song_list.dart';
import 'package:permission_handler/permission_handler.dart';


class MusicPlayerHome extends StatefulWidget {
  const MusicPlayerHome({super.key});

  @override
  State<MusicPlayerHome> createState() => _MusicPlayerHomeState();
}

class _MusicPlayerHomeState extends State<MusicPlayerHome> {
  final AudioPlayer _player = AudioPlayer();
  List<Song> _songs = [];
  bool _isPlaying = false;
  Song? _currentSong;
  bool _isLoading = true;
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    await requestPermission();
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  Future<void> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.audio.request();
        if (status.isGranted) {
          await scanMusic();
        } else {
          _showPermissionDialog();
        }
      }
    } catch (e) {
      debugPrint('Permission error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Audio permission is required to access music files.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> scanMusic() async {
    try {
      final List<Song> songs = [];
      if (Platform.isAndroid) {
        final directories = [
          '/storage/emulated/0/Music',
          '/storage/emulated/0/Download',
          '/storage/emulated/0/DCIM',
        ];

        for (final dirPath in directories) {
          final dir = Directory(dirPath);
          if (dir.existsSync()) {
            await _scanDirectory(dir.path, songs);
          }
        }
      }

      setState(() {
        _songs = songs..sort((a, b) => a.name.compareTo(b.name));
      });
    } catch (e) {
      debugPrint('Scan error: $e');
      _showErrorSnackBar('Error scanning music files');
    }
  }

  Future<void> _scanDirectory(String dirPath, List<Song> songs) async {
    try {
      final dir = Directory(dirPath);
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
          final name = _getSongName(entity.path);
          songs.add(
            Song(path: entity.path, name: name, artist: _extractArtist(name)),
          );
        }
      }
    } catch (e) {
      debugPrint('Directory scan error: $e');
    }
  }

  String _getSongName(String path) {
    final fileName = path.split('/').last;
    return fileName.replaceAll('.mp3', '').replaceAll('_', ' ');
  }

  String? _extractArtist(String songName) {
    final parts = songName.split('-');
    if (parts.length > 1) {
      return parts[0].trim();
    }
    return null;
  }

  Future<void> playSong(Song song) async {
    try {
      await _player.stop();
      await _player.setFilePath(song.path);
      await _player.play();

      setState(() {
        _currentSong = song;
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint('Playback error: $e');
      _showErrorSnackBar('Error playing the selected song');
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null) return;

    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }

      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      debugPrint('Playback toggle error: $e');
      _showErrorSnackBar('Error controlling playback');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Sort by'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                _songs.sort((a, b) => a.name.compareTo(b.name));
              });
              Navigator.pop(context);
            },
            child: const Text('Title'),
          ),
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                _songs.sort((a, b) => (a.artist ?? '').compareTo(b.artist ?? ''));
              });
              Navigator.pop(context);
            },
            child: const Text('Artist'),
          ),
        ],
      ),
    );
  }


  List<Song> _getFilteredSongs() {
    if (_searchQuery.isEmpty) return _songs;
    
    return _songs.where((song) {
      final searchLower = _searchQuery.toLowerCase();
      return song.name.toLowerCase().contains(searchLower) ||
          (song.artist?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  void _handleMenuItemSelected(Song song, String value) {
    switch (value) {
      case 'add_to_playlist':
        // Show playlist selection dialog
        break;
      case 'share':
        // Implement share functionality
        break;
    }
  }

  void _navigateToNowPlaying() {
    if (_currentSong == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NowPlayingScreen(
          currentSong: _currentSong!,
          player: _player,
          isPlaying: _isPlaying,
          onPlayPause: togglePlayPause,
          onNext: _playNextSong,
          onPrevious: _playPreviousSong,
        ),
      ),
    );
  }

  void _playNextSong() {
    if (_currentSong == null) return;
    final currentIndex = _songs.indexOf(_currentSong!);
    if (currentIndex < _songs.length - 1) {
      playSong(_songs[currentIndex + 1]);
    }
  }

  void _playPreviousSong() {
    if (_currentSong == null) return;
    final currentIndex = _songs.indexOf(_currentSong!);
    if (currentIndex > 0) {
      playSong(_songs[currentIndex - 1]);
    }
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildLibraryScreen();
      case 1:
        return PlaylistScreen(songs: _songs);
      case 2:
        return const SettingsScreen();
      default:
        return _buildLibraryScreen();
    }
  }

  Widget _buildLibraryScreen() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: _songs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No music files found.\nAdd some MP3 files to your device and tap the refresh button.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                )
              : SongsList(
                  songs: _getFilteredSongs(),
                  onSongTap: playSong,
                  onMenuItemSelected: _handleMenuItemSelected,
                ),
        ),
        if (_currentSong != null)
          MiniPlayer(
            currentSong: _currentSong!,
            isPlaying: _isPlaying,
            onPlayPause: togglePlayPause,
            onTap: _navigateToNowPlaying,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search songs...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                autofocus: true,
              )
            : Text(_currentIndex == 0 
                ? 'Music Player' 
                : _currentIndex == 1 
                    ? 'Playlists' 
                    : 'Settings'),
        actions: _currentIndex == 0 ? [
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => scanMusic(),
          ),
        ] : null,
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}