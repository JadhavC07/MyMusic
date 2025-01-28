import 'package:flutter/material.dart';
import 'package:myapp/modal/song.dart';

class PlaylistDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> playlist;
  final List<Song> allSongs;

  const PlaylistDetailsScreen({
    super.key,
    required this.playlist,
    required this.allSongs,
  });

  @override
  State<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Song> playlistSongs = List<Song>.from(widget.playlist['songs']);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSongsDialog,
          ),
        ],
      ),
      body: playlistSongs.isEmpty
          ? Center(
              child: Text(
                'No songs in playlist\nTap + to add songs',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
              ),
            )
          : ListView.builder(
              itemCount: playlistSongs.length,
              itemBuilder: (context, index) {
                final song = playlistSongs[index];
                return ListTile(
                  title: Text(song.name),
                  subtitle: song.artist != null ? Text(song.artist!) : null,
                  leading: const Icon(Icons.music_note),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        widget.playlist['songs'].remove(song);
                      });
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showAddSongsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Songs'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.allSongs.length,
            itemBuilder: (context, index) {
              final song = widget.allSongs[index];
              final isInPlaylist = widget.playlist['songs'].contains(song);
              
              return CheckboxListTile(
                title: Text(song.name),
                subtitle: song.artist != null ? Text(song.artist!) : null,
                value: isInPlaylist,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      widget.playlist['songs'].add(song);
                    } else {
                      widget.playlist['songs'].remove(song);
                    }
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}