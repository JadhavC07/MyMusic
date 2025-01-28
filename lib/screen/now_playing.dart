import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:myapp/modal/song.dart';

class NowPlayingScreen extends StatefulWidget {
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
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _playPauseController;
  bool _isShuffleEnabled = false;
  bool _isRepeatEnabled = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _playPauseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    if (widget.isPlaying) {
      _playPauseController.forward();
    }
  }

  @override
  void dispose() {
    _playPauseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 30),
                  // Album Art with Animation
                  _buildAlbumArt(),
                  const SizedBox(height: 40),
                  // Song Info
                  _buildSongInfo(),
                  const SizedBox(height: 20),
                  // Progress Bar
                  _buildProgressBar(),
                  const SizedBox(height: 30),
                  // Control Buttons
                  _buildControlButtons(),
                  const SizedBox(height: 30),
                  // Additional Features
                  _buildAdditionalFeatures(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          const Text(
            'NOW PLAYING',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.queue_music),
            onPressed: () {
              // TODO: Show queue
            },
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Hero(
      tag: 'album_art_${widget.currentSong.name}',
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Colors.grey[850],
            child: const Icon(
              Icons.music_note,
              size: 100,
              color: Colors.white24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo() {
    return Column(
      children: [
        Text(
          widget.currentSong.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (widget.currentSong.artist != null)
          Text(
            widget.currentSong.artist!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
              letterSpacing: 0.5,
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return StreamBuilder<Duration>(
      stream: widget.player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = widget.player.duration ?? Duration.zero;

        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: Colors.blue,
                inactiveTrackColor: Colors.grey[800],
                thumbColor: Colors.white,
                overlayColor: Colors.blue.withOpacity(0.2),
              ),
              child: Slider(
                value: position.inSeconds.toDouble(),
                max: duration.inSeconds.toDouble(),
                onChanged: (value) {
                  widget.player.seek(Duration(seconds: value.toInt()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.shuffle,
            color: _isShuffleEnabled ? Colors.blue : Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isShuffleEnabled = !_isShuffleEnabled;
            });
          },
          iconSize: 24,
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          onPressed: widget.onPrevious,
          iconSize: 40,
        ),
        GestureDetector(
          onTap: () {
            widget.onPlayPause();
            if (widget.isPlaying) {
              _playPauseController.reverse();
            } else {
              _playPauseController.forward();
            }
          },
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _playPauseController,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white),
          onPressed: widget.onNext,
          iconSize: 40,
        ),
        IconButton(
          icon: Icon(
            Icons.repeat,
            color: _isRepeatEnabled ? Colors.blue : Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isRepeatEnabled = !_isRepeatEnabled;
            });
          },
          iconSize: 24,
        ),
      ],
    );
  }

  Widget _buildAdditionalFeatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.devices, color: Colors.white),
          onPressed: () {
            // TODO: Implement device selection
          },
        ),
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            // TODO: Implement share functionality
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
