import 'audio_player_plus_widget.dart';

class AudioPlayerController {
  static final AudioPlayerController _instance = AudioPlayerController._internal();
  AudioPlayerPlusWidgetState? _currentPlayer;

  factory AudioPlayerController() => _instance;

  AudioPlayerController._internal();

  void register(AudioPlayerPlusWidgetState player) {
    if (_currentPlayer != null && _currentPlayer != player) {
      _currentPlayer!.stop();
    }
    _currentPlayer = player;
  }

  void unregister(AudioPlayerPlusWidgetState player) {
    if (_currentPlayer == player) {
      _currentPlayer = null;
    }
  }
}
