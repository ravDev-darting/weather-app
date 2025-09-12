import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// Screens
import 'settings_screen.dart';
import 'forecast_screen.dart';
import 'radar_screen.dart';

class HomeScreen extends StatefulWidget {
  final String unit; // "metric" or "imperial"
  final bool darkMode;
  final Function(bool darkMode, String unit)? onSettingsChanged;

  const HomeScreen({
    super.key,
    required this.unit,
    required this.darkMode,
    this.onSettingsChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _unit;
  late bool _darkMode;
  String _weather = "Loading...";
  String _city = "";
  String _country = "";
  String? _iconCode;
  String _condition = ""; // NEW: weather condition (Clear sky, Rain, etc.)

  final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";

  @override
  void initState() {
    super.initState();
    _unit = widget.unit;
    _darkMode = widget.darkMode;
    _getWeather();
  }

  /// Fetch weather by city or GPS
  Future<void> _getWeather({String? city}) async {
    setState(() {
      _weather = "Fetching weather...";
      _iconCode = null;
      _condition = "";
    });

    try {
      String url;
      if (city != null && city.isNotEmpty) {
        // Supports "City" or "City,CountryCode"
        url =
            "https://api.openweathermap.org/data/2.5/weather?q=$city&units=$_unit&appid=$apiKey";
      } else {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high),
        );
        url =
            "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=$_unit&appid=$apiKey";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _city = data['name'] ?? city ?? "";
          _country = data['sys']['country'] ?? "";
          _weather =
              "${data['main']['temp']}° ${_unit == "metric" ? "C" : "F"}";
          _iconCode = data['weather'][0]['icon'];
          _condition = data['weather'][0]['description']; // e.g. "clear sky"
        });
      } else {
        setState(() => _weather = "City not found or API error");
      }
    } catch (e) {
      setState(() => _weather = "Location/Network error: $e");
    }
  }

  void _updateSettings(bool darkMode, String unit) {
    setState(() {
      _darkMode = darkMode;
      _unit = unit;
    });

    widget.onSettingsChanged?.call(darkMode, unit);

    _getWeather(city: _city.isNotEmpty ? "$_city,$_country" : null);
  }

  void _showSearchDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Search City or City,CountryCode"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "e.g. London or London,uk",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _getWeather(city: controller.text.trim());
            },
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _darkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Weather App"),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearchDialog,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      darkMode: _darkMode,
                      unit: _unit,
                      onSettingsChanged: _updateSettings,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_iconCode != null) ...[
                Image.network(
                  "https://openweathermap.org/img/wn/${_iconCode!}@4x.png",
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 10),
              ],
              Text(
                "$_city, $_country",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                _weather,
                style: const TextStyle(fontSize: 20),
              ),
              if (_condition.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  _condition[0].toUpperCase() + _condition.substring(1),
                  style: const TextStyle(
                      fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _getWeather(
                    city: _city.isNotEmpty ? "$_city,$_country" : null),
                child: const Text("Refresh Weather"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ForecastScreen(unit: _unit),
                    ),
                  );
                },
                child: const Text("5-Day / 3-Hour Forecast"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RadarScreen(),
                    ),
                  );
                },
                child: const Text("Radar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
