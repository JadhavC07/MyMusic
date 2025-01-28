import 'package:flutter/material.dart';
import 'package:myapp/modal/song.dart';

class SongsList extends StatelessWidget {
  final List<Song> songs;
  final Function(Song) onSongTap;
  final Function(Song, String) onMenuItemSelected;

  const SongsList({
    super.key,
    required this.songs,
    required this.onSongTap,
    required this.onMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No songs match your search.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
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
            onSelected: (value) => onMenuItemSelected(song, value),
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
          onTap: () => onSongTap(song),
        );
      },
    );
  }
}