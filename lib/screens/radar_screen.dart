import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});

  static const String apiKey = "b83f15578b1c0f6507504162e7e2c4c0"; // replace

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Radar"),
        backgroundColor: Colors.blue,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(51.5, -0.09), // Default (London)
          initialZoom: 5,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          // Clouds layer (you can change to precipitation_new, temp_new, etc.)
          TileLayer(
            urlTemplate:
                "https://tile.openweathermap.org/map/clouds_new/{z}/{x}/{y}.png?appid=$apiKey",
          ),
        ],
      ),
    );
  }
}
