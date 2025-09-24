// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:glassmorphism/glassmorphism.dart';
// import 'package:latlong2/latlong.dart';

// class RadarScreen extends StatefulWidget {
//   const RadarScreen({super.key});

//   static const String apiKey =
//       "b83f15578b1c0f6507504162e7e2c4c0"; // replace with yours

//   @override
//   State<RadarScreen> createState() => _RadarScreenState();
// }

// class _RadarScreenState extends State<RadarScreen> {
//   String selectedLayer = "clouds_new"; // default layer

//   final Map<String, String> weatherLayers = {
//     "Clouds": "clouds_new",
//     "Precipitation": "precipitation_new",
//     "Temperature": "temp_new",
//     "Wind": "wind_new",
//     "Air Pressure": "pressure_new", // Proxy for AQ
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: const Text("Weather Radar"),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: Stack(
//         children: [
//           FlutterMap(
//             options: const MapOptions(
//               initialCenter: LatLng(51.5, -0.09), // Default London
//               initialZoom: 4,
//             ),
//             children: [
//               // Base map
//               TileLayer(
//                 urlTemplate:
//                     "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                 subdomains: const ['a', 'b', 'c'],
//               ),
//               // Weather layer (dynamic selection)
//               TileLayer(
//                 urlTemplate:
//                     "https://tile.openweathermap.org/map/$selectedLayer/{z}/{x}/{y}.png?appid=${RadarScreen.apiKey}",
//               ),
//             ],
//           ),

//           // Glassmorphic Control Panel
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: GlassmorphicContainer(
//               width: double.infinity,
//               height: 120,
//               borderRadius: 20,
//               blur: 20,
//               alignment: Alignment.center,
//               border: 2,
//               linearGradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.white.withOpacity(0.15),
//                   Colors.white.withOpacity(0.05),
//                 ],
//               ),
//               borderGradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.white.withOpacity(0.3),
//                   Colors.white.withOpacity(0.3),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   children: [
//                     const Text(
//                       "Select Radar Layer",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 15, 15, 15),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     SizedBox(
//                       height: 40,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: weatherLayers.length,
//                         itemBuilder: (context, index) {
//                           final entry = weatherLayers.entries.elementAt(index);
//                           final bool isSelected = selectedLayer == entry.value;

//                           return Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 6),
//                             child: ChoiceChip(
//                               label: Text(entry.key),
//                               selected: isSelected,
//                               onSelected: (_) {
//                                 setState(() {
//                                   selectedLayer = entry.value;
//                                 });
//                               },
//                               selectedColor: Colors.blueAccent,
//                               backgroundColor: Colors.transparent,
//                               shape: StadiumBorder(
//                                 side: BorderSide(
//                                   color: isSelected
//                                       ? Colors.blueAccent
//                                       : Colors.white70,
//                                 ),
//                               ),
//                               labelStyle: TextStyle(
//                                 color: isSelected
//                                     ? const Color.fromARGB(255, 252, 250, 250)
//                                     : const Color.fromARGB(255, 15, 14, 14),
//                                 fontWeight: isSelected
//                                     ? FontWeight.bold
//                                     : FontWeight.normal,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../provider/settings_provider.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  static const String apiKey =
      "b83f15578b1c0f6507504162e7e2c4c0"; // replace with yours

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  String selectedLayer = "clouds_new"; // default layer

  final Map<String, String> weatherLayers = {
    "Clouds": "clouds_new",
    "Precipitation": "precipitation_new",
    "Temperature": "temp_new",
    "Wind": "wind_new",
    "Air Pressure": "pressure_new",
  };

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    /// Apply theme based on settings
    Color bgColor;
    Color textColor;

    switch (settings.themeMode) {
      case "Light":
        bgColor = Colors.white;
        textColor = Colors.blue;
        break;
      case "Dark":
        bgColor = Colors.black;
        textColor = Colors.white;
        break;
      default: // System (Glassmorphic)
        bgColor = Colors.transparent;
        textColor = const Color.fromARGB(255, 12, 12, 12);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Weather Radar",
          style: TextStyle(color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(51.5, -0.09), // Default London
              initialZoom: 4,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              TileLayer(
                urlTemplate:
                    "https://tile.openweathermap.org/map/$selectedLayer/{z}/{x}/{y}.png?appid=${RadarScreen.apiKey}",
              ),
            ],
          ),

          /// Control Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: settings.themeMode == "System"
                ? _buildGlassPanel(textColor)
                : Container(
                    width: double.infinity,
                    height: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgColor.withOpacity(0.85),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: _buildPanelContent(textColor),
                  ),
          ),
        ],
      ),
    );
  }

  /// Glassmorphic panel for System theme
  Widget _buildGlassPanel(Color textColor) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 120,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.3),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _buildPanelContent(textColor),
      ),
    );
  }

  /// Reusable panel content
  Widget _buildPanelContent(Color textColor) {
    return Column(
      children: [
        Text(
          "Select Radar Layer",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weatherLayers.length,
            itemBuilder: (context, index) {
              final entry = weatherLayers.entries.elementAt(index);
              final bool isSelected = selectedLayer == entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(entry.key),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedLayer = entry.value;
                    });
                  },
                  selectedColor: Colors.blueAccent,
                  backgroundColor: Colors.transparent,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected
                          ? Colors.blueAccent
                          : textColor.withOpacity(0.6),
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
