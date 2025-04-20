import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_player_plus/audio_player_plus.dart';

void main() {
  testWidgets('AudioPlayerPlusWidget plays and pauses audio', (WidgetTester tester) async {
    final filePath = 'assets/audio/sample.mp3';

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AudioPlayerPlusWidget(audioPath: filePath),
      ),
    ));

    expect(find.text('00:00 / 00:00'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(find.byIcon(Icons.pause), findsOneWidget);

     await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();

     expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

 }

