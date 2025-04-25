import 'package:audio_player_plus/audio_player_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DemoAppState());
}

class DemoAppState extends StatefulWidget {
  const DemoAppState({super.key});

  @override
  State<DemoAppState> createState() => _DemoAppStateState();
}

class _DemoAppStateState extends State<DemoAppState> {
  final List<String> audioUrls = [
    'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
    'https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3',
    'https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Sevish_-__nbsp_.mp3'
  ];

  double parseDurationToSeconds(String duration) {
    final parts = duration.split(':');
    final minutes = int.parse(parts[0]);
    final seconds = int.parse(parts[1]);
    return (minutes * 60 + seconds).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Custom Audio Player Plus Demo',
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Custom Audio Player Plus Demo'),
          elevation: 4,
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: audioUrls.length,
          itemBuilder: (context, index) => AudioPlayerPlus(showAudioSlider: true,
            audioPath: audioUrls[index],
            customBuilder: (
              context,
              isPlaying,
              currentDuration,
              endDuration,
              onPlayPause,
              onStop,
              onSeek,
            ) {
              final currentSeconds = parseDurationToSeconds(currentDuration);
              final totalSeconds = parseDurationToSeconds(endDuration);

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio : ${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          iconSize: 30,
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: Colors.deepPurple,
                          ),
                          onPressed: onPlayPause,
                        ),
                        IconButton(
                          iconSize: 28,
                          icon: Icon(
                            Icons.stop_circle_outlined,
                            color: Colors.redAccent,
                          ),
                          onPressed: onStop,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$currentDuration / $endDuration',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[800]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                        value: currentSeconds,
                        min: 0,
                        max: totalSeconds > 0 ? totalSeconds : 1.0,
                        onChanged: (value) async => await onSeek(value)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
