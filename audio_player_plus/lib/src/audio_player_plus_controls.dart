// lib/src/audio_player_plus_controls.dart

import 'package:flutter/material.dart';

Widget audioPlayerPlusControls({
  required bool isPlaying,
  required VoidCallback onPlayPause,
  required VoidCallback onStop,
}) {
  return Row(
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
  );
}
