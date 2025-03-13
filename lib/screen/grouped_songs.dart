import 'package:flutter/material.dart';
import 'package:myapp/modal/song.dart';

class GroupSongsScreen extends StatelessWidget {
  final List<Song> songs;

  const GroupSongsScreen({super.key, required this.songs});

  Map<String, List<Song>> _groupSongsByArtist() {
    final grouped = <String, List<Song>>{};

    for (var song in songs) {
      final artist = song.artist ?? 'Unknown Artist';
      if (!grouped.containsKey(artist)) {
        grouped[artist] = [];
      }
      grouped[artist]!.add(song);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedSongs = _groupSongsByArtist();
    final artists = groupedSongs.keys.toList()..sort();

    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        final artistSongs = groupedSongs[artist]!;

        return ExpansionTile(
          title: Text(artist),
          subtitle: Text('${artistSongs.length} songs'),
          children:
              artistSongs
                  .map(
                    (song) => ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text(song.name),
                      onTap: () {
                        // TODO: Implement song playback
                      },
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}
