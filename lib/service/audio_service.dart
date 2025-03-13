import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:myapp/modal/song.dart';

class AudioService {
  final AudioPlayer player;

  AudioService() : player = AudioPlayer();

  Future<void> playSong(Song song) async {
    try {
      await player.stop();
      await player.setFilePath(song.path);
      await player.play();
    } catch (e) {
      debugPrint('Playback error: $e');
      rethrow;
    }
  }

  Future<void> togglePlayPause() async {
    try {
      if (player.playing) {
        await player.pause();
      } else {
        await player.play();
      }
    } catch (e) {
      debugPrint('Playback toggle error: $e');
      rethrow;
    }
  }

  void dispose() {
    player.dispose();
  }
}
