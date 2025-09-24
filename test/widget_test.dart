import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weather_app/main.dart';

void main() {
  testWidgets('WeatherApp loads home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that HomeScreen is loaded by checking for some text/widget.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
