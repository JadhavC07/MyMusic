import 'package:flutter/material.dart';
import 'package:myapp/modal/song.dart';
import 'package:myapp/screen/playlist_details.dart';

class PlaylistScreen extends StatefulWidget {
  final List<Song> songs;

  const PlaylistScreen({super.key, required this.songs});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final List<Map<String, dynamic>> _playlists = [];
  final TextEditingController _playlistNameController = TextEditingController();

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _createPlaylist,
        child: const Icon(Icons.add),
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
              controller: _playlistNameController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Playlist name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final name = _playlistNameController.text.trim();
                  if (name.isNotEmpty) {
                    setState(() {
                      _playlists.add({'name': name, 'songs': <Song>[]});
                    });
                    _playlistNameController.clear();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _openPlaylist(Map<String, dynamic> playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PlaylistDetailsScreen(
              playlist: playlist,
              allSongs: widget.songs,
            ),
      ),
    );
  }
}
