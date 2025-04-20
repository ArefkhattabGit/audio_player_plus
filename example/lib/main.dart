import 'package:audio_player_plus/audio_player_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DemoAppState());
}

class DemoAppState extends StatefulWidget {
  DemoAppState({super.key});

  @override
  State<DemoAppState> createState() => _DemoAppStateState();
}

class _DemoAppStateState extends State<DemoAppState> {
  List<String> audioUrls = [
    'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
    'https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3',
    'https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Sevish_-__nbsp_.mp3'
  ];

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
          child: ListView.builder(
            itemCount: audioUrls.length,
            itemBuilder: (context, index) =>
                ListTile(
                  contentPadding: EdgeInsetsDirectional.all(10),
                  title: AudioPlayerPlusWidget(
                    audioPath: audioUrls[index],
                  ),
                ),),
        ),
      ),
    );
  }
}
