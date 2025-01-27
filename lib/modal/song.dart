class Song {
  final String path;
  final String name;
  final String? artist;
  final Duration? duration;

  Song({required this.path, required this.name, this.artist, this.duration});
}