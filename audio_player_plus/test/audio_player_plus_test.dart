import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_player_plus/audio_player_plus.dart';

void main() {
  testWidgets('AudioPlayerPlusWidget plays and pauses audio', (WidgetTester tester) async {
    final filePath = 'assets/audio/sample.mp3'; // Use a valid file path here

    // Build the widget.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AudioPlayerPlusWidget(filePath: filePath),
      ),
    ));

    // Verify initial state (paused)
    expect(find.text('00:00 / 00:00'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    // Tap the play button
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump(); // Rebuild the widget to reflect the play state

    // Verify the play state
    expect(find.byIcon(Icons.pause), findsOneWidget);

    // Tap the pause button
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump(); // Rebuild the widget to reflect the pause state

    // Verify the pause state
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('AudioPlayerPlusWidget stops audio', (WidgetTester tester) async {
    final filePath = 'assets/audio/sample.mp3'; // Use a valid file path here

    // Build the widget.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AudioPlayerPlusWidget(filePath: filePath),
      ),
    ));

    // Start playing the audio.
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    // Verify the play state
    expect(find.byIcon(Icons.pause), findsOneWidget);

    // Tap the stop button
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump(); // Rebuild the widget to reflect the stop state

    // Verify the stop state
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.text('00:00 / 00:00'), findsOneWidget); // Check that the position reset to 0
  });
}

