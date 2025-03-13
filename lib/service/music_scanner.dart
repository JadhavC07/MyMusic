import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/modal/song.dart';

class MusicScanner {
  static final List<String> _defaultDirectories = [
    '/storage/emulated/0/Music',
    '/storage/emulated/0/Download',
    '/storage/emulated/0/DCIM',
  ];

  Future<List<Song>> scanMusic() async {
    try {
      final List<Song> songs = [];
      if (Platform.isAndroid) {
        for (final dirPath in _defaultDirectories) {
          final dir = Directory(dirPath);
          if (dir.existsSync()) {
            await _scanDirectory(dir.path, songs);
          }
        }
      }
      return songs..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      debugPrint('Scan error: $e');
      rethrow;
    }
  }

  Future<void> _scanDirectory(String dirPath, List<Song> songs) async {
    try {
      final dir = Directory(dirPath);
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
          final name = _getSongName(entity.path);
          songs.add(
            Song(
              path: entity.path,
              name: name,
              artist: _extractArtist(name),
              album: null,
              albumArtUrl: null,
            ),
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
}
