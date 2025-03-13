class Song {
  final String path;
  final String name;
  final String? artist;
  final String? album;
  final String? albumArtUrl;
  final Duration? duration;

  Song({
    required this.path,
    required this.name,
    this.artist,
    this.album,
    this.albumArtUrl,
    this.duration,
  });
}
