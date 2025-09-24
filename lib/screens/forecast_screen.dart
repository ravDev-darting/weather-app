// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:fl_chart/fl_chart.dart';
// import 'package:glassmorphism/glassmorphism.dart';

// class ForecastScreen extends StatefulWidget {
//   final String unit;
//   const ForecastScreen({super.key, required this.unit});

//   @override
//   State<ForecastScreen> createState() => _ForecastScreenState();
// }

// class _ForecastScreenState extends State<ForecastScreen> {
//   Map<String, dynamic>? _forecastData;
//   bool _isLoading = true;
//   String? _error;

//   final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";

//   @override
//   void initState() {
//     super.initState();
//     _fetchForecast();
//   }

//   Future<void> _fetchForecast() async {
//     try {
//       Position pos = await Geolocator.getCurrentPosition();

//       final url =
//           "https://api.openweathermap.org/data/2.5/forecast?lat=${pos.latitude}&lon=${pos.longitude}&units=${widget.unit}&appid=$apiKey";

//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         setState(() {
//           _forecastData = json.decode(response.body);
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _error = "Failed to load forecast (${response.statusCode})";
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _error = "Error: $e";
//         _isLoading = false;
//       });
//     }
//   }

//   List<FlSpot> _getChartSpots() {
//     if (_forecastData == null) return [];
//     final list = _forecastData!['list'];
//     return List.generate(list.length, (i) {
//       final temp = (list[i]['main']['temp'] as num).toDouble();
//       return FlSpot(i.toDouble(), temp);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true, // glass look
//       appBar: AppBar(
//         title: const Text(
//           "5-Day / 3-Hour Forecast",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1.2,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: Stack(
//         children: [
//           // 🔹 Gradient background (like HomeScreen)
//           AnimatedContainer(
//             duration: const Duration(seconds: 2),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.indigo, Colors.deepPurple, Colors.black],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),

//           // 🔹 Glassmorphic container
//           GlassmorphicContainer(
//             width: double.infinity,
//             height: double.infinity,
//             borderRadius: 0,
//             blur: 25,
//             border: 0,
//             linearGradient: LinearGradient(
//               colors: [
//                 Colors.white.withOpacity(0.08),
//                 Colors.white.withOpacity(0.02),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderGradient: LinearGradient(
//               colors: [
//                 Colors.white.withOpacity(0.3),
//                 Colors.white.withOpacity(0.05),
//               ],
//             ),
//             child: _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: Colors.white))
//                 : _error != null
//                     ? Center(
//                         child: Text(
//                           _error!,
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       )
//                     : Column(
//                         children: [
//                           SizedBox(
//                             height: MediaQuery.of(context).size.height * .08,
//                           ),
//                           // 🔹 Forecast Chart inside glass card
//                           Container(
//                               margin: const EdgeInsets.all(16),
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(25),
//                                 color: Colors.white.withOpacity(0.08),
//                                 border: Border.all(
//                                   color: Colors.white.withOpacity(0.15),
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.25),
//                                     blurRadius: 15,
//                                     offset: const Offset(0, 5),
//                                   ),
//                                 ],
//                               ),
//                               height: 220,
//                               child: LineChart(
//                                 LineChartData(
//                                   minY: (_getChartSpots()
//                                           .map((e) => e.y)
//                                           .reduce((a, b) => a < b ? a : b)) -
//                                       2,
//                                   maxY: (_getChartSpots()
//                                           .map((e) => e.y)
//                                           .reduce((a, b) => a > b ? a : b)) +
//                                       2,
//                                   gridData: const FlGridData(show: true),
//                                   borderData: FlBorderData(show: false),
//                                   titlesData: FlTitlesData(
//                                     leftTitles: AxisTitles(
//                                       sideTitles: SideTitles(
//                                         showTitles: true,
//                                         reservedSize: 40, // ✅ enough space
//                                         getTitlesWidget: (value, meta) {
//                                           return Text(
//                                             "${value.toInt()}°", // ✅ show as degrees
//                                             style: const TextStyle(
//                                                 color: Colors.white70,
//                                                 fontSize: 12),
//                                             textAlign: TextAlign.left,
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                     bottomTitles: AxisTitles(
//                                       sideTitles: SideTitles(
//                                         showTitles: true,
//                                         interval:
//                                             8, // ✅ one label every ~8 data points (adjust if needed)
//                                         getTitlesWidget: (value, meta) {
//                                           if (_forecastData == null)
//                                             return const SizedBox();
//                                           final list = _forecastData!['list'];
//                                           final index = value.toInt();
//                                           if (index < 0 || index >= list.length)
//                                             return const SizedBox();
//                                           final date = DateTime
//                                               .fromMillisecondsSinceEpoch(
//                                                   list[index]['dt'] * 1000);
//                                           return Padding(
//                                             padding:
//                                                 const EdgeInsets.only(top: 6),
//                                             child: Text(
//                                               "${date.day}/${date.month}\n${date.hour}:00", // ✅ stacked format
//                                               style: const TextStyle(
//                                                   color: Colors.white70,
//                                                   fontSize: 10),
//                                               textAlign: TextAlign.center,
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                     topTitles: const AxisTitles(
//                                         sideTitles:
//                                             SideTitles(showTitles: false)),
//                                     rightTitles: const AxisTitles(
//                                         sideTitles:
//                                             SideTitles(showTitles: false)),
//                                   ),
//                                   lineBarsData: [
//                                     LineChartBarData(
//                                       spots: _getChartSpots(),
//                                       isCurved: true,
//                                       color: Colors.cyanAccent,
//                                       barWidth: 3,
//                                       dotData: const FlDotData(show: false),
//                                     ),
//                                   ],
//                                 ),
//                               )),

//                           // 🔹 Forecast List with glassmorphic cards
//                           Expanded(
//                             child: ListView.builder(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 8),
//                               itemCount: _forecastData?['list']?.length ?? 0,
//                               itemBuilder: (context, index) {
//                                 final item = _forecastData!['list'][index];
//                                 final date =
//                                     DateTime.fromMillisecondsSinceEpoch(
//                                         item['dt'] * 1000);
//                                 final temp = item['main']['temp'];
//                                 final description =
//                                     item['weather'][0]['description'];

//                                 return GlassmorphicContainer(
//                                   width: double.infinity,
//                                   height: 80,
//                                   borderRadius: 20,
//                                   blur: 20,
//                                   border: 1,
//                                   margin: const EdgeInsets.only(bottom: 12),
//                                   linearGradient: LinearGradient(
//                                     colors: [
//                                       Colors.white.withOpacity(0.15),
//                                       Colors.white.withOpacity(0.05),
//                                     ],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   borderGradient: LinearGradient(
//                                     colors: [
//                                       Colors.white.withOpacity(0.3),
//                                       Colors.white.withOpacity(0.05),
//                                     ],
//                                   ),
//                                   child: ListTile(
//                                     leading: Icon(Icons.cloud,
//                                         color: Colors.cyanAccent.shade100,
//                                         size: 30),
//                                     title: Text(
//                                       "${date.day}-${date.month} ${date.hour}:00",
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                     subtitle: Text(
//                                       description,
//                                       style: const TextStyle(
//                                           fontSize: 14, color: Colors.white70),
//                                     ),
//                                     trailing: Text(
//                                       "${temp.toStringAsFixed(1)}° ${widget.unit == "metric" ? "C" : "F"}",
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// ...................................................................................
// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:fl_chart/fl_chart.dart';
// import 'package:glassmorphism/glassmorphism.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ForecastScreen extends StatefulWidget {
//   final String unit;
//   const ForecastScreen({super.key, required this.unit});

//   @override
//   State<ForecastScreen> createState() => _ForecastScreenState();
// }

// class _ForecastScreenState extends State<ForecastScreen> {
//   Map<String, dynamic>? _forecastData;
//   Map<String, dynamic>? _currentData;
//   bool _isLoading = true;
//   String? _error;

//   final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";

//   @override
//   void initState() {
//     super.initState();
//     _fetchForecast();
//   }

//   Future<void> _fetchForecast() async {
//     try {
//       Position pos = await Geolocator.getCurrentPosition();

//       final forecastUrl =
//           "https://api.openweathermap.org/data/2.5/forecast?lat=${pos.latitude}&lon=${pos.longitude}&units=${widget.unit}&appid=$apiKey";
//       final currentUrl =
//           "https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&units=${widget.unit}&appid=$apiKey";

//       final forecastRes = await http.get(Uri.parse(forecastUrl));
//       final currentRes = await http.get(Uri.parse(currentUrl));

//       if (forecastRes.statusCode == 200 && currentRes.statusCode == 200) {
//         setState(() {
//           _forecastData = json.decode(forecastRes.body);
//           _currentData = json.decode(currentRes.body);
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _error = "Failed to load forecast (${forecastRes.statusCode})";
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _error = "Error: $e";
//         _isLoading = false;
//       });
//     }
//   }

//   List<FlSpot> _getChartSpotsTemp() {
//     if (_forecastData == null) return [];
//     final list = _forecastData!['list'];
//     return List.generate(list.length, (i) {
//       final temp = (list[i]['main']['temp'] as num).toDouble();
//       return FlSpot(i.toDouble(), temp);
//     });
//   }

//   List<FlSpot> _getChartSpotsRain() {
//     if (_forecastData == null) return [];
//     final list = _forecastData!['list'];
//     return List.generate(list.length, (i) {
//       final rain =
//           list[i]['rain'] != null ? (list[i]['rain']['3h'] ?? 0.0) : 0.0;
//       return FlSpot(i.toDouble(), (rain as num).toDouble());
//     });
//   }

//   String _getMoonPhase(double moonPhase) {
//     if (moonPhase == 0) return "New Moon";
//     if (moonPhase < 0.25) return "Waxing Crescent";
//     if (moonPhase == 0.25) return "First Quarter";
//     if (moonPhase < 0.5) return "Waxing Gibbous";
//     if (moonPhase == 0.5) return "Full Moon";
//     if (moonPhase < 0.75) return "Waning Gibbous";
//     if (moonPhase == 0.75) return "Last Quarter";
//     return "Waning Crescent";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: const Text(
//           "Forecast",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1.2,
//           ),
//         ),
//         elevation: 0,
//         backgroundColor: Colors.transparent, // keep transparent
//         flexibleSpace: GlassmorphicContainer(
//           width: double.infinity,
//           height: double.infinity,
//           borderRadius: 0,
//           blur: 20,
//           border: 0,
//           linearGradient: LinearGradient(
//             colors: [
//               const Color.fromARGB(255, 97, 234, 230)
//                   .withOpacity(0.25), // teal tint
//               Colors.white.withOpacity(0.05),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderGradient: LinearGradient(
//             colors: [
//               Colors.white.withOpacity(0.3),
//               Colors.white.withOpacity(0.1),
//             ],
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           AnimatedContainer(
//             duration: const Duration(seconds: 2),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.indigo, Colors.deepPurple, Colors.black],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//           GlassmorphicContainer(
//             width: double.infinity,
//             height: double.infinity,
//             borderRadius: 0,
//             blur: 25,
//             border: 0,
//             linearGradient: LinearGradient(
//               colors: [
//                 Colors.white.withOpacity(0.08),
//                 Colors.white.withOpacity(0.02),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderGradient: LinearGradient(
//               colors: [
//                 Colors.white.withOpacity(0.3),
//                 Colors.white.withOpacity(0.05),
//               ],
//             ),
//             child: _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: Colors.white))
//                 : _error != null
//                     ? Center(
//                         child: Text(
//                           _error!,
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       )
//                     : SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             SizedBox(
//                                 height:
//                                     MediaQuery.of(context).size.height * 0.02),

//                             /// 🌅 Sunrise & Sunset
//                             if (_currentData != null)
//                               Container(
//                                 margin: const EdgeInsets.all(16),
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(20),
//                                   color: Colors.white.withOpacity(0.08),
//                                   border: Border.all(
//                                       color: Colors.white.withOpacity(0.15)),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceAround,
//                                   children: [
//                                     Column(
//                                       children: [
//                                         const Icon(Icons.wb_sunny,
//                                             color: Colors.orange, size: 28),
//                                         Text(
//                                           "Sunrise\n${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunrise'] * 1000).hour}:${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunrise'] * 1000).minute.toString().padLeft(2, '0')}",
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(
//                                               color: Colors.white),
//                                         ),
//                                       ],
//                                     ),
//                                     Column(
//                                       children: [
//                                         const Icon(Icons.nights_stay,
//                                             color: Colors.blueAccent, size: 28),
//                                         Text(
//                                           "Sunset\n${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunset'] * 1000).hour}:${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunset'] * 1000).minute.toString().padLeft(2, '0')}",
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(
//                                               color: Colors.white),
//                                         ),
//                                       ],
//                                     ),
//                                     Column(
//                                       children: [
//                                         const Icon(Icons.brightness_3,
//                                             color: Colors.white70, size: 28),
//                                         Text(
//                                           _getMoonPhase(
//                                               (_currentData!['moon_phase'] ??
//                                                       0.5)
//                                                   .toDouble()),
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(
//                                               color: Colors.white),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),

//                             /// 📊 Temperature Graph
//                             _buildGraphCard(
//                               "Temperature Trend",
//                               _getChartSpotsTemp(),
//                               Colors.cyanAccent,
//                               "°",
//                             ),

//                             /// 📊 Rainfall Graph
//                             _buildGraphCard(
//                               "Rainfall Trend",
//                               _getChartSpotsRain(),
//                               Colors.lightBlueAccent,
//                               "mm",
//                             ),

//                             /// ⏳ Hourly Forecast
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16.0, vertical: 8.0),
//                                   child: Center(
//                                     child: Text(
//                                       "Hourly Forecast",
//                                       textAlign: TextAlign.center,
//                                       style: GoogleFonts.poppins(
//                                         // ✅ Now Poppins is applied
//                                         fontWeight: FontWeight.w600,
//                                         letterSpacing: 1.2,
//                                         fontSize: 16,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   height: 120,
//                                   child: ListView.builder(
//                                     scrollDirection: Axis.horizontal,
//                                     padding: const EdgeInsets.all(12),
//                                     itemCount: 8, // ~24 hours (3h * 8)
//                                     itemBuilder: (context, index) {
//                                       final item =
//                                           _forecastData!['list'][index];
//                                       final date =
//                                           DateTime.fromMillisecondsSinceEpoch(
//                                               item['dt'] * 1000);
//                                       final temp = item['main']['temp'];
//                                       final wind = item['wind']['speed'];
//                                       final rain =
//                                           item['rain']?['3h']?.toString() ??
//                                               "0";

//                                       return GlassmorphicContainer(
//                                         width: 100,
//                                         height: 100,
//                                         borderRadius: 20,
//                                         blur: 20,
//                                         border: 1,
//                                         margin:
//                                             const EdgeInsets.only(right: 12),
//                                         linearGradient: LinearGradient(
//                                           colors: [
//                                             Colors.white.withOpacity(0.15),
//                                             Colors.white.withOpacity(0.05),
//                                           ],
//                                           begin: Alignment.topLeft,
//                                           end: Alignment.bottomRight,
//                                         ),
//                                         borderGradient: LinearGradient(
//                                           colors: [
//                                             Colors.white.withOpacity(0.3),
//                                             Colors.white.withOpacity(0.05),
//                                           ],
//                                         ),
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Text(
//                                                 "${date.hour}:00",
//                                                 style: const TextStyle(
//                                                     color: Colors.white),
//                                               ),
//                                               Text(
//                                                 "${temp.toStringAsFixed(1)}°${widget.unit == "metric" ? "C" : "F"}",
//                                                 style: const TextStyle(
//                                                   color: Colors.cyanAccent,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 "💨 $wind m/s",
//                                                 style: const TextStyle(
//                                                   color: Colors.white70,
//                                                   fontSize: 12,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 "🌧 $rain mm",
//                                                 style: const TextStyle(
//                                                   color: Colors.white70,
//                                                   fontSize: 12,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             /// 📅 5-Day / 3-Hour Forecast Title
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 16.0, vertical: 8.0),
//                               child: Center(
//                                 child: Text(
//                                   "5-Day / 3-Hour Forecast",
//                                   textAlign: TextAlign.center,
//                                   style: GoogleFonts.poppins(
//                                     fontWeight: FontWeight.w600,
//                                     letterSpacing: 1.2,
//                                     fontSize: 16,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             /// 📅 5-Day Forecast (already there → kept)
//                             ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 8),
//                               itemCount: _forecastData?['list']?.length ?? 0,
//                               itemBuilder: (context, index) {
//                                 final item = _forecastData!['list'][index];
//                                 final date =
//                                     DateTime.fromMillisecondsSinceEpoch(
//                                         item['dt'] * 1000);
//                                 final temp = item['main']['temp'];
//                                 final description =
//                                     item['weather'][0]['description'];

//                                 return GlassmorphicContainer(
//                                   width: double.infinity,
//                                   height: 80,
//                                   borderRadius: 20,
//                                   blur: 20,
//                                   border: 1,
//                                   margin: const EdgeInsets.only(bottom: 12),
//                                   linearGradient: LinearGradient(
//                                     colors: [
//                                       Colors.white.withOpacity(0.15),
//                                       Colors.white.withOpacity(0.05),
//                                     ],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   borderGradient: LinearGradient(
//                                     colors: [
//                                       Colors.white.withOpacity(0.3),
//                                       Colors.white.withOpacity(0.05),
//                                     ],
//                                   ),
//                                   child: ListTile(
//                                     leading: Icon(Icons.cloud,
//                                         color: Colors.cyanAccent.shade100,
//                                         size: 30),
//                                     title: Text(
//                                       "${date.day}-${date.month} ${date.hour}:00",
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                     subtitle: Text(
//                                       description,
//                                       style: const TextStyle(
//                                           fontSize: 14, color: Colors.white70),
//                                     ),
//                                     trailing: Text(
//                                       "${temp.toStringAsFixed(1)}° ${widget.unit == "metric" ? "C" : "F"}",
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 🔹 Helper widget for Graph Cards
//   Widget _buildGraphCard(
//       String title, List<FlSpot> spots, Color color, String unit) {
//     if (spots.isEmpty) return const SizedBox();
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(25),
//         color: Colors.white.withOpacity(0.08),
//         border: Border.all(color: Colors.white.withOpacity(0.15)),
//       ),
//       height: MediaQuery.of(context).size.height * 0.25,
//       child: Column(
//         children: [
//           Text(title,
//               style: const TextStyle(color: Colors.white, fontSize: 16)),
//           const SizedBox(height: 10),
//           Expanded(
//             child: LineChart(
//               LineChartData(
//                 minY: spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 2,
//                 maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2,
//                 gridData: const FlGridData(show: true),
//                 borderData: FlBorderData(show: false),
//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       interval: 8, // show label every 2 points
//                       reservedSize: 50, // more space reserved for labels
//                       getTitlesWidget: (value, meta) => Padding(
//                         padding: const EdgeInsets.only(
//                             right: 6.0), // space between text & chart
//                         child: Text(
//                           "${value.toInt()}$unit",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       // interval: 2, // space between labels
//                       reservedSize: 32, // adds vertical breathing space
//                       getTitlesWidget: (value, meta) {
//                         return Padding(
//                           padding: const EdgeInsets.only(
//                               top: 12), // push labels down
//                           child: Text(
//                             value.toInt().toString(), // X-axis label
//                             style: const TextStyle(
//                               color: Colors.white, // pure white
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   topTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false)),
//                   rightTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false)),
//                 ),
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: spots,
//                     isCurved: true,
//                     color: color,
//                     barWidth: 3,
//                     dotData: const FlDotData(show: false),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // import 'dart:convert';
// // import 'dart:ui';
// // import 'package:flutter/material.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:fl_chart/fl_chart.dart';
// // import 'package:glassmorphism/glassmorphism.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:provider/provider.dart';
// // import '../provider/settings_provider.dart';

// // class ForecastScreen extends StatefulWidget {
// //   final String unit;
// //   const ForecastScreen({super.key, required this.unit});

// //   @override
// //   State<ForecastScreen> createState() => _ForecastScreenState();
// // }

// // class _ForecastScreenState extends State<ForecastScreen> {
// //   Map<String, dynamic>? _forecastData;
// //   Map<String, dynamic>? _currentData;
// //   bool _isLoading = true;
// //   String? _error;

// //   final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchForecast();
// //   }

// //   Future<void> _fetchForecast() async {
// //     try {
// //       Position pos = await Geolocator.getCurrentPosition();

// //       final forecastUrl =
// //           "https://api.openweathermap.org/data/2.5/forecast?lat=${pos.latitude}&lon=${pos.longitude}&units=${widget.unit}&appid=$apiKey";
// //       final currentUrl =
// //           "https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&units=${widget.unit}&appid=$apiKey";

// //       final forecastRes = await http.get(Uri.parse(forecastUrl));
// //       final currentRes = await http.get(Uri.parse(currentUrl));

// //       if (forecastRes.statusCode == 200 && currentRes.statusCode == 200) {
// //         setState(() {
// //           _forecastData = json.decode(forecastRes.body);
// //           _currentData = json.decode(currentRes.body);
// //           _isLoading = false;
// //         });
// //       } else {
// //         setState(() {
// //           _error = "Failed to load forecast (${forecastRes.statusCode})";
// //           _isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _error = "Error: $e";
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   List<FlSpot> _getChartSpotsTemp() {
// //     if (_forecastData == null) return [];
// //     final list = _forecastData!['list'];
// //     return List.generate(list.length, (i) {
// //       final temp = (list[i]['main']['temp'] as num).toDouble();
// //       return FlSpot(i.toDouble(), temp);
// //     });
// //   }

// //   List<FlSpot> _getChartSpotsRain() {
// //     if (_forecastData == null) return [];
// //     final list = _forecastData!['list'];
// //     return List.generate(list.length, (i) {
// //       final rain =
// //           list[i]['rain'] != null ? (list[i]['rain']['3h'] ?? 0.0) : 0.0;
// //       return FlSpot(i.toDouble(), (rain as num).toDouble());
// //     });
// //   }

// //   String _getMoonPhase(double moonPhase) {
// //     if (moonPhase == 0) return "New Moon";
// //     if (moonPhase < 0.25) return "Waxing Crescent";
// //     if (moonPhase == 0.25) return "First Quarter";
// //     if (moonPhase < 0.5) return "Waxing Gibbous";
// //     if (moonPhase == 0.5) return "Full Moon";
// //     if (moonPhase < 0.75) return "Waning Gibbous";
// //     if (moonPhase == 0.75) return "Last Quarter";
// //     return "Waning Crescent";
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final settings = Provider.of<SettingsProvider>(context);

// //     return Scaffold(
// //       backgroundColor: settings.themeMode == "System"
// //           ? Colors.transparent
// //           : settings.getBackgroundColor(),
// //       appBar: AppBar(
// //         title: Text(
// //           "Forecast",
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold,
// //             letterSpacing: 1.2,
// //             color: settings.getTextColor(),
// //           ),
// //         ),
// //         elevation: 0,
// //         backgroundColor: Colors.transparent,
// //       ),
// //       body: Stack(
// //         children: [
// //           if (settings.themeMode == "System")
// //             AnimatedContainer(
// //               duration: const Duration(seconds: 2),
// //               decoration: const BoxDecoration(
// //                 gradient: LinearGradient(
// //                   colors: [Colors.indigo, Colors.deepPurple, Colors.black],
// //                   begin: Alignment.topCenter,
// //                   end: Alignment.bottomCenter,
// //                 ),
// //               ),
// //             ),
// //           _isLoading
// //               ? const Center(
// //                   child: CircularProgressIndicator(color: Colors.white))
// //               : _error != null
// //                   ? Center(
// //                       child: Text(
// //                         _error!,
// //                         style: TextStyle(color: settings.getTextColor()),
// //                       ),
// //                     )
// //                   : SingleChildScrollView(
// //                       child: Column(
// //                         children: [
// //                           SizedBox(
// //                               height:
// //                                   MediaQuery.of(context).size.height * 0.02),

// //                           /// 🌅 Sunrise & Sunset
// //                           if (_currentData != null)
// //                             Container(
// //                               margin: const EdgeInsets.all(16),
// //                               padding: const EdgeInsets.all(16),
// //                               decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.circular(20),
// //                                 color: settings.themeMode == "System"
// //                                     ? Colors.white.withOpacity(0.08)
// //                                     : Colors.transparent,
// //                                 border: Border.all(
// //                                     color: settings.getBorderColor()),
// //                               ),
// //                               child: Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceAround,
// //                                 children: [
// //                                   Column(
// //                                     children: [
// //                                       const Icon(Icons.wb_sunny,
// //                                           color: Colors.orange, size: 28),
// //                                       Text(
// //                                         "Sunrise\n${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunrise'] * 1000).hour}:${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunrise'] * 1000).minute.toString().padLeft(2, '0')}",
// //                                         textAlign: TextAlign.center,
// //                                         style: TextStyle(
// //                                             color: settings.getTextColor()),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   Column(
// //                                     children: [
// //                                       const Icon(Icons.nights_stay,
// //                                           color: Colors.blueAccent, size: 28),
// //                                       Text(
// //                                         "Sunset\n${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunset'] * 1000).hour}:${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunset'] * 1000).minute.toString().padLeft(2, '0')}",
// //                                         textAlign: TextAlign.center,
// //                                         style: TextStyle(
// //                                             color: settings.getTextColor()),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),

// //                           /// 📊 Temperature Graph
// //                           _buildGraphCard(
// //                             "Temperature Trend",
// //                             _getChartSpotsTemp(),
// //                             Colors.cyanAccent,
// //                             "°",
// //                             settings,
// //                           ),

// //                           /// 📊 Rainfall Graph
// //                           _buildGraphCard(
// //                             "Rainfall Trend",
// //                             _getChartSpotsRain(),
// //                             Colors.lightBlueAccent,
// //                             "mm",
// //                             settings,
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //         ],
// //       ),
// //     );
// //   }

// //   /// 🔹 Helper widget for Graph Cards
// //   Widget _buildGraphCard(String title, List<FlSpot> spots, Color color,
// //       String unit, SettingsProvider settings) {
// //     if (spots.isEmpty) return const SizedBox();
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(25),
// //         color: settings.themeMode == "System"
// //             ? Colors.white.withOpacity(0.08)
// //             : Colors.transparent,
// //         border: Border.all(color: settings.getBorderColor()),
// //       ),
// //       height: MediaQuery.of(context).size.height * 0.25,
// //       child: Column(
// //         children: [
// //           Text(title,
// //               style: TextStyle(color: settings.getTextColor(), fontSize: 16)),
// //           const SizedBox(height: 10),
// //           Expanded(
// //             child: LineChart(
// //               LineChartData(
// //                 minY: spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 2,
// //                 maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2,
// //                 gridData: const FlGridData(show: true),
// //                 borderData: FlBorderData(show: false),
// //                 titlesData: FlTitlesData(
// //                   leftTitles: AxisTitles(
// //                     sideTitles: SideTitles(
// //                       showTitles: true,
// //                       reservedSize: 50,
// //                       getTitlesWidget: (value, meta) => Padding(
// //                         padding: const EdgeInsets.only(right: 6.0),
// //                         child: Text(
// //                           "${value.toInt()}$unit",
// //                           style: TextStyle(
// //                             color: settings.getTextColor(),
// //                             fontSize: 12,
// //                             fontWeight: FontWeight.w500,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   bottomTitles: AxisTitles(
// //                     sideTitles: SideTitles(
// //                       showTitles: true,
// //                       reservedSize: 32,
// //                       getTitlesWidget: (value, meta) {
// //                         return Padding(
// //                           padding: const EdgeInsets.only(top: 12),
// //                           child: Text(
// //                             value.toInt().toString(),
// //                             style: TextStyle(
// //                               color: settings.getTextColor(),
// //                               fontSize: 12,
// //                               fontWeight: FontWeight.w500,
// //                             ),
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                   ),
// //                   topTitles: const AxisTitles(
// //                       sideTitles: SideTitles(showTitles: false)),
// //                   rightTitles: const AxisTitles(
// //                       sideTitles: SideTitles(showTitles: false)),
// //                 ),
// //                 lineBarsData: [
// //                   LineChartBarData(
// //                     spots: spots,
// //                     isCurved: true,
// //                     color: color,
// //                     barWidth: 3,
// //                     dotData: const FlDotData(show: false),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:fl_chart/fl_chart.dart';
// import 'package:glassmorphism/glassmorphism.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import '../provider/settings_provider.dart';

// class ForecastScreen extends StatefulWidget {
//   final String unit;
//   const ForecastScreen({super.key, required this.unit});

//   @override
//   State<ForecastScreen> createState() => _ForecastScreenState();
// }

// class _ForecastScreenState extends State<ForecastScreen> {
//   Map<String, dynamic>? _forecastData;
//   Map<String, dynamic>? _currentData;
//   bool _isLoading = true;
//   String? _error;

//   final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";

//   @override
//   void initState() {
//     super.initState();
//     _fetchForecast();
//   }

//   Future<void> _fetchForecast() async {
//     try {
//       Position pos = await Geolocator.getCurrentPosition();

//       final forecastUrl =
//           "https://api.openweathermap.org/data/2.5/forecast?lat=${pos.latitude}&lon=${pos.longitude}&units=${widget.unit}&appid=$apiKey";
//       final currentUrl =
//           "https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&units=${widget.unit}&appid=$apiKey";

//       final forecastRes = await http.get(Uri.parse(forecastUrl));
//       final currentRes = await http.get(Uri.parse(currentUrl));

//       if (forecastRes.statusCode == 200 && currentRes.statusCode == 200) {
//         setState(() {
//           _forecastData = json.decode(forecastRes.body);
//           _currentData = json.decode(currentRes.body);
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _error = "Failed to load forecast (${forecastRes.statusCode})";
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _error = "Error: $e";
//         _isLoading = false;
//       });
//     }
//   }

//   List<FlSpot> _getChartSpotsTemp() {
//     if (_forecastData == null) return [];
//     final list = _forecastData!['list'];
//     return List.generate(list.length, (i) {
//       final temp = (list[i]['main']['temp'] as num).toDouble();
//       return FlSpot(i.toDouble(), temp);
//     });
//   }

//   List<FlSpot> _getChartSpotsRain() {
//     if (_forecastData == null) return [];
//     final list = _forecastData!['list'];
//     return List.generate(list.length, (i) {
//       final rain =
//           list[i]['rain'] != null ? (list[i]['rain']['3h'] ?? 0.0) : 0.0;
//       return FlSpot(i.toDouble(), (rain as num).toDouble());
//     });
//   }

//   String _getMoonPhase(double moonPhase) {
//     if (moonPhase == 0) return "New Moon";
//     if (moonPhase < 0.25) return "Waxing Crescent";
//     if (moonPhase == 0.25) return "First Quarter";
//     if (moonPhase < 0.5) return "Waxing Gibbous";
//     if (moonPhase == 0.5) return "Full Moon";
//     if (moonPhase < 0.75) return "Waning Gibbous";
//     if (moonPhase == 0.75) return "Last Quarter";
//     return "Waning Crescent";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SettingsProvider>(
//       builder: (context, settings, _) {
//         final themeMode = settings.themeMode;

//         // Colors depending on theme
//         final bool isLight = themeMode == "Light";
//         final bool isDark = themeMode == "Dark";
//         final bool isSystem = themeMode == "System";

//         final Color bgColor = isLight
//             ? Colors.white
//             : isDark
//                 ? Colors.black
//                 : Colors.transparent;
//         final Color textColor = isLight
//             ? Colors.blue
//             : isDark
//                 ? Colors.white
//                 : Colors.white;
//         final Color borderColor = isLight
//             ? Colors.blue
//             : isDark
//                 ? Colors.white
//                 : Colors.white30;

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text(
//               "Forecast",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.2,
//               ),
//             ),
//             elevation: 0,
//             backgroundColor:
//                 isSystem ? Colors.transparent : bgColor, // glass for system
//             flexibleSpace: isSystem
//                 ? GlassmorphicContainer(
//                     width: double.infinity,
//                     height: double.infinity,
//                     borderRadius: 0,
//                     blur: 20,
//                     border: 0,
//                     linearGradient: LinearGradient(
//                       colors: [
//                         const Color.fromARGB(255, 97, 234, 230)
//                             .withOpacity(0.25),
//                         Colors.white.withOpacity(0.05),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderGradient: LinearGradient(
//                       colors: [
//                         Colors.white.withOpacity(0.3),
//                         Colors.white.withOpacity(0.1),
//                       ],
//                     ),
//                   )
//                 : null,
//           ),
//           body: Stack(
//             children: [
//               if (isSystem)
//                 AnimatedContainer(
//                   duration: const Duration(seconds: 2),
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.indigo, Colors.deepPurple, Colors.black],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                   ),
//                 )
//               else
//                 Container(color: bgColor),
//               GlassmorphicContainer(
//                 width: double.infinity,
//                 height: double.infinity,
//                 borderRadius: 0,
//                 blur: isSystem ? 25 : 0,
//                 border: 0,
//                 linearGradient: LinearGradient(
//                   colors: isSystem
//                       ? [
//                           Colors.white.withOpacity(0.08),
//                           Colors.white.withOpacity(0.02),
//                         ]
//                       : [bgColor, bgColor],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderGradient: LinearGradient(
//                   colors: isSystem
//                       ? [
//                           Colors.white.withOpacity(0.3),
//                           Colors.white.withOpacity(0.05),
//                         ]
//                       : [borderColor, borderColor],
//                 ),
//                 child: _isLoading
//                     ? Center(child: CircularProgressIndicator(color: textColor))
//                     : _error != null
//                         ? Center(
//                             child: Text(
//                               _error!,
//                               style: TextStyle(color: textColor),
//                             ),
//                           )
//                         : SingleChildScrollView(
//                             child: Column(
//                               children: [
//                                 SizedBox(
//                                     height: MediaQuery.of(context).size.height *
//                                         0.02),

//                                 /// 🌅 Sunrise & Sunset
//                                 if (_currentData != null)
//                                   Container(
//                                     margin: const EdgeInsets.all(16),
//                                     padding: const EdgeInsets.all(16),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(20),
//                                       color: bgColor.withOpacity(0.08),
//                                       border: Border.all(color: borderColor),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceAround,
//                                       children: [
//                                         Column(
//                                           children: [
//                                             const Icon(Icons.wb_sunny,
//                                                 color: Colors.orange, size: 28),
//                                             Text(
//                                               "Sunrise\n${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunrise'] * 1000).hour}:${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunrise'] * 1000).minute.toString().padLeft(2, '0')}",
//                                               textAlign: TextAlign.center,
//                                               style:
//                                                   TextStyle(color: textColor),
//                                             ),
//                                           ],
//                                         ),
//                                         Column(
//                                           children: [
//                                             const Icon(Icons.nights_stay,
//                                                 color: Colors.blueAccent,
//                                                 size: 28),
//                                             Text(
//                                               "Sunset\n${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunset'] * 1000).hour}:${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunset'] * 1000).minute.toString().padLeft(2, '0')}",
//                                               textAlign: TextAlign.center,
//                                               style:
//                                                   TextStyle(color: textColor),
//                                             ),
//                                           ],
//                                         ),
//                                         Column(
//                                           children: [
//                                             Icon(
//                                               Icons.brightness_3,
//                                               size: 32,
//                                               color: Colors.grey
//                                                   .shade400, // 🌙 light silver (visible on white bg)
//                                               shadows: [
//                                                 Shadow(
//                                                   blurRadius: 8,
//                                                   color: Colors.black
//                                                       .withOpacity(
//                                                           0.5), // subtle glow
//                                                   offset: const Offset(2, 2),
//                                                 ),
//                                               ],
//                                             ),
//                                             Text(
//                                               _getMoonPhase((_currentData![
//                                                           'moon_phase'] ??
//                                                       0.5)
//                                                   .toDouble()),
//                                               textAlign: TextAlign.center,
//                                               style:
//                                                   TextStyle(color: textColor),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),

//                                 /// 📊 Temperature Graph
//                                 _buildGraphCard(
//                                   "Temperature Trend",
//                                   _getChartSpotsTemp(),
//                                   Colors.cyanAccent,
//                                   "°",
//                                   textColor,
//                                   borderColor,
//                                   bgColor,
//                                 ),

//                                 /// 📊 Rainfall Graph
//                                 _buildGraphCard(
//                                   "Rainfall Trend",
//                                   _getChartSpotsRain(),
//                                   Colors.lightBlueAccent,
//                                   "mm",
//                                   textColor,
//                                   borderColor,
//                                   bgColor,
//                                 ),

//                                 /// ⏳ Hourly Forecast
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 16.0, vertical: 8.0),
//                                       child: Center(
//                                         child: Text(
//                                           "Hourly Forecast",
//                                           style: GoogleFonts.poppins(
//                                             fontWeight: FontWeight.w600,
//                                             letterSpacing: 1.2,
//                                             fontSize: 16,
//                                             color: textColor,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height: 120,
//                                       child: ListView.builder(
//                                         scrollDirection: Axis.horizontal,
//                                         padding: const EdgeInsets.all(12),
//                                         itemCount: 8,
//                                         itemBuilder: (context, index) {
//                                           final item =
//                                               _forecastData!['list'][index];
//                                           final date = DateTime
//                                               .fromMillisecondsSinceEpoch(
//                                                   item['dt'] * 1000);
//                                           final temp = item['main']['temp'];
//                                           final wind = item['wind']['speed'];
//                                           final rain =
//                                               item['rain']?['3h']?.toString() ??
//                                                   "0";

//                                           return GlassmorphicContainer(
//                                             width: 100,
//                                             height: 100,
//                                             borderRadius: 20,
//                                             blur: isSystem ? 20 : 0,
//                                             border: 1,
//                                             margin: const EdgeInsets.only(
//                                                 right: 12),
//                                             linearGradient: LinearGradient(
//                                               colors: isSystem
//                                                   ? [
//                                                       Colors.white
//                                                           .withOpacity(0.15),
//                                                       Colors.white
//                                                           .withOpacity(0.05),
//                                                     ]
//                                                   : [bgColor, bgColor],
//                                             ),
//                                             borderGradient: LinearGradient(
//                                               colors: isSystem
//                                                   ? [
//                                                       Colors.white
//                                                           .withOpacity(0.3),
//                                                       Colors.white
//                                                           .withOpacity(0.05),
//                                                     ]
//                                                   : [borderColor, borderColor],
//                                             ),
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Text(
//                                                     "${date.hour}:00",
//                                                     style: TextStyle(
//                                                         color: textColor),
//                                                   ),
//                                                   Text(
//                                                     "${temp.toStringAsFixed(1)}°${widget.unit == "metric" ? "C" : "F"}",
//                                                     style: const TextStyle(
//                                                       color: Colors.cyanAccent,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     "💨 $wind m/s",
//                                                     style: TextStyle(
//                                                       color: textColor
//                                                           .withOpacity(0.7),
//                                                       fontSize: 12,
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     "🌧 $rain mm",
//                                                     style: TextStyle(
//                                                       color: textColor
//                                                           .withOpacity(0.7),
//                                                       fontSize: 12,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),

//                                 /// 📅 5-Day / 3-Hour Forecast
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16.0, vertical: 8.0),
//                                   child: Center(
//                                     child: Text(
//                                       "5-Day / 3-Hour Forecast",
//                                       style: GoogleFonts.poppins(
//                                         fontWeight: FontWeight.w600,
//                                         letterSpacing: 1.2,
//                                         fontSize: 16,
//                                         color: textColor,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 ListView.builder(
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16, vertical: 8),
//                                   itemCount:
//                                       _forecastData?['list']?.length ?? 0,
//                                   itemBuilder: (context, index) {
//                                     final item = _forecastData!['list'][index];
//                                     final date =
//                                         DateTime.fromMillisecondsSinceEpoch(
//                                             item['dt'] * 1000);
//                                     final temp = item['main']['temp'];
//                                     final description =
//                                         item['weather'][0]['description'];

//                                     return GlassmorphicContainer(
//                                       width: double.infinity,
//                                       height: 80,
//                                       borderRadius: 20,
//                                       blur: isSystem ? 20 : 0,
//                                       border: 1,
//                                       margin: const EdgeInsets.only(bottom: 12),
//                                       linearGradient: LinearGradient(
//                                         colors: isSystem
//                                             ? [
//                                                 Colors.white.withOpacity(0.15),
//                                                 Colors.white.withOpacity(0.05),
//                                               ]
//                                             : [bgColor, bgColor],
//                                       ),
//                                       borderGradient: LinearGradient(
//                                         colors: isSystem
//                                             ? [
//                                                 Colors.white.withOpacity(0.3),
//                                                 Colors.white.withOpacity(0.05),
//                                               ]
//                                             : [borderColor, borderColor],
//                                       ),
//                                       child: ListTile(
//                                         leading: Icon(Icons.cloud,
//                                             color: Colors.cyanAccent.shade100,
//                                             size: 30),
//                                         title: Text(
//                                           "${date.day}-${date.month} ${date.hour}:00",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                             color: textColor,
//                                           ),
//                                         ),
//                                         subtitle: Text(
//                                           description,
//                                           style: TextStyle(
//                                               fontSize: 14,
//                                               color:
//                                                   textColor.withOpacity(0.7)),
//                                         ),
//                                         trailing: Text(
//                                           "${temp.toStringAsFixed(1)}° ${widget.unit == "metric" ? "C" : "F"}",
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600,
//                                             color: textColor,
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   /// 🔹 Helper widget for Graph Cards
//   Widget _buildGraphCard(String title, List<FlSpot> spots, Color color,
//       String unit, Color textColor, Color borderColor, Color bgColor) {
//     if (spots.isEmpty) return const SizedBox();
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(25),
//         color: bgColor.withOpacity(0.08),
//         border: Border.all(color: borderColor),
//       ),
//       height: MediaQuery.of(context).size.height * 0.25,
//       child: Column(
//         children: [
//           Text(title, style: TextStyle(color: textColor, fontSize: 16)),
//           const SizedBox(height: 10),
//           Expanded(
//             child: LineChart(
//               LineChartData(
//                 minY: spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 2,
//                 maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2,
//                 gridData: const FlGridData(show: true),
//                 borderData: FlBorderData(show: false),
//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 50,
//                       getTitlesWidget: (value, meta) => Padding(
//                         padding: const EdgeInsets.only(right: 6.0),
//                         child: Text(
//                           "${value.toInt()}$unit",
//                           style: TextStyle(
//                             color: textColor,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 32,
//                       getTitlesWidget: (value, meta) {
//                         return Padding(
//                           padding: const EdgeInsets.only(top: 12),
//                           child: Text(
//                             value.toInt().toString(),
//                             style: TextStyle(
//                               color: textColor,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   topTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false)),
//                   rightTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false)),
//                 ),
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: spots,
//                     isCurved: true,
//                     color: color,
//                     barWidth: 3,
//                     dotData: const FlDotData(show: false),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../provider/settings_provider.dart';

class ForecastScreen extends StatefulWidget {
  final String unit;
  const ForecastScreen({super.key, required this.unit});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  Map<String, dynamic>? _forecastData;
  Map<String, dynamic>? _currentData;
  bool _isLoading = true;
  String? _error;

  final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    try {
      Position pos = await Geolocator.getCurrentPosition();

      final forecastUrl =
          "https://api.openweathermap.org/data/2.5/forecast?lat=${pos.latitude}&lon=${pos.longitude}&units=${widget.unit}&appid=$apiKey";
      final currentUrl =
          "https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&units=${widget.unit}&appid=$apiKey";

      final forecastRes = await http.get(Uri.parse(forecastUrl));
      final currentRes = await http.get(Uri.parse(currentUrl));

      if (forecastRes.statusCode == 200 && currentRes.statusCode == 200) {
        setState(() {
          _forecastData = json.decode(forecastRes.body);
          _currentData = json.decode(currentRes.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load forecast (${forecastRes.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
        _isLoading = false;
      });
    }
  }

  List<FlSpot> _getChartSpotsTemp() {
    if (_forecastData == null) return [];
    final list = _forecastData!['list'];
    return List.generate(list.length, (i) {
      final temp = (list[i]['main']['temp'] as num).toDouble();
      return FlSpot(i.toDouble(), temp);
    });
  }

  List<FlSpot> _getChartSpotsRain() {
    if (_forecastData == null) return [];
    final list = _forecastData!['list'];
    return List.generate(list.length, (i) {
      final rain =
          list[i]['rain'] != null ? (list[i]['rain']['3h'] ?? 0.0) : 0.0;
      return FlSpot(i.toDouble(), (rain as num).toDouble());
    });
  }

  String _getMoonPhase(double moonPhase) {
    if (moonPhase == 0) return "New Moon";
    if (moonPhase < 0.25) return "Waxing Crescent";
    if (moonPhase == 0.25) return "First Quarter";
    if (moonPhase < 0.5) return "Waxing Gibbous";
    if (moonPhase == 0.5) return "Full Moon";
    if (moonPhase < 0.75) return "Waning Gibbous";
    if (moonPhase == 0.75) return "Last Quarter";
    return "Waning Crescent";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final themeMode = settings.themeMode;

        // Colors depending on theme
        final bool isLight = themeMode == "Light";
        final bool isDark = themeMode == "Dark";
        final bool isSystem = themeMode == "System";

        final Color bgColor = isLight
            ? Colors.white
            : isDark
                ? Colors.black
                : Colors.transparent;
        final Color textColor = isLight
            ? Colors.blue
            : isDark
                ? Colors.white
                : Colors.white;
        final Color borderColor = isLight
            ? Colors.blue
            : isDark
                ? Colors.white
                : Colors.white30;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Forecast",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: textColor,
              ),
            ),
            elevation: 0,
            backgroundColor: bgColor,
            flexibleSpace: isSystem
                ? GlassmorphicContainer(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 0,
                    blur: 20,
                    border: 0,
                    linearGradient: const LinearGradient(
                      colors: [
                        Colors.indigo,
                        Colors.deepPurple,
                        // Colors.black,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                  )
                : null,
          ),
          body: Stack(
            children: [
              if (isSystem)
                AnimatedContainer(
                  duration: const Duration(seconds: 2),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo, Colors.deepPurple, Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                )
              else
                Container(color: bgColor),
              GlassmorphicContainer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 0,
                blur: isSystem ? 25 : 0,
                border: 0,
                linearGradient: LinearGradient(
                  colors: isSystem
                      ? [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.02),
                        ]
                      : [bgColor, bgColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderGradient: LinearGradient(
                  colors: isSystem
                      ? [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.05),
                        ]
                      : [borderColor, borderColor],
                ),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: textColor))
                    : _error != null
                        ? Center(
                            child: Text(
                              _error!,
                              style: TextStyle(color: textColor),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),

                                /// 🌅 Sunrise & Sunset
                                if (_currentData != null)
                                  Container(
                                    margin: const EdgeInsets.all(16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: isSystem
                                          ? Colors.white.withOpacity(0.08)
                                          : bgColor.withOpacity(0.08),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            const Icon(Icons.wb_sunny,
                                                color: Colors.orange, size: 28),
                                            Text(
                                              "Sunrise\n${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunrise'] * 1000).hour}:${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunrise'] * 1000).minute.toString().padLeft(2, '0')}",
                                              textAlign: TextAlign.center,
                                              style:
                                                  TextStyle(color: textColor),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            const Icon(Icons.nights_stay,
                                                color: Colors.blueAccent,
                                                size: 28),
                                            Text(
                                              "Sunset\n${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunset'] * 1000).hour}:${DateTime.fromMillisecondsSinceEpoch(_currentData!['sys']['sunset'] * 1000).minute.toString().padLeft(2, '0')}",
                                              textAlign: TextAlign.center,
                                              style:
                                                  TextStyle(color: textColor),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.brightness_3,
                                              size: 32,
                                              color: Colors.grey
                                                  .shade400, // 🌙 light silver (visible on white bg)
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 8,
                                                  color: Colors.black
                                                      .withOpacity(
                                                          0.5), // subtle glow
                                                  offset: const Offset(2, 2),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              _getMoonPhase((_currentData![
                                                          'moon_phase'] ??
                                                      0.5)
                                                  .toDouble()),
                                              textAlign: TextAlign.center,
                                              style:
                                                  TextStyle(color: textColor),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                /// 📊 Temperature Graph
                                _buildGraphCard(
                                  "Temperature Trend",
                                  _getChartSpotsTemp(),
                                  Colors.cyanAccent,
                                  "°",
                                  textColor,
                                  borderColor,
                                  bgColor,
                                ),

                                /// 📊 Rainfall Graph
                                _buildGraphCard(
                                  "Rainfall Trend",
                                  _getChartSpotsRain(),
                                  Colors.lightBlueAccent,
                                  "mm",
                                  textColor,
                                  borderColor,
                                  bgColor,
                                ),

                                /// ⏳ Hourly Forecast
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      child: Center(
                                        child: Text(
                                          "Hourly Forecast",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.2,
                                            fontSize: 16,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 120,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.all(12),
                                        itemCount: 8,
                                        itemBuilder: (context, index) {
                                          final item =
                                              _forecastData!['list'][index];
                                          final date = DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  item['dt'] * 1000);
                                          final temp = item['main']['temp'];
                                          final wind = item['wind']['speed'];
                                          final rain =
                                              item['rain']?['3h']?.toString() ??
                                                  "0";

                                          return GlassmorphicContainer(
                                            width: 100,
                                            height: 100,
                                            borderRadius: 20,
                                            blur: isSystem ? 20 : 0,
                                            border: 1,
                                            margin: const EdgeInsets.only(
                                                right: 12),
                                            linearGradient: LinearGradient(
                                              colors: isSystem
                                                  ? [
                                                      Colors.white
                                                          .withOpacity(0.15),
                                                      Colors.white
                                                          .withOpacity(0.05),
                                                    ]
                                                  : [bgColor, bgColor],
                                            ),
                                            borderGradient: LinearGradient(
                                              colors: isSystem
                                                  ? [
                                                      Colors.white
                                                          .withOpacity(0.3),
                                                      Colors.white
                                                          .withOpacity(0.05),
                                                    ]
                                                  : [borderColor, borderColor],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${date.hour}:00",
                                                    style: TextStyle(
                                                        color: textColor),
                                                  ),
                                                  Text(
                                                    "${temp.toStringAsFixed(1)}°${widget.unit == "metric" ? "C" : "F"}",
                                                    style: const TextStyle(
                                                      color: Colors.cyanAccent,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "💨 $wind m/s",
                                                    style: TextStyle(
                                                      color: textColor
                                                          .withOpacity(0.7),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    "🌧 $rain mm",
                                                    style: TextStyle(
                                                      color: textColor
                                                          .withOpacity(0.7),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                /// 📅 5-Day / 3-Hour Forecast
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Center(
                                    child: Text(
                                      "5-Day / 3-Hour Forecast",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                        fontSize: 16,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  itemCount:
                                      _forecastData?['list']?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final item = _forecastData!['list'][index];
                                    final date =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            item['dt'] * 1000);
                                    final temp = item['main']['temp'];
                                    final description =
                                        item['weather'][0]['description'];

                                    return GlassmorphicContainer(
                                      width: double.infinity,
                                      height: 80,
                                      borderRadius: 20,
                                      blur: isSystem ? 20 : 0,
                                      border: 1,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      linearGradient: LinearGradient(
                                        colors: isSystem
                                            ? [
                                                Colors.white.withOpacity(0.15),
                                                Colors.white.withOpacity(0.05),
                                              ]
                                            : [bgColor, bgColor],
                                      ),
                                      borderGradient: LinearGradient(
                                        colors: isSystem
                                            ? [
                                                Colors.white.withOpacity(0.3),
                                                Colors.white.withOpacity(0.05),
                                              ]
                                            : [borderColor, borderColor],
                                      ),
                                      child: ListTile(
                                        leading: Icon(Icons.cloud,
                                            color: Colors.cyanAccent.shade100,
                                            size: 30),
                                        title: Text(
                                          "${date.day}-${date.month} ${date.hour}:00",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: textColor,
                                          ),
                                        ),
                                        subtitle: Text(
                                          description,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  textColor.withOpacity(0.7)),
                                        ),
                                        trailing: Text(
                                          "${temp.toStringAsFixed(1)}° ${widget.unit == "metric" ? "C" : "F"}",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 Helper widget for Graph Cards
  Widget _buildGraphCard(String title, List<FlSpot> spots, Color color,
      String unit, Color textColor, Color borderColor, Color bgColor) {
    if (spots.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: bgColor.withOpacity(0.08),
        border: Border.all(color: borderColor),
      ),
      height: MediaQuery.of(context).size.height * 0.25,
      child: Column(
        children: [
          Text(title, style: TextStyle(color: textColor, fontSize: 16)),
          const SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 2,
                maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2,
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 8, // show label every 2 points
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Text(
                          "${value.toInt()}$unit",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      // interval: 2, // space between labels
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
