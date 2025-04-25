import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../audio_player_plus.dart';
import '../utils/utils.dart';

class AudioPlayerPlus extends StatefulWidget {
  /// audio file source
  final String audioPath;
  /// show the audio slider default Ui
  final bool showAudioSlider;
  final Widget Function(
    BuildContext context,
    bool isPlaying,
    String currentAudioDuration,
    String endAudioDuration,
    VoidCallback onPlayPause,
    VoidCallback onStop,
    Function(double) onSeek,
  )? customBuilder;

  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? thumbColor;
  final Color? overlayColor;
  final double? trackHeight;

  const AudioPlayerPlus({
    super.key,
    required this.audioPath,
    this.customBuilder,
    this.showAudioSlider = true,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.overlayColor,
    this.trackHeight,
  });

  @override
  AudioPlayerPlusState createState() => AudioPlayerPlusState();
}

class AudioPlayerPlusState extends State<AudioPlayerPlus> {
  /// Audio player instance
  final AudioPlayer audioPlayer = AudioPlayer();

  /// Current playback position
  Duration current = Duration.zero;

  /// Total duration of the audio
  Duration total = Duration.zero;

  /// Track if the audio is playing
  bool isPlaying = false;


  @override
  void initState() {
    super.initState();
    loadDuration();
    setupDurationListeners();
    final savedPosition = AudioPlayerController.instance.getSavedPosition(widget.audioPath);
    if (savedPosition != null) {
      setCurrentPosition(savedPosition);
    }
  }

  /// Listen to changes in the audio duration and position
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
        // Reset the current position
        current = Duration.zero;
        // Reset saved position
        AudioPlayerController.instance.resetPosition(widget.audioPath);
      });
    });
  }

  Future<void> loadDuration() async {
    try {
      await audioPlayer.setSourceUrl(widget.audioPath);
      final dur = await audioPlayer.getDuration();
      if (dur != null) {
        setState(() => total = dur);
      }
    } catch (e) {
      debugPrint('Failed to load duration: $e');
    }
  }
  // play audio control
  Future<void> play() async {
    // Register the player controller
    AudioPlayerController.instance.register(this);
    await audioPlayer.setSourceUrl(widget.audioPath);

    final savedPosition = AudioPlayerController.instance.getSavedPosition(widget.audioPath);
    if (savedPosition != null && savedPosition > Duration.zero) {
      // Seek to the saved position if any
      await audioPlayer.seek(savedPosition);
      // Update the current position
      setCurrentPosition(savedPosition);
    }

    await audioPlayer.resume();
    setState(() => isPlaying = true);
  }

  /// pause audio control
  Future<void> pause() async {
    await audioPlayer.pause();
    AudioPlayerController.instance.savePosition(widget.audioPath, current);
    setState(() => isPlaying = false);
  }

  /// stop audio control
  Future<void> stop() async {
    await audioPlayer.stop();
    AudioPlayerController.instance.resetPosition(widget.audioPath); // Reset position
    setState(() {
      isPlaying = false; // Update the play state to stopped
      current = Duration.zero; // Reset the position to the start
    });
  }
  /// Update the current position
  void setCurrentPosition(Duration position) {
    setState(() {
      current = position;
    });
  }

  Future<void> seekTo(double value) async {
    /// Convert the value to a Duration
    final position = Duration(seconds: value.toInt());
    /// Seek to the new position
    await audioPlayer.seek(position);
    setCurrentPosition(position);
    /// Save the new position
    AudioPlayerController.instance.savePosition(widget.audioPath, position);
  }

  @override
  void dispose() {
    AudioPlayerController.instance.unregister(this);
    audioPlayer.dispose();
    super.dispose();
  }

  void togglePlayPause() {
    isPlaying ? pause() : play();
  }

  @override
  Widget build(BuildContext context) {
    /// Use custom builder or default UI
    final builder = widget.customBuilder ?? defaultUI;

    /// Format position duration
    final currentDuration = Utils.formatDuration(current);
    final endDuration = Utils.formatDuration(total);

    return builder(
      context,
      isPlaying,
      currentDuration,
      endDuration,
      togglePlayPause,
      stop,
      seekTo,
    );
  }

  Widget defaultUI(
    BuildContext context,
    bool isPlaying,
    String formattedCurrent,
    String formattedTotal,
    VoidCallback onPlayPause,
    VoidCallback onStop,
    Function(double) onSeek,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Display current and total duration
        Text("$formattedCurrent / $formattedTotal",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.showAudioSlider) ...[
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.activeTrackColor ?? Colors.blueAccent,
              inactiveTrackColor: widget.inactiveTrackColor ?? Colors.grey[300],
              thumbColor: widget.thumbColor ?? Colors.blueAccent,
              overlayColor: widget.overlayColor ?? Colors.blue.withOpacity(0.2),
              trackHeight: widget.trackHeight ?? 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
            ),
            child: Slider(
              value: current.inSeconds.toDouble(),
              /// Current position in seconds
              max: total.inSeconds.toDouble() > 0
                  ? total.inSeconds.toDouble()
                  : 1.0,

              onChanged: (value) {
                onSeek(value);
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.blueAccent,
                size: 32,
              ),
              onPressed: onPlayPause,
            ),
            IconButton(
              icon: const Icon(
                Icons.stop,
                color: Colors.redAccent,
                size: 32,
              ),
              onPressed: onStop,
            ),
          ],
        ),
      ],
    );
  }
}
