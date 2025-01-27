import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:myapp/modal/song.dart';
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

  Widget _buildNowPlayingMiniPlayer() {
    if (_currentSong == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to now playing screen
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.music_note, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentSong!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_currentSong!.artist != null)
                    Text(
                      _currentSong!.artist!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: togglePlayPause,
            ),
          ],
        ),
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
            : const Text('Music Player'),
        actions: [
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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _buildSongsList(),
                ),
                _buildNowPlayingMiniPlayer(),
              ],
            ),
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

  Widget _buildSongsList() {
    final filteredSongs = _getFilteredSongs();
    
    if (filteredSongs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _songs.isEmpty
                ? 'No music files found.\nAdd some MP3 files to your device and tap the refresh button.'
                : 'No songs match your search.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) {
        final song = filteredSongs[index];
        return ListTile(
          title: Text(
            song.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: song.artist != null
              ? Text(
                  song.artist!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          leading: const Icon(Icons.music_note),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Implement menu actions
              switch (value) {
                case 'add_to_playlist':
                  // Show playlist selection dialog
                  break;
                case 'share':
                  // Implement share functionality
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_to_playlist',
                child: Text('Add to Playlist'),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Text('Share'),
              ),
            ],
          ),
          onTap: () => playSong(song),
        );
      },
    );
  }
}