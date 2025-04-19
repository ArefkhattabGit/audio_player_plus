import 'package:audio_player_plus/audio_player_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DemoAppState());
}

class DemoAppState extends StatelessWidget {
  const DemoAppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audio Player Plus Plugin Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Audio Player Plus Plugin Demo'),
          elevation: 4,
        ),
        body: Center(
          child: AudioPlayerPlusWidget(
              filePath:
                  "https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3"),
        ),
      ),
    );
  }
}
