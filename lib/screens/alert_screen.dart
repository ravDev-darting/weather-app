// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../provider/settings_provider.dart';

// class AlertsAndSuggestionsPage extends StatefulWidget {
//   final String city;

//   const AlertsAndSuggestionsPage({
//     super.key,
//     required this.city,
//   });

//   @override
//   _AlertsAndSuggestionsPageState createState() =>
//       _AlertsAndSuggestionsPageState();
// }

// class _AlertsAndSuggestionsPageState extends State<AlertsAndSuggestionsPage> {
//   final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";
//   Map<String, dynamic>? weatherData;
//   List<String> alerts = [];
//   List<String> suggestions = [];
//   List<Map<String, dynamic>> customAlerts = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadCustomAlerts();
//     fetchWeather();
//   }

//   Future<void> loadCustomAlerts() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? alertsJson = prefs.getString('custom_alerts');
//     if (alertsJson != null) {
//       try {
//         final List<dynamic> decoded = json.decode(alertsJson);
//         setState(() {
//           customAlerts = decoded.cast<Map<String, dynamic>>();
//         });
//       } catch (e) {
//         debugPrint('Error loading custom alerts: $e');
//       }
//     }
//   }

//   Future<void> saveCustomAlerts() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String alertsJson = json.encode(customAlerts);
//     await prefs.setString('custom_alerts', alertsJson);
//   }

//   Future<void> fetchWeather() async {
//     final settings = Provider.of<SettingsProvider>(context, listen: false);
//     final unit = settings.temperatureUnit == "°C" ? "metric" : "imperial";

//     final url = Uri.parse(
//       "https://api.openweathermap.org/data/2.5/weather?q=${widget.city}&units=$unit&appid=$apiKey",
//     );
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         setState(() {
//           weatherData = json.decode(response.body);
//           generateAlertsAndSuggestions(unit);
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to fetch weather data')),
//           );
//         }
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     }
//   }

//   void generateAlertsAndSuggestions(String unit) {
//     if (weatherData == null) return;

//     final double temp = weatherData!['main']['temp'].toDouble();
//     final int humidity = weatherData!['main']['humidity'];
//     final double windSpeed = weatherData!['wind']['speed'].toDouble();
//     final String weatherMain = weatherData!['weather'][0]['main'].toLowerCase();
//     final int clouds = weatherData!['clouds']['all'];

//     alerts.clear();
//     if (weatherMain.contains('storm')) {
//       alerts.add('⚠ Storm alert: Expect thunderstorms in ${widget.city}.');
//     }
//     if (weatherMain.contains('rain') && temp < 5) {
//       alerts.add('⚠ Flood risk: Heavy rain + low temp in ${widget.city}.');
//     }
//     if ((unit == 'metric' && temp > 35) || (unit == 'imperial' && temp > 95)) {
//       alerts.add('⚠ Heatwave alert: Extreme heat in ${widget.city}.');
//     }
//     if (windSpeed > 20) {
//       alerts.add(
//           '⚠ High winds: ${windSpeed.toStringAsFixed(1)} ${unit == 'metric' ? 'm/s' : 'mph'} in ${widget.city}.');
//     }

//     suggestions.clear();
//     if (weatherMain.contains('rain')) {
//       suggestions.add('Carry an umbrella today.');
//     }
//     if ((unit == 'metric' && temp > 15 && temp < 25) ||
//         (unit == 'imperial' && temp > 59 && temp < 77)) {
//       suggestions.add('Great day for running outdoors.');
//     }
//     if (weatherMain.contains('clear') && clouds < 20) {
//       suggestions.add('Use sunscreen, UV index likely high.');
//     }
//     if (humidity > 70) {
//       suggestions.add('Indoor activities recommended (high humidity).');
//     }

//     if (weatherMain.contains('rain') && customAlerts.isNotEmpty) {
//       for (var alert in customAlerts) {
//         if (alert['condition'] == 'rain_chance_gt_60') {
//           alerts.add(
//               '🔔 Custom alert triggered: Rain chance > 60% in ${widget.city}.');
//         }
//       }
//     }
//   }

//   void addCustomAlert() {
//     String condition = '';
//     final settings = Provider.of<SettingsProvider>(context, listen: false);
//     final bgColor = settings.themeMode == "Dark"
//         ? Colors.black
//         : settings.themeMode == "Light"
//             ? Colors.white
//             : const Color.fromARGB(255, 215, 246, 253);
//     final textColor = settings.themeMode == "Light"
//         ? Colors.blue
//         : const Color.fromARGB(255, 11, 11, 11);
//     final borderColor = textColor;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: bgColor,
//         title: Text(
//           'Add Custom Alert',
//           style: GoogleFonts.poppins(
//             color: textColor,
//             fontSize: 20,
//             fontWeight: FontWeight.normal,
//           ),
//         ),
//         content: TextField(
//           style: GoogleFonts.poppins(color: textColor),
//           decoration: InputDecoration(
//             labelText: 'Condition (e.g., rain_chance_gt_60)',
//             labelStyle: GoogleFonts.poppins(color: textColor),
//             enabledBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: borderColor),
//             ),
//             focusedBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: borderColor),
//             ),
//           ),
//           onChanged: (value) => condition = value,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               if (condition.isNotEmpty) {
//                 setState(() {
//                   customAlerts.add({'condition': condition});
//                 });
//                 await saveCustomAlerts();
//               }
//               Navigator.pop(context);
//             },
//             child: Text(
//               'Add',
//               style: GoogleFonts.poppins(color: textColor),
//             ),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: GoogleFonts.poppins(color: textColor),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void deleteCustomAlert(int index) async {
//     setState(() {
//       customAlerts.removeAt(index);
//     });
//     await saveCustomAlerts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final settings = Provider.of<SettingsProvider>(context);

//     Color bgColor;
//     Color textColor;
//     Color cardBgColor;
//     Color borderColor;

//     switch (settings.themeMode) {
//       case "Light":
//         bgColor = Colors.white;
//         textColor = Colors.blue;
//         cardBgColor = Colors.white.withOpacity(0.8);
//         borderColor = Colors.blue;
//         break;
//       case "Dark":
//         bgColor = Colors.black;
//         textColor = Colors.white;
//         cardBgColor = Colors.grey[900]!.withOpacity(0.8);
//         borderColor = Colors.white;
//         break;
//       default: // System
//         bgColor = Colors.transparent;
//         textColor = Colors.white;
//         cardBgColor = Colors.white.withOpacity(0.1);
//         borderColor = Colors.white.withOpacity(0.2);
//     }

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: Text(
//           'Alerts & AI Suggestions',
//           style: GoogleFonts.poppins(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: textColor,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add_alert, color: textColor),
//             onPressed: addCustomAlert,
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: settings.themeMode == "System"
//             ? const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Colors.blue, Colors.purple],
//                 ),
//               )
//             : BoxDecoration(color: bgColor),
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : CustomScrollView(
//                 slivers: [
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.only(
//                           top: 100.0, left: 16.0, right: 16.0, bottom: 16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildGlassCard(
//                             title: 'Weather Alerts',
//                             textColor: textColor,
//                             cardBgColor: cardBgColor,
//                             borderColor: borderColor,
//                             children: alerts.isEmpty
//                                 ? [
//                                     Text('No active alerts.',
//                                         style: GoogleFonts.poppins(
//                                             color: textColor))
//                                   ]
//                                 : alerts
//                                     .map((alert) => Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 4.0),
//                                           child: Row(
//                                             children: [
//                                               const Icon(Icons.warning,
//                                                   color: Colors.orange),
//                                               const SizedBox(width: 8),
//                                               Expanded(
//                                                 child: Text(alert,
//                                                     style: GoogleFonts.poppins(
//                                                         color: textColor)),
//                                               ),
//                                             ],
//                                           ),
//                                         ))
//                                     .toList(),
//                           ),
//                           const SizedBox(height: 24),
//                           _buildGlassCard(
//                             title: 'AI Smart Suggestions',
//                             textColor: textColor,
//                             cardBgColor: cardBgColor,
//                             borderColor: borderColor,
//                             children: suggestions.isEmpty
//                                 ? [
//                                     Text('No suggestions.',
//                                         style: GoogleFonts.poppins(
//                                             color: textColor))
//                                   ]
//                                 : suggestions
//                                     .map((s) => Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 4.0),
//                                           child: Row(
//                                             children: [
//                                               const Icon(Icons.lightbulb,
//                                                   color: Colors.yellow),
//                                               const SizedBox(width: 8),
//                                               Expanded(
//                                                 child: Text(s,
//                                                     style: GoogleFonts.poppins(
//                                                         color: textColor)),
//                                               ),
//                                             ],
//                                           ),
//                                         ))
//                                     .toList(),
//                           ),
//                           const SizedBox(height: 24),
//                           _buildGlassCard(
//                             title: 'Custom Alerts',
//                             textColor: textColor,
//                             cardBgColor: cardBgColor,
//                             borderColor: borderColor,
//                             children: customAlerts.isEmpty
//                                 ? [
//                                     Text('No custom alerts yet.',
//                                         style: GoogleFonts.poppins(
//                                             color: textColor))
//                                   ]
//                                 : customAlerts.asMap().entries.map((entry) {
//                                     final index = entry.key;
//                                     final alert = entry.value;
//                                     return Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 4.0),
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               '• ${alert['condition']}',
//                                               style: GoogleFonts.poppins(
//                                                   color: textColor),
//                                             ),
//                                           ),
//                                           IconButton(
//                                             icon: Icon(Icons.delete,
//                                                 color: textColor),
//                                             onPressed: () =>
//                                                 deleteCustomAlert(index),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   }).toList(),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildGlassCard({
//     required String title,
//     required Color textColor,
//     required Color cardBgColor,
//     required Color borderColor,
//     required List<Widget> children,
//   }) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: cardBgColor,
//         border: Border.all(
//           color: borderColor,
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title,
//               style: GoogleFonts.poppins(
//                 color: textColor,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               )),
//           const SizedBox(height: 8),
//           ...children,
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/settings_provider.dart';

class AlertsAndSuggestionsPage extends StatefulWidget {
  final String city;

  const AlertsAndSuggestionsPage({
    super.key,
    required this.city,
  });

  @override
  _AlertsAndSuggestionsPageState createState() =>
      _AlertsAndSuggestionsPageState();
}

class _AlertsAndSuggestionsPageState extends State<AlertsAndSuggestionsPage> {
  final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";
  Map<String, dynamic>? weatherData;
  List<String> alerts = [];
  List<String> suggestions = [];
  List<Map<String, dynamic>> customAlerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCustomAlerts();
    fetchWeather();
  }

  Future<void> loadCustomAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? alertsJson = prefs.getString('custom_alerts');
    if (alertsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(alertsJson);
        setState(() {
          customAlerts = decoded.cast<Map<String, dynamic>>();
        });
      } catch (e) {
        debugPrint('Error loading custom alerts: $e');
      }
    }
  }

  Future<void> saveCustomAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final String alertsJson = json.encode(customAlerts);
    await prefs.setString('custom_alerts', alertsJson);
  }

  Future<void> fetchWeather() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final unit = settings.temperatureUnit == "°C" ? "metric" : "imperial";

    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=${widget.city}&units=$unit&appid=$apiKey",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          generateAlertsAndSuggestions(unit);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch weather data')),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void generateAlertsAndSuggestions(String unit) {
    if (weatherData == null) return;

    final double temp = weatherData!['main']['temp'].toDouble();
    final int humidity = weatherData!['main']['humidity'];
    final double windSpeed = weatherData!['wind']['speed'].toDouble();
    final String weatherMain = weatherData!['weather'][0]['main'].toLowerCase();
    final int clouds = weatherData!['clouds']['all'];

    alerts.clear();
    if (weatherMain.contains('storm')) {
      alerts.add('⚠ Storm alert: Expect thunderstorms in ${widget.city}.');
    }
    if (weatherMain.contains('rain') && temp < 5) {
      alerts.add('⚠ Flood risk: Heavy rain + low temp in ${widget.city}.');
    }
    if ((unit == 'metric' && temp > 35) || (unit == 'imperial' && temp > 95)) {
      alerts.add('⚠ Heatwave alert: Extreme heat in ${widget.city}.');
    }
    if (windSpeed > 20) {
      alerts.add(
          '⚠ High winds: ${windSpeed.toStringAsFixed(1)} ${unit == 'metric' ? 'm/s' : 'mph'} in ${widget.city}.');
    }

    suggestions.clear();
    if (weatherMain.contains('rain')) {
      suggestions.add('Carry an umbrella today.');
    }
    if ((unit == 'metric' && temp > 15 && temp < 25) ||
        (unit == 'imperial' && temp > 59 && temp < 77)) {
      suggestions.add('Great day for running outdoors.');
    }
    if (weatherMain.contains('clear') && clouds < 20) {
      suggestions.add('Use sunscreen, UV index likely high.');
    }
    if (humidity > 70) {
      suggestions.add('Indoor activities recommended (high humidity).');
    }

    if (weatherMain.contains('rain') && customAlerts.isNotEmpty) {
      for (var alert in customAlerts) {
        if (alert['condition'] == 'rain_chance_gt_60') {
          alerts.add(
              '🔔 Custom alert triggered: Rain chance > 60% in ${widget.city}.');
        }
      }
    }
  }

  void addCustomAlert() {
    String condition = '';
    final settings = Provider.of<SettingsProvider>(context, listen: false);
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
      default: // System
        bgColor = const Color.fromARGB(171, 18, 30, 96);
        {}
        textColor = Colors.white;
    }
    final borderColor = textColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(
          'Add Custom Alert',
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
        content: TextField(
          style: GoogleFonts.poppins(color: textColor),
          decoration: InputDecoration(
            labelText: 'Condition (e.g., rain_chance_gt_60)',
            labelStyle: GoogleFonts.poppins(color: textColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: borderColor),
            ),
          ),
          onChanged: (value) => condition = value,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (condition.isNotEmpty) {
                setState(() {
                  customAlerts.add({'condition': condition});
                });
                await saveCustomAlerts();
              }
              Navigator.pop(context);
            },
            child: Text(
              'Add',
              style: GoogleFonts.poppins(color: textColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  void deleteCustomAlert(int index) async {
    setState(() {
      customAlerts.removeAt(index);
    });
    await saveCustomAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    Color bgColor;
    Color textColor;
    Color cardBgColor;
    Color borderColor;

    switch (settings.themeMode) {
      case "Light":
        bgColor = Colors.white;
        textColor = Colors.blue;
        cardBgColor = Colors.white.withOpacity(0.8);
        borderColor = Colors.blue;
        break;
      case "Dark":
        bgColor = Colors.black;
        textColor = Colors.white;
        cardBgColor = Colors.grey[900]!.withOpacity(0.8);
        borderColor = Colors.white;
        break;
      default: // System
        bgColor = Colors.transparent;
        textColor = Colors.white;
        cardBgColor = Colors.white.withOpacity(0.1);
        borderColor = Colors.white.withOpacity(0.2);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Alerts & AI Suggestions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_alert, color: textColor),
            onPressed: addCustomAlert,
          ),
        ],
      ),
      body: Container(
        decoration: settings.themeMode == "System"
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // colors: [Colors.blue, Colors.purple],
                  colors: [
                    Colors.indigo,
                    Colors.deepPurple,
                    Colors.black,
                  ],
                ),
              )
            : BoxDecoration(color: bgColor),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 100.0, left: 16.0, right: 16.0, bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGlassCard(
                            title: 'Weather Alerts',
                            textColor: textColor,
                            cardBgColor: cardBgColor,
                            borderColor: borderColor,
                            children: alerts.isEmpty
                                ? [
                                    Text('No active alerts.',
                                        style: GoogleFonts.poppins(
                                            color: textColor))
                                  ]
                                : alerts
                                    .map((alert) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.warning,
                                                  color: Colors.orange),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(alert,
                                                    style: GoogleFonts.poppins(
                                                        color: textColor)),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                          ),
                          const SizedBox(height: 24),
                          _buildGlassCard(
                            title: 'AI Smart Suggestions',
                            textColor: textColor,
                            cardBgColor: cardBgColor,
                            borderColor: borderColor,
                            children: suggestions.isEmpty
                                ? [
                                    Text('No suggestions.',
                                        style: GoogleFonts.poppins(
                                            color: textColor))
                                  ]
                                : suggestions
                                    .map((s) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.lightbulb,
                                                  color: Colors.yellow),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(s,
                                                    style: GoogleFonts.poppins(
                                                        color: textColor)),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                          ),
                          const SizedBox(height: 24),
                          _buildGlassCard(
                            title: 'Custom Alerts',
                            textColor: textColor,
                            cardBgColor: cardBgColor,
                            borderColor: borderColor,
                            children: customAlerts.isEmpty
                                ? [
                                    Text('No custom alerts yet.',
                                        style: GoogleFonts.poppins(
                                            color: textColor))
                                  ]
                                : customAlerts.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final alert = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '• ${alert['condition']}',
                                              style: GoogleFonts.poppins(
                                                  color: textColor),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: textColor),
                                            onPressed: () =>
                                                deleteCustomAlert(index),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGlassCard({
    required String title,
    required Color textColor,
    required Color cardBgColor,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardBgColor,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
