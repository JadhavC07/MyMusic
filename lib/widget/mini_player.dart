import 'package:flutter/material.dart';
import 'package:myapp/modal/song.dart';

class MiniPlayer extends StatelessWidget {
  final Song currentSong;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback? onTap;

  const MiniPlayer({
    super.key,
    required this.currentSong,
    required this.isPlaying,
    required this.onPlayPause,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                    currentSong.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (currentSong.artist != null)
                    Text(
                      currentSong.artist!,
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
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: onPlayPause,
            ),
          ],
        ),
      ),
    );
  }
}