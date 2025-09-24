// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:glassmorphism/glassmorphism.dart';

// class AirQualityScreen extends StatefulWidget {
//   final String unit;
//   final bool darkMode;

//   const AirQualityScreen({
//     super.key,
//     required this.unit,
//     required this.darkMode,
//   });

//   @override
//   State<AirQualityScreen> createState() => _AirQualityScreenState();
// }

// class _AirQualityScreenState extends State<AirQualityScreen>
//     with SingleTickerProviderStateMixin {
//   final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";

//   String _status = "Loading AQI...";
//   int? _aqi;
//   Map<String, dynamic>? _components;

//   late AnimationController _controller;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAirQuality();

//     _controller =
//         AnimationController(vsync: this, duration: const Duration(seconds: 1));
//     _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchAirQuality() async {
//     setState(() {
//       _status = "Fetching air quality...";
//       _aqi = null;
//       _components = null;
//     });

//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         locationSettings:
//             const LocationSettings(accuracy: LocationAccuracy.high),
//       );

//       final url =
//           "https://api.openweathermap.org/data/2.5/air_pollution?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey";

//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         setState(() {
//           _aqi = data['list'][0]['main']['aqi'];
//           _components = data['list'][0]['components'];
//           _status = "Air Quality Data Loaded";
//         });

//         _controller.forward(from: 0);
//       } else {
//         setState(() => _status = "API error: ${response.statusCode}");
//       }
//     } catch (e) {
//       setState(() => _status = "Location/Network error: $e");
//     }
//   }

//   String _getAqiDescription(int? aqi) {
//     switch (aqi) {
//       case 1:
//         return "Good 😊";
//       case 2:
//         return "Fair 🙂";
//       case 3:
//         return "Moderate 😐";
//       case 4:
//         return "Poor 😷";
//       case 5:
//         return "Very Poor ☠️";
//       default:
//         return "Unknown";
//     }
//   }

//   List<Color> _getGradient() {
//     switch (_aqi) {
//       case 1:
//         return [Colors.green, Colors.teal];
//       case 2:
//         return [Colors.lightGreen, Colors.yellow];
//       case 3:
//         return [Colors.orange, Colors.deepOrangeAccent];
//       case 4:
//         return [Colors.redAccent, Colors.red];
//       case 5:
//         return [Colors.purple, Colors.black87];
//       default:
//         return widget.darkMode
//             ? [Colors.black, Colors.blueGrey.shade900]
//             : [Colors.blue.shade200, Colors.white];
//     }
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//           Text(value,
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: widget.darkMode ? ThemeData.dark() : ThemeData.light(),
//       home: Scaffold(
//         extendBodyBehindAppBar: true,
//         appBar: AppBar(
//           title: const Text("Air Quality Index"),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//         ),
//         body: Stack(
//           children: [
//             AnimatedContainer(
//               duration: const Duration(seconds: 2),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: _getGradient(),
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//             ),
//             Center(
//               child: GlassmorphicContainer(
//                 width: MediaQuery.of(context).size.width * 0.9,
//                 height: MediaQuery.of(context).size.height * 0.7,
//                 borderRadius: 30,
//                 blur: 20,
//                 border: 2,
//                 alignment: Alignment.center,
//                 linearGradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.white.withOpacity(0.15),
//                     Colors.white.withOpacity(0.05),
//                   ],
//                 ),
//                 borderGradient: LinearGradient(
//                   colors: [
//                     Colors.white.withOpacity(0.4),
//                     Colors.white.withOpacity(0.1),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: FadeTransition(
//                     opacity: _fadeAnim,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           _status,
//                           style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         if (_aqi != null) ...[
//                           const SizedBox(height: 15),
//                           Text(
//                             "AQI: $_aqi",
//                             style: const TextStyle(
//                               fontSize: 26,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             _getAqiDescription(_aqi),
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ),
//                           const Divider(height: 30, thickness: 1),
//                           Expanded(
//                             child: SingleChildScrollView(
//                               child: Column(
//                                 children: [
//                                   _buildInfoRow(
//                                       "CO", "${_components?['co']} µg/m³"),
//                                   _buildInfoRow(
//                                       "NO", "${_components?['no']} µg/m³"),
//                                   _buildInfoRow(
//                                       "NO₂", "${_components?['no2']} µg/m³"),
//                                   _buildInfoRow(
//                                       "O₃", "${_components?['o3']} µg/m³"),
//                                   _buildInfoRow(
//                                       "SO₂", "${_components?['so2']} µg/m³"),
//                                   _buildInfoRow("PM2.5",
//                                       "${_components?['pm2_5']} µg/m³"),
//                                   _buildInfoRow(
//                                       "PM10", "${_components?['pm10']} µg/m³"),
//                                   _buildInfoRow(
//                                       "NH₃", "${_components?['nh3']} µg/m³"),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           ElevatedButton.icon(
//                             onPressed: _fetchAirQuality,
//                             icon: const Icon(Icons.refresh),
//                             label: const Text("Refresh"),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:glassmorphism/glassmorphism.dart';

// class AirQualityScreen extends StatefulWidget {
//   final String unit;
//   final bool darkMode;
//   final String locationName; // ✅ new field to show current city/country

//   const AirQualityScreen({
//     super.key,
//     required this.unit,
//     required this.darkMode,
//     required this.locationName,
//   });

//   @override
//   State<AirQualityScreen> createState() => _AirQualityScreenState();
// }

// class _AirQualityScreenState extends State<AirQualityScreen>
//     with SingleTickerProviderStateMixin {
//   final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";

//   String _status = "Loading AQI...";
//   int? _aqi;
//   Map<String, dynamic>? _components;

//   late AnimationController _controller;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAirQuality();

//     _controller =
//         AnimationController(vsync: this, duration: const Duration(seconds: 1));
//     _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchAirQuality() async {
//     setState(() {
//       _status = "Fetching air quality...";
//       _aqi = null;
//       _components = null;
//     });

//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         locationSettings:
//             const LocationSettings(accuracy: LocationAccuracy.high),
//       );

//       final url =
//           "https://api.openweathermap.org/data/2.5/air_pollution?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey";

//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         setState(() {
//           _aqi = data['list'][0]['main']['aqi'];
//           _components = data['list'][0]['components'];
//           _status = "Air Quality Data Loaded";
//         });

//         _controller.forward(from: 0);
//       } else {
//         setState(() => _status = "API error: ${response.statusCode}");
//       }
//     } catch (e) {
//       setState(() => _status = "Location/Network error: $e");
//     }
//   }

//   String _getAqiDescription(int? aqi) {
//     switch (aqi) {
//       case 1:
//         return "Good 😊";
//       case 2:
//         return "Fair 🙂";
//       case 3:
//         return "Moderate 😐";
//       case 4:
//         return "Poor 😷";
//       case 5:
//         return "Very Poor ☠️";
//       default:
//         return "Unknown";
//     }
//   }

//   List<Color> _getGradient() {
//     switch (_aqi) {
//       case 1:
//         return [Colors.green, Colors.teal];
//       case 2:
//         return [Colors.lightGreen, Colors.yellow];
//       case 3:
//         return [Colors.orange, Colors.deepOrangeAccent];
//       case 4:
//         return [Colors.redAccent, Colors.red];
//       case 5:
//         return [Colors.purple, Colors.black87];
//       default:
//         return widget.darkMode
//             ? [Colors.black, Colors.blueGrey.shade900]
//             : [Colors.blue.shade200, Colors.white];
//     }
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//           Text(value,
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: widget.darkMode ? ThemeData.dark() : ThemeData.light(),
//       home: Scaffold(
//         extendBodyBehindAppBar: true,
//         appBar: AppBar(
//           title:
//               Text("Air Quality - ${widget.locationName}"), // ✅ show location
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//             // ✅ back button
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         body: Stack(
//           children: [
//             AnimatedContainer(
//               duration: const Duration(seconds: 2),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: _getGradient(),
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//             ),
//             Center(
//               child: GlassmorphicContainer(
//                 width: MediaQuery.of(context).size.width * 0.9,
//                 height: MediaQuery.of(context).size.height * 0.7,
//                 borderRadius: 30,
//                 blur: 20,
//                 border: 2,
//                 alignment: Alignment.center,
//                 linearGradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.white.withOpacity(0.15),
//                     Colors.white.withOpacity(0.05),
//                   ],
//                 ),
//                 borderGradient: LinearGradient(
//                   colors: [
//                     Colors.white.withOpacity(0.4),
//                     Colors.white.withOpacity(0.1),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: FadeTransition(
//                     opacity: _fadeAnim,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Text(
//                         //   _status,
//                         //   style: const TextStyle(
//                         //     fontSize: 20,
//                         //     fontWeight: FontWeight.bold,
//                         //   ),
//                         // ),
//                         if (_aqi != null) ...[
//                           const SizedBox(height: 10),
//                           Text(
//                             "AQI: $_aqi",
//                             style: const TextStyle(
//                               fontSize: 26,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             _getAqiDescription(_aqi),
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ),
//                           SizedBox(
//                             height: MediaQuery.of(context).size.height * .03,
//                           ),
//                           Expanded(
//                             child: SingleChildScrollView(
//                               child: Column(
//                                 children: [
//                                   _buildInfoRow(
//                                       "CO", "${_components?['co']} µg/m³"),
//                                   _buildInfoRow(
//                                       "NO", "${_components?['no']} µg/m³"),
//                                   _buildInfoRow(
//                                       "NO₂", "${_components?['no2']} µg/m³"),
//                                   _buildInfoRow(
//                                       "O₃", "${_components?['o3']} µg/m³"),
//                                   _buildInfoRow(
//                                       "SO₂", "${_components?['so2']} µg/m³"),
//                                   _buildInfoRow("PM2.5",
//                                       "${_components?['pm2_5']} µg/m³"),
//                                   _buildInfoRow(
//                                       "PM10", "${_components?['pm10']} µg/m³"),
//                                   _buildInfoRow(
//                                       "NH₃", "${_components?['nh3']} µg/m³"),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           ElevatedButton.icon(
//                             onPressed: _fetchAirQuality,
//                             icon: const Icon(Icons.refresh),
//                             label: const Text("Refresh"),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:glassmorphism/glassmorphism.dart';
// import 'package:provider/provider.dart';

// import '../provider/settings_provider.dart';

// class AirQualityScreen extends StatefulWidget {
//   final String locationName;

//   const AirQualityScreen({
//     super.key,
//     required this.locationName,
//   });

//   @override
//   State<AirQualityScreen> createState() => _AirQualityScreenState();
// }

// class _AirQualityScreenState extends State<AirQualityScreen>
//     with SingleTickerProviderStateMixin {
//   final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";

//   String _status = "Loading AQI...";
//   int? _aqi;
//   Map<String, dynamic>? _components;

//   late AnimationController _controller;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAirQuality();

//     _controller =
//         AnimationController(vsync: this, duration: const Duration(seconds: 1));
//     _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchAirQuality() async {
//     setState(() {
//       _status = "Fetching air quality...";
//       _aqi = null;
//       _components = null;
//     });

//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         locationSettings:
//             const LocationSettings(accuracy: LocationAccuracy.high),
//       );

//       final url =
//           "https://api.openweathermap.org/data/2.5/air_pollution?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey";

//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         setState(() {
//           _aqi = data['list'][0]['main']['aqi'];
//           _components = data['list'][0]['components'];
//           _status = "Air Quality Data Loaded";
//         });

//         _controller.forward(from: 0);
//       } else {
//         setState(() => _status = "API error: ${response.statusCode}");
//       }
//     } catch (e) {
//       setState(() => _status = "Location/Network error: $e");
//     }
//   }

//   String _getAqiDescription(int? aqi) {
//     switch (aqi) {
//       case 1:
//         return "Good 😊";
//       case 2:
//         return "Fair 🙂";
//       case 3:
//         return "Moderate 😐";
//       case 4:
//         return "Poor 😷";
//       case 5:
//         return "Very Poor ☠️";
//       default:
//         return "Unknown";
//     }
//   }

//   List<Color> _getGradient(SettingsProvider settings) {
//     switch (_aqi) {
//       case 1:
//         return [Colors.green, Colors.teal];
//       case 2:
//         return [Colors.lightGreen, Colors.yellow];
//       case 3:
//         return [Colors.orange, Colors.deepOrangeAccent];
//       case 4:
//         return [Colors.redAccent, Colors.red];
//       case 5:
//         return [Colors.purple, Colors.black87];
//       default:
//         return settings.themeMode == "Dark"
//             ? [Colors.black, Colors.blueGrey.shade900]
//             : [Colors.blue.shade200, Colors.white];
//     }
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//           Text(value,
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final settings = Provider.of<SettingsProvider>(context);

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: Text("Air Quality - ${widget.locationName}"),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Stack(
//         children: [
//           AnimatedContainer(
//             duration: const Duration(seconds: 2),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: _getGradient(settings),
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//           Center(
//             child: GlassmorphicContainer(
//               width: MediaQuery.of(context).size.width * 0.9,
//               height: MediaQuery.of(context).size.height * 0.7,
//               borderRadius: 30,
//               blur: 20,
//               border: 2,
//               alignment: Alignment.center,
//               linearGradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.white.withOpacity(0.15),
//                   Colors.white.withOpacity(0.05),
//                 ],
//               ),
//               borderGradient: LinearGradient(
//                 colors: [
//                   Colors.white.withOpacity(0.4),
//                   Colors.white.withOpacity(0.1),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: FadeTransition(
//                   opacity: _fadeAnim,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       if (_aqi != null) ...[
//                         const SizedBox(height: 10),
//                         Text(
//                           "AQI: $_aqi",
//                           style: const TextStyle(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _getAqiDescription(_aqi),
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                         SizedBox(
//                           height: MediaQuery.of(context).size.height * .03,
//                         ),
//                         Expanded(
//                           child: SingleChildScrollView(
//                             child: Column(
//                               children: [
//                                 _buildInfoRow(
//                                     "CO", "${_components?['co']} µg/m³"),
//                                 _buildInfoRow(
//                                     "NO", "${_components?['no']} µg/m³"),
//                                 _buildInfoRow(
//                                     "NO₂", "${_components?['no2']} µg/m³"),
//                                 _buildInfoRow(
//                                     "O₃", "${_components?['o3']} µg/m³"),
//                                 _buildInfoRow(
//                                     "SO₂", "${_components?['so2']} µg/m³"),
//                                 _buildInfoRow(
//                                     "PM2.5", "${_components?['pm2_5']} µg/m³"),
//                                 _buildInfoRow(
//                                     "PM10", "${_components?['pm10']} µg/m³"),
//                                 _buildInfoRow(
//                                     "NH₃", "${_components?['nh3']} µg/m³"),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         ElevatedButton.icon(
//                           onPressed: _fetchAirQuality,
//                           icon: const Icon(Icons.refresh),
//                           label: const Text("Refresh"),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:glassmorphism/glassmorphism.dart';
// import 'package:provider/provider.dart';

// import '../provider/settings_provider.dart';

// class AirQualityScreen extends StatefulWidget {
//   final String locationName;

//   const AirQualityScreen({
//     super.key,
//     required this.locationName,
//   });

//   @override
//   State<AirQualityScreen> createState() => _AirQualityScreenState();
// }

// class _AirQualityScreenState extends State<AirQualityScreen>
//     with SingleTickerProviderStateMixin {
//   final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";

//   String _status = "Loading AQI...";
//   int? _aqi;
//   Map<String, dynamic>? _components;

//   late AnimationController _controller;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAirQuality();

//     _controller =
//         AnimationController(vsync: this, duration: const Duration(seconds: 1));
//     _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchAirQuality() async {
//     setState(() {
//       _status = "Fetching air quality...";
//       _aqi = null;
//       _components = null;
//     });

//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         locationSettings:
//             const LocationSettings(accuracy: LocationAccuracy.high),
//       );

//       final url =
//           "https://api.openweathermap.org/data/2.5/air_pollution?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey";

//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         setState(() {
//           _aqi = data['list'][0]['main']['aqi'];
//           _components = data['list'][0]['components'];
//           _status = "Air Quality Data Loaded";
//         });

//         _controller.forward(from: 0);
//       } else {
//         setState(() => _status = "API error: ${response.statusCode}");
//       }
//     } catch (e) {
//       setState(() => _status = "Location/Network error: $e");
//     }
//   }

//   String _getAqiDescription(int? aqi) {
//     switch (aqi) {
//       case 1:
//         return "Good 😊";
//       case 2:
//         return "Fair 🙂";
//       case 3:
//         return "Moderate 😐";
//       case 4:
//         return "Poor 😷";
//       case 5:
//         return "Very Poor ☠️";
//       default:
//         return "Unknown";
//     }
//   }

//   List<Color> _getGradient(SettingsProvider settings) {
//     // If AQI has a color, show it
//     if (_aqi != null) {
//       switch (_aqi) {
//         case 1:
//           return [Colors.green, Colors.teal];
//         case 2:
//           return [Colors.lightGreen, Colors.yellow];
//         case 3:
//           return [Colors.orange, Colors.deepOrangeAccent];
//         case 4:
//           return [Colors.redAccent, Colors.red];
//         case 5:
//           return [Colors.purple, Colors.black87];
//       }
//     }

//     // If no AQI, fall back to theme mode
//     if (settings.themeMode == "Dark") {
//       return [Colors.black, Colors.blueGrey.shade900];
//     } else if (settings.themeMode == "Light") {
//       return [Colors.white, Colors.blue.shade200];
//     } else {
//       // System/Glassmorphic default
//       return [Colors.blue.shade200, Colors.white];
//     }
//   }

//   Widget _buildInfoRow(String label, String value, SettingsProvider settings) {
//     final textColor =
//         settings.themeMode == "Dark" ? Colors.white : Colors.black;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: textColor,
//               )),
//           Text(value,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: textColor,
//               )),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final settings = Provider.of<SettingsProvider>(context);
//     final textColor =
//         settings.themeMode == "Dark" ? Colors.white : Colors.black;

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: Text(
//           "Air Quality - ${widget.locationName}",
//           style: TextStyle(color: textColor),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: IconThemeData(color: textColor),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Stack(
//         children: [
//           AnimatedContainer(
//             duration: const Duration(seconds: 2),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: _getGradient(settings),
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//           Center(
//             child: GlassmorphicContainer(
//               width: MediaQuery.of(context).size.width * 0.9,
//               height: MediaQuery.of(context).size.height * 0.7,
//               borderRadius: 30,
//               blur: 20,
//               border: 2,
//               alignment: Alignment.center,
//               linearGradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.white.withOpacity(0.15),
//                   Colors.white.withOpacity(0.05),
//                 ],
//               ),
//               borderGradient: LinearGradient(
//                 colors: [
//                   Colors.white.withOpacity(0.4),
//                   Colors.white.withOpacity(0.1),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: FadeTransition(
//                   opacity: _fadeAnim,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       if (_aqi != null) ...[
//                         const SizedBox(height: 10),
//                         Text(
//                           "AQI: $_aqi",
//                           style: TextStyle(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                             color: textColor,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _getAqiDescription(_aqi),
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontStyle: FontStyle.italic,
//                             color: textColor,
//                           ),
//                         ),
//                         SizedBox(
//                           height: MediaQuery.of(context).size.height * .03,
//                         ),
//                         Expanded(
//                           child: SingleChildScrollView(
//                             child: Column(
//                               children: [
//                                 _buildInfoRow("CO",
//                                     "${_components?['co']} µg/m³", settings),
//                                 _buildInfoRow("NO",
//                                     "${_components?['no']} µg/m³", settings),
//                                 _buildInfoRow("NO₂",
//                                     "${_components?['no2']} µg/m³", settings),
//                                 _buildInfoRow("O₃",
//                                     "${_components?['o3']} µg/m³", settings),
//                                 _buildInfoRow("SO₂",
//                                     "${_components?['so2']} µg/m³", settings),
//                                 _buildInfoRow("PM2.5",
//                                     "${_components?['pm2_5']} µg/m³", settings),
//                                 _buildInfoRow("PM10",
//                                     "${_components?['pm10']} µg/m³", settings),
//                                 _buildInfoRow("NH₃",
//                                     "${_components?['nh3']} µg/m³", settings),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         ElevatedButton.icon(
//                           onPressed: _fetchAirQuality,
//                           icon: const Icon(Icons.refresh),
//                           label: const Text("Refresh"),
//                         ),
//                       ] else ...[
//                         Text(
//                           _status,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: textColor,
//                           ),
//                         ),
//                       ]
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';

import '../provider/settings_provider.dart';

class AirQualityScreen extends StatefulWidget {
  final String locationName;
  final double? latitude;
  final double? longitude;

  const AirQualityScreen({
    super.key,
    required this.locationName,
    this.latitude,
    this.longitude,
  });

  @override
  State<AirQualityScreen> createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AirQualityScreen>
    with SingleTickerProviderStateMixin {
  final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";

  String _status = "Loading AQI...";
  int? _aqi;
  Map<String, dynamic>? _components;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fetchAirQuality();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchAirQuality() async {
    setState(() {
      _status = "Fetching air quality...";
      _aqi = null;
      _components = null;
    });

    try {
      double lat;
      double lon;

      if (widget.latitude != null && widget.longitude != null) {
        // Use provided coordinates
        lat = widget.latitude!;
        lon = widget.longitude!;
      } else {
        // Fallback to geolocation
        Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high),
        );
        lat = position.latitude;
        lon = position.longitude;
      }

      final url =
          "https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _aqi = data['list'][0]['main']['aqi'];
          _components = data['list'][0]['components'];
          _status = "Air Quality Data Loaded";
        });

        _controller.forward(from: 0);
      } else {
        setState(() => _status = "API error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _status = "Location/Network error: $e");
    }
  }

  String _getAqiDescription(int? aqi) {
    switch (aqi) {
      case 1:
        return "Good 😊";
      case 2:
        return "Fair 🙂";
      case 3:
        return "Moderate 😐";
      case 4:
        return "Poor 😷";
      case 5:
        return "Very Poor ☠️";
      default:
        return "Unknown";
    }
  }

  List<Color> _getGradient(SettingsProvider settings) {
    // If AQI has a color, show it
    if (_aqi != null) {
      switch (_aqi) {
        case 1:
          return [Colors.green, Colors.teal];
        case 2:
          return [Colors.lightGreen, Colors.yellow];
        case 3:
          return [Colors.orange, Colors.deepOrangeAccent];
        case 4:
          return [Colors.redAccent, Colors.red];
        case 5:
          return [Colors.purple, Colors.black87];
      }
    }

    // If no AQI, fall back to theme mode
    if (settings.themeMode == "Dark") {
      return [Colors.black, Colors.blueGrey.shade900];
    } else if (settings.themeMode == "Light") {
      return [Colors.white, Colors.blue.shade200];
    } else {
      // System/Glassmorphic default
      return [Colors.blue.shade200, Colors.white];
    }
  }

  Widget _buildInfoRow(String label, String value, SettingsProvider settings) {
    final textColor =
        settings.themeMode == "Dark" ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final textColor =
        settings.themeMode == "Dark" ? Colors.white : Colors.black;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Air Quality - ${widget.locationName}",
          style: TextStyle(color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getGradient(settings),
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: GlassmorphicContainer(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              borderRadius: 30,
              blur: 20,
              border: 2,
              alignment: Alignment.center,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.4),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_aqi != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          "AQI: $_aqi",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getAqiDescription(_aqi),
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: textColor,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .03,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildInfoRow("CO",
                                    "${_components?['co']} µg/m³", settings),
                                _buildInfoRow("NO",
                                    "${_components?['no']} µg/m³", settings),
                                _buildInfoRow("NO₂",
                                    "${_components?['no2']} µg/m³", settings),
                                _buildInfoRow("O₃",
                                    "${_components?['o3']} µg/m³", settings),
                                _buildInfoRow("SO₂",
                                    "${_components?['so2']} µg/m³", settings),
                                _buildInfoRow("PM2.5",
                                    "${_components?['pm2_5']} µg/m³", settings),
                                _buildInfoRow("PM10",
                                    "${_components?['pm10']} µg/m³", settings),
                                _buildInfoRow("NH₃",
                                    "${_components?['nh3']} µg/m³", settings),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _fetchAirQuality,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh"),
                        ),
                      ] else ...[
                        Text(
                          _status,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
