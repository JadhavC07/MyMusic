import 'package:flutter/material.dart';
import 'package:myapp/modal/song.dart';

class PlaylistScreen extends StatefulWidget {
  final List<Song> songs;

  const PlaylistScreen({super.key, required this.songs});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final List<Map<String, dynamic>> _playlists = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _createPlaylist),
        ],
      ),
      body:
          _playlists.isEmpty
              ? Center(
                child: Text(
                  'No playlists yet\nTap + to create one',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400]),
                ),
              )
              : ListView.builder(
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  final playlist = _playlists[index];
                  return ListTile(
                    leading: const Icon(Icons.playlist_play),
                    title: Text(playlist['name']),
                    subtitle: Text('${playlist['songs'].length} songs'),
                    onTap: () => _openPlaylist(playlist),
                  );
                },
              ),
    );
  }

  void _createPlaylist() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('New Playlist'),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Playlist name'),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _playlists.add({'name': value, 'songs': []});
                  });
                  Navigator.pop(context);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Save playlist
                  Navigator.pop(context);
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _openPlaylist(Map<String, dynamic> playlist) {
    // TODO: Navigate to playlist details screen
  }
}
