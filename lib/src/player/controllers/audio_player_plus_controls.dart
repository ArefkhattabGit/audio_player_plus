import 'package:audio_player_plus/audio_player_plus.dart';

class AudioPlayerController {
  static final AudioPlayerController _instance =
  AudioPlayerController._internal();

  AudioPlayerController._internal();

  /// AudioPlayerController getter instance
  static AudioPlayerController get instance => _instance;

  AudioPlayerPlusState? _currentPlayer;

  /// Map to store the last playback position for each audio path
  final Map<String, Duration> audioPositions = {};

  /// Register a player. If another one is already playing, pause it and save its position.
  void register(AudioPlayerPlusState player) async {
    if (_currentPlayer != null && _currentPlayer != player) {
      // Save the current position of the previous player
      audioPositions[_currentPlayer!.widget.audioPath] =
          _currentPlayer!.current;
      await _currentPlayer!.pause(); // Pause to preserve state
    }
    _currentPlayer = player;

    // Check if the player is ready to seek
    try {
      // Wait for the audio player to be ready
      await player.audioPlayer
          .setSourceUrl(player.widget.audioPath); // Ensure the source is set
      final savedPosition = audioPositions[player.widget.audioPath];
      if (savedPosition != null) {
        await player.audioPlayer.seek(savedPosition).timeout(
          Duration(seconds: 10), // 10-second timeout for seek operation
          onTimeout: () {
            print("Seek operation timed out");
            return Future.value(); // Handle timeout gracefully
          },
        );
        player
            .setCurrentPosition(savedPosition); // Update UI with saved position
      }
    } catch (e) {
      print("Error in register: $e");
    }
  }

  /// Unregister the player if it's the current one and save its position.
  void unregister(AudioPlayerPlusState player) {
    if (_currentPlayer == player) {
      // Save the current position before unregistering
      audioPositions[player.widget.audioPath] = player.current;
      _currentPlayer = null;
    }
  }

  /// Get the saved position for an audio path
  Duration? getSavedPosition(String audioPath) {
    return audioPositions[audioPath];
  }

  /// Reset the saved position for an audio path (used when stopping)
  void resetPosition(String audioPath) {
    audioPositions[audioPath] = Duration.zero;
  }

  /// Save the position for an audio path (used when pausing)
  void savePosition(String audioPath, Duration position) {
    audioPositions[audioPath] = position;
  }
}
