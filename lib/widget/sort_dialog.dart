import 'package:flutter/material.dart';
import 'package:myapp/provider/music_provider.dart';
import 'package:provider/provider.dart';

class SortDialog extends StatelessWidget {
  const SortDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    return SimpleDialog(
      title: const Text('Sort by'),
      children: [
        SimpleDialogOption(
          onPressed: () {
            musicProvider.sortByTitle();
            Navigator.pop(context);
          },
          child: const Text('Title'),
        ),
        SimpleDialogOption(
          onPressed: () {
            musicProvider.sortByArtist();
            Navigator.pop(context);
          },
          child: const Text('Artist'),
        ),
      ],
    );
  }
}