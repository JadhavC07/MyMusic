// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:metadata_god/metadata_god.dart';
// import 'package:myapp/modal/song.dart';

// class DirectoryScanner {
//   Future<void> scanDirectory(String dirPath, List<Song> songs) async {
//     try {
//       final dir = Directory(dirPath);
//       await for (var entity in dir.list(recursive: true, followLinks: false)) {
//         if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
//           try {
//             final metadata = await MetadataGod.readMetadata(file: entity.path);
//             final name = metadata.title ?? _getSongName(entity.path);
//             final artist = metadata.artist ?? _extractArtist(name);
//             final album = metadata.album;
//             final albumArt = metadata.picture;
            
//             songs.add(
//               Song(
//                 path: entity.path,
//                 name: name,
//                 artist: artist,
//                 album: album,
//                 albumArtUrl: albumArt != null ? 'data:image/jpeg;base64,${base64Encode(albumArt.data)}' : null,
//               ),
//             );
//           } catch (metadataError) {
//             debugPrint('Metadata extraction error for ${entity.path}: $metadataError');
//             // Fallback to basic file information if metadata extraction fails
//             songs.add(
//               Song(
//                 path: entity.path,
//                 name: _getSongName(entity.path),
//                 artist: null,
//                 album: null,
//                 albumArtUrl: null,
//               ),
//             );
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('Directory scan error: $e');
//       rethrow;
//     }
//   }

//   String _getSongName(String filePath) {
//     final fileName = path.basename(filePath);
//     // Remove the extension
//     final nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));
//     // Remove track numbers if present (e.g., "01 - " or "01.")
//     return nameWithoutExt.replaceFirst(RegExp(r'^\d+[\s.-]+'), '').trim();
//   }

//   String? _extractArtist(String songName) {
//     // Common patterns for artist-title separation
//     final patterns = [
//       RegExp(r'^(.*?)\s*-\s*(.*)$'),  // "Artist - Title"
//       RegExp(r'^(.*?)\s*–\s*(.*)$'),  // "Artist – Title" (em dash)
//       RegExp(r'^(.*?)\s*:\s*(.*)$'),  // "Artist: Title"
//     ];

//     for (var pattern in patterns) {
//       final match = pattern.firstMatch(songName);
//       if (match != null) {
//         return match.group(1)?.trim();
//       }
//     }
//     return null;
//   }
// }