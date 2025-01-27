import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:myapp/modal/song.dart';

class NowPlayingScreen extends StatelessWidget {
  final Song currentSong;
  final AudioPlayer player;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const NowPlayingScreen({
    super.key,
    required this.currentSong,
    required this.player,
    required this.isPlaying,
    required this.onPlayPause,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Album Art
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.music_note, size: 150, color: Colors.white54),
          ),
          
          // Song Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  currentSong.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (currentSong.artist != null)
                  Text(
                    currentSong.artist!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
          ),

          // Progress Bar
          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = player.duration ?? Duration.zero;
              return Column(
                children: [
                  Slider(
                    value: position.inSeconds.toDouble(),
                    max: duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      player.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position)),
                        Text(_formatDuration(duration)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.shuffle),
                onPressed: () {}, // TODO: Implement shuffle
                iconSize: 32,
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: onPrevious,
                iconSize: 48,
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                onPressed: onPlayPause,
                iconSize: 64,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: onNext,
                iconSize: 48,
              ),
              IconButton(
                icon: const Icon(Icons.repeat),
                onPressed: () {}, // TODO: Implement repeat
                iconSize: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}