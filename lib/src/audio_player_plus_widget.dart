import 'package:audio_player_plus/audio_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerPlusWidget extends StatefulWidget {
  final String audioPath;
  final Widget Function(
      BuildContext context,
      bool isPlaying,
      String currentAudioDuration,
      String endAudioDuration,
      VoidCallback onPlayPause,
      VoidCallback onStop,
      )? customBuilder;

  const AudioPlayerPlusWidget({
    super.key,
    required this.audioPath,
    this.customBuilder,
  });

  @override
  AudioPlayerPlusWidgetState createState() => AudioPlayerPlusWidgetState();
}

class AudioPlayerPlusWidgetState extends State<AudioPlayerPlusWidget> {
  final AudioPlayer audioPlayer = AudioPlayer();

  Duration current = Duration.zero;
  Duration total = Duration.zero;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    loadDuration();
    setupDurationListeners();
  }

  void setupDurationListeners() {
    audioPlayer.onDurationChanged.listen((d) {
      setState(() => total = d);
    });

    audioPlayer.onPositionChanged.listen((p) {
      setState(() => current = p);
    });

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        current = Duration.zero;
      });
    });
  }

  Future<void> loadDuration() async {
    try {
      await audioPlayer.setSourceDeviceFile(widget.audioPath);
      final dur = await audioPlayer.getDuration();
      if (dur != null) {
        setState(() => total = dur);
      }
    } catch (e) {
      debugPrint('Failed to load duration: $e');
    }
  }

  Future<void> play() async {
    AudioPlayerController().register(this);
    await audioPlayer.setSourceDeviceFile(widget.audioPath);
    await audioPlayer.resume();
    setState(() => isPlaying = true);
  }

  Future<void> pause() async {
    await audioPlayer.pause();
    setState(() => isPlaying = false);
  }

  Future<void> stop() async {
    await audioPlayer.stop();
    setState(() {
      isPlaying = false;
      current = Duration.zero;
    });
  }

  @override
  void dispose() {
    AudioPlayerController().unregister(this);
    audioPlayer.dispose();
    super.dispose();
  }

  void togglePlayPause() {
    isPlaying ? pause() : play();
  }

  @override
  Widget build(BuildContext context) {
    final builder = widget.customBuilder ?? defaultUI;
    final formattedCurrent = Utils.formatDuration(current);
    final formattedTotal = Utils.formatDuration(total);

    return builder(
      context,
      isPlaying,
      formattedCurrent,
      formattedTotal,
      togglePlayPause,
      stop,
    );
  }

  Widget defaultUI(
      BuildContext context,
      bool isPlaying,
      String formattedCurrent,
      String formattedTotal,
      VoidCallback onPlayPause,
      VoidCallback onStop,
      ) {
    return Column(
      children: [
        Text("$formattedCurrent / $formattedTotal"),
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
