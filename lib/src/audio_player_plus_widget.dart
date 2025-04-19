import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audio_player_plus_controls.dart';
import 'utils.dart';

class AudioPlayerPlusWidget extends StatefulWidget {
  final String filePath;
  final Widget Function(
      BuildContext context,
      bool isPlaying,
      Duration current,
      Duration total,
      VoidCallback onPlayPause,
      VoidCallback onStop,
      )? customBuilder;

  const AudioPlayerPlusWidget({
    super.key,
    required this.filePath,
    this.customBuilder,
  });

  @override
  _AudioPlayerPlusWidgetState createState() => _AudioPlayerPlusWidgetState();
}

class _AudioPlayerPlusWidgetState extends State<AudioPlayerPlusWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _current = Duration.zero;
  Duration _total = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => _total = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _current = p);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _current = Duration.zero;
      });
    });
  }

  Future<void> _play() async {
    await _audioPlayer.setSourceDeviceFile(widget.filePath);
    await _audioPlayer.resume();
    setState(() => _isPlaying = true);
  }

  Future<void> _pause() async {
    await _audioPlayer.pause();
    setState(() => _isPlaying = false);
  }

  Future<void> _stop() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _current = Duration.zero;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the custom builder if provided, else use the default UI
    final builder = widget.customBuilder ?? _defaultUI;

    return builder(
      context,
      _isPlaying,
      _current,
      _total,
      _togglePlayPause,
      _stop,
    );
  }

  void _togglePlayPause() {
    _isPlaying ? _pause() : _play();
  }

  // Default UI if no custom builder is provided
  Widget _defaultUI(
      BuildContext context,
      bool isPlaying,
      Duration current,
      Duration total,
      VoidCallback onPlayPause,
      VoidCallback onStop,
      ) {
    return Column(
      children: [
        Text("${formatDuration(current)} / ${formatDuration(total)}"),
        Row(
          children: [
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: onPlayPause,
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: onStop,
            ),
          ],
        ),
      ],
    );
  }
}
