import 'audio_player_plus_widget.dart';

class AudioPlayerController {
  static final AudioPlayerController _instance = AudioPlayerController._internal();
  AudioPlayerPlusWidgetState? _currentPlayer;

  /// Get the shared instance of this controller.
  factory AudioPlayerController() => _instance;

  AudioPlayerController._internal();

  /// Register a player If another one is already playing, stop it.
  void register(AudioPlayerPlusWidgetState player) {
    if (_currentPlayer != null && _currentPlayer != player) {
      _currentPlayer!.stop();
    }
    _currentPlayer = player;
  }

  /// Unregister the player if its the current one.
  void unregister(AudioPlayerPlusWidgetState player) {
    if (_currentPlayer == player) {
      _currentPlayer = null;
    }
  }
}
