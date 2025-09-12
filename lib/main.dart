import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  bool _darkMode = false;
  String _unit = "metric";

  void _updateSettings(bool darkMode, String unit) {
    setState(() {
      _darkMode = darkMode;
      _unit = unit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _darkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(
        unit: _unit,
        darkMode: _darkMode,
        onSettingsChanged: _updateSettings,
      ),
    );
  }
}
