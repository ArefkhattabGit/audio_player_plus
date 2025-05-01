import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../audio_player_plus.dart';
import '../utils/utils.dart';

class AudioPlayerPlus extends StatefulWidget {
  /// Audio file source
  final String audioPath;

  /// Show the audio slider default UI
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

  AudioPlayerPlus({
    super.key,
    required this.audioPath,
    this.customBuilder,
    this.showAudioSlider = true,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.overlayColor,
    this.trackHeight = 0.8,
  })
      : assert(trackHeight! >= 0.8 && trackHeight <= 10,
  'Slider height must be between 0.8 and 10.0'),
        assert(
        customBuilder == null ||
            (activeTrackColor == null &&
                inactiveTrackColor == null &&
                thumbColor == null &&
                overlayColor == null &&
                trackHeight == 0.8 &&
                showAudioSlider == true),
        'Cannot provide custom values (activeTrackColor,'
            ' inactiveTrackColor,'
            ' thumbColor,'
            ' overlayColor,'
            ' trackHeight,'
            ' or showAudioSlider) if customBuilder is used'),
        assert(audioPath != '', 'audioPath should not be empty');

  @override
  AudioPlayerPlusState createState() => AudioPlayerPlusState();
}

class AudioPlayerPlusState extends State<AudioPlayerPlus>
    with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    loadDuration();
    setupDurationListeners();
    final savedPosition =
    AudioPlayerController.instance.getSavedPosition(widget.audioPath);
    if (savedPosition != null) {
      setCurrentPosition(savedPosition);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    AudioPlayerController.instance.unregister(this);
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused && isPlaying) {
      // App is in the background, save position
      AudioPlayerController.instance.savePosition(widget.audioPath, current);
    } else if (state == AppLifecycleState.resumed && isPlaying) {
      // App is back in the foreground, resume playback if needed
      audioPlayer.resume();
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

  // Play audio control
  Future<void> play() async {
    try {
      AudioPlayerController.instance.register(this);
      await audioPlayer.setSourceUrl(widget.audioPath);

      // Set audio attributes for background playback based on platform
      AudioContext audioContext;
      if (Platform.isIOS) {
        audioContext = AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        );
      } else {
        audioContext = AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
        );
      }
      await audioPlayer.setAudioContext(audioContext);
      print('Audio context set successfully for ${Platform.isIOS
          ? 'iOS'
          : 'Android'}');

      final savedPosition =
      AudioPlayerController.instance.getSavedPosition(widget.audioPath);
      if (savedPosition != null && savedPosition > Duration.zero) {
        await audioPlayer.seek(savedPosition);
        setCurrentPosition(savedPosition);
      }

      await audioPlayer.resume();
      setState(() => isPlaying = true);
    } catch (e) {
      print('Error in play: $e');
    }
  }

  /// Pause audio control
  Future<void> pause() async {
    await audioPlayer.pause();
    AudioPlayerController.instance.savePosition(widget.audioPath, current);
    setState(() => isPlaying = false);
  }

  /// Stop audio control
  Future<void> stop() async {
    await audioPlayer.stop();
    AudioPlayerController.instance.resetPosition(
        widget.audioPath); // Reset position
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

  Widget defaultUI(BuildContext context,
      bool isPlaying,
      String formattedCurrent,
      String formattedTotal,
      VoidCallback onPlayPause,
      VoidCallback onStop,
      Function(double) onSeek,) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        /// Display current and total duration
        Text(
          "$formattedCurrent / $formattedTotal",
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
              overlayColor: widget.overlayColor ?? Colors.blue.withAlpha(51),
              trackHeight: widget.trackHeight ?? 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
            ),
            child: Slider(
              value: current.inSeconds.toDouble(),
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