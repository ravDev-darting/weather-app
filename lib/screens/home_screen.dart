// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:lottie/lottie.dart';
// import 'package:glassmorphism/glassmorphism.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // Screens
// import 'air_quality_screen.dart';
// import 'settings_screen.dart';
// import 'forecast_screen.dart';
// import 'radar_screen.dart';
// import 'alert_screen.dart';
// import 'favorite_screen.dart';

// // Provider
// import '../provider/settings_provider.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // Weather state
//   String _city = "";
//   String _country = "";
//   String _condition = "";
//   String _temperature = "";
//   String _feelsLike = "";
//   String _humidity = "";
//   String _wind = "";
//   String _pressure = "";
//   String? _iconCode;
//   bool _isLoading = true; // Track loading state
//   String? _errorMessage; // Track error message
//   double? _lastLat; // Store last used latitude
//   double? _lastLon; // Store last used longitude

//   List<dynamic> _hourly = [];

//   // AQI + UV state
//   String _aqiStatus = "Loading...";
//   String _uvIndex = "Loading...";

//   // Recent searches
//   final List<String> _recentSearches = [];

//   final String apiKey =
//       "b83f15578b1c0f6507504162e7e2c4c0"; // Replace with your API key

//   @override
//   void initState() {
//     super.initState();
//     _fetchWeatherWithPermission();
//     loadFavoritesCount();

//     // Listen to changes in SettingsProvider
//     final settings = Provider.of<SettingsProvider>(context, listen: false);
//     settings.addListener(_onSettingsChanged);
//   }

//   int favoritesCount = 0;

//   Future<void> loadFavoritesCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       favoritesCount = prefs.getStringList('favourites')?.length ?? 0;
//     });
//   }

//   @override
//   void dispose() {
//     // Remove listener when disposing
//     final settings = Provider.of<SettingsProvider>(context, listen: false);
//     settings.removeListener(_onSettingsChanged);
//     super.dispose();
//   }

//   void _onSettingsChanged() {
//     // Re-fetch weather when units change
//     if (_city.isNotEmpty) {
//       _fetchWeather(city: _city);
//     }
//   }

//   Future<void> _fetchWeatherWithPermission() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     bool serviceEnabled;
//     LocationPermission permission;

//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services disabled, use default city
//       await _fetchWeather(city: "London");
//       return;
//     }

//     // Check location permissions
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Permissions denied, use default city
//         await _fetchWeather(city: "London");
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       // Permissions permanently denied, use default city
//       await _fetchWeather(city: "London");
//       return;
//     }

//     // Permissions granted, fetch weather with geolocation
//     await _fetchWeather();
//   }

//   Future<void> _fetchWeather({String? city}) async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       final settings = Provider.of<SettingsProvider>(context, listen: false);
//       final tempUnit = settings.temperatureUnit;
//       final unit = tempUnit == "°C" ? "metric" : "imperial";

//       String url;
//       Position? pos;

//       if (city != null && city.isNotEmpty) {
//         url =
//             "https://api.openweathermap.org/data/2.5/weather?q=$city&units=$unit&appid=$apiKey";
//       } else {
//         pos = await Geolocator.getCurrentPosition(
//             locationSettings:
//                 const LocationSettings(accuracy: LocationAccuracy.high));
//         url =
//             "https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&units=$unit&appid=$apiKey";
//       }

//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         debugPrint("Weather API response: $data"); // Log response for debugging

//         // Safely convert numeric fields
//         final tempRaw = data['main']['temp'];
//         final feelsLikeRaw = data['main']['feels_like'];
//         final windSpeedRaw = data['wind']['speed'];
//         final pressureValueRaw = data['main']['pressure'];
//         final humidityRaw = data['main']['humidity'];

//         double temp = (tempRaw is num) ? tempRaw.toDouble() : 0.0;
//         double feelsLike =
//             (feelsLikeRaw is num) ? feelsLikeRaw.toDouble() : 0.0;
//         double windSpeed =
//             (windSpeedRaw is num) ? windSpeedRaw.toDouble() : 0.0;
//         double pressureValue =
//             (pressureValueRaw is num) ? pressureValueRaw.toDouble() : 0.0;
//         int humidity = (humidityRaw is num) ? humidityRaw.toInt() : 0;

//         // Convert wind and pressure according to selected units
//         String windDisplay;
//         String pressureDisplay;

//         if (settings.windUnit == "km/h") {
//           windDisplay =
//               "Wind: ${(windSpeed * (unit == "metric" ? 1 : 1.60934)).round()} km/h";
//         } else {
//           windDisplay =
//               "Wind: ${(windSpeed * (unit == "metric" ? 0.621371 : 1)).round()} mph";
//         }

//         if (settings.pressureUnit == "hPa") {
//           pressureDisplay = "Pressure: ${pressureValue.round()} hPa";
//         } else {
//           // Convert hPa to inHg
//           pressureDisplay =
//               "Pressure: ${(pressureValue * 0.029529983071445).toStringAsFixed(2)} inHg";
//         }

//         setState(() {
//           _city = data["name"] ?? "Unknown";
//           _country = data["sys"]["country"] ?? "";
//           _condition = data["weather"][0]["description"] ?? "Unknown";
//           _temperature = "${temp.round()}";
//           _feelsLike = "Feels like: ${feelsLike.round()}";
//           _humidity = "Humidity: $humidity%";
//           _wind = windDisplay;
//           _pressure = pressureDisplay;
//           _iconCode = data['weather'][0]['icon'];
//           _lastLat = data['coord']['lat']?.toDouble() ??
//               pos?.latitude; // Store latitude
//           _lastLon = data['coord']['lon']?.toDouble() ??
//               pos?.longitude; // Store longitude
//           _isLoading = false;
//         });

//         // Forecast (next 6 slots)
//         final forecastUrl =
//             "https://api.openweathermap.org/data/2.5/forecast?q=$_city,$_country&units=$unit&appid=$apiKey";
//         final forecastRes = await http.get(Uri.parse(forecastUrl));
//         if (forecastRes.statusCode == 200) {
//           final forecastData = json.decode(forecastRes.body);
//           debugPrint(
//               "Forecast API response: $forecastData"); // Log forecast response
//           setState(() {
//             _hourly = forecastData["list"].take(6).toList();
//           });
//         }

//         // AQI + UV
//         if (_lastLat != null && _lastLon != null) {
//           _fetchAirQualityAndUV(_lastLat!, _lastLon!, unit);
//         }
//       } else {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = "Failed to load weather data: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = "Error fetching weather: $e";
//       });
//       debugPrint("Weather error: $e");
//     }
//   }

//   Future<void> _fetchAirQualityAndUV(
//       double lat, double lon, String unit) async {
//     try {
//       // 1. AQI
//       final aqiUrl =
//           "https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey";
//       final aqiRes = await http.get(Uri.parse(aqiUrl));
//       if (aqiRes.statusCode == 200) {
//         final aqiData = json.decode(aqiRes.body);
//         int aqi = aqiData['list'][0]['main']['aqi'];
//         setState(() {
//           _aqiStatus = _mapAqiToLabel(aqi);
//         });
//       }

//       // 2. UV Index
//       final uvUrl =
//           "https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,daily,alerts&units=$unit&appid=$apiKey";
//       final uvRes = await http.get(Uri.parse(uvUrl));

//       if (uvRes.statusCode == 200) {
//         final uvData = json.decode(uvRes.body);
//         final raw = uvData['current']['uvi'] ?? 0.0;
//         final uv = (raw is num) ? raw.toDouble() : 0.0;
//         setState(() {
//           _uvIndex = _mapUvToLabel(uv);
//         });
//       } else {
//         setState(() => _uvIndex = "N/A");
//       }
//     } catch (e) {
//       setState(() {
//         _aqiStatus = "Error";
//         _uvIndex = "Error";
//       });
//     }
//   }

//   String _mapAqiToLabel(int aqi) {
//     switch (aqi) {
//       case 1:
//         return "Good 🌿";
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

//   String _mapUvToLabel(double uv) {
//     if (uv < 3) return "Low ($uv) 🟢";
//     if (uv < 6) return "Moderate ($uv) 🟡";
//     if (uv < 8) return "High ($uv) 🟠";
//     if (uv < 11) return "Very High ($uv) 🔴";
//     return "Extreme ($uv) 🟣";
//   }

//   // Color _glowColor(String cond, SettingsProvider settings) {
//   //   final c = cond.toLowerCase();

//   //   // Pick base glow color depending on condition
//   //   Color base;
//   //   if (c.contains("rain")) {
//   //     base = Colors.blueAccent;
//   //   } else if (c.contains("thunder")) {
//   //     base = Colors.deepPurpleAccent;
//   //   } else if (c.contains("snow")) {
//   //     base = Colors.cyanAccent;
//   //   } else if (c.contains("cloud")) {
//   //     base = Colors.grey;
//   //   } else if (c.contains("clear")) {
//   //     base = Colors.orangeAccent;
//   //   } else {
//   //     base = Colors.indigo;
//   //   }

//   //   // Adjust brightness based on theme
//   //   if (settings.themeMode == "Dark") {
//   //     return base.withValues(alpha: 0.8); // Brighter glow on dark bg
//   //   } else {
//   //     return base.withValues(alpha: 0.6); // Softer glow on light/system
//   //   }
//   // }

//   Color _glowColor(String cond, SettingsProvider settings) {
//     final c = cond.toLowerCase();

//     // Pick base glow color depending on condition
//     Color base;
//     if (c.contains("rain")) {
//       base = Colors.blueAccent;
//     } else if (c.contains("thunder")) {
//       base = Colors.deepPurpleAccent;
//     } else if (c.contains("snow")) {
//       base = Colors.cyanAccent;
//     } else if (c.contains("cloud")) {
//       base = Colors.grey;
//     } else if (c.contains("clear")) {
//       base = Colors.orangeAccent;
//     } else {
//       base = Colors.indigo;
//     }

//     if (settings.themeMode == "Dark") {
//       // Much softer for blending with dark background
//       return base.withOpacity(0.2);
//     } else {
//       // Stronger for light/system backgrounds
//       return base.withOpacity(0.2);
//     }
//   }

//   void _showSearchDialog() {
//     final controller = TextEditingController();
//     final settings = Provider.of<SettingsProvider>(context, listen: false);
//     showDialog(
//       context: context,
//       builder: (ctx) => Material(
//         type: MaterialType.transparency,
//         child: Center(
//           child: GlassmorphicContainer(
//             width: MediaQuery.of(context).size.width * 0.9,
//             height: 260,
//             borderRadius: 20,
//             blur: 20,
//             border: 1,
//             alignment: Alignment.center,
//             linearGradient: LinearGradient(
//               colors: [
//                 settings.themeMode == "Light"
//                     ? Colors.white.withAlpha(38)
//                     : Colors.white.withAlpha(38),
//                 settings.themeMode == "Light"
//                     ? Colors.white.withAlpha(13)
//                     : Colors.white.withAlpha(13),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderGradient: LinearGradient(
//               colors: [
//                 settings.themeMode == "Light"
//                     ? Colors.blue.withAlpha(77)
//                     : Colors.white.withAlpha(77),
//                 settings.themeMode == "Light"
//                     ? Colors.blue.withAlpha(26)
//                     : Colors.white.withAlpha(26),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Search City / Country",
//                     style: TextStyle(
//                       color: settings.themeMode == "Light"
//                           ? const Color.fromARGB(255, 255, 255, 255)
//                           : Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextField(
//                     controller: controller,
//                     style: TextStyle(
//                       color: settings.themeMode == "Light"
//                           ? const Color.fromARGB(255, 253, 253, 253)
//                           : Colors.white,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: "e.g. Paris, FR or New York, US",
//                       hintStyle: TextStyle(
//                         color: settings.themeMode == "Light"
//                             ? const Color.fromARGB(255, 252, 253, 253)
//                                 .withOpacity(0.54)
//                             : Colors.white54,
//                       ),
//                       enabledBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(
//                           color: settings.themeMode == "Light"
//                               ? Colors.blue.withOpacity(0.38)
//                               : Colors.white38,
//                         ),
//                       ),
//                       focusedBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(
//                           color: settings.themeMode == "Light"
//                               ? Colors.blue
//                               : Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   if (_recentSearches.isNotEmpty)
//                     SizedBox(
//                       height: 40,
//                       child: ListView(
//                         scrollDirection: Axis.horizontal,
//                         children: _recentSearches
//                             .map((e) => Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(horizontal: 4),
//                                   child: ActionChip(
//                                     label: Text(
//                                       e,
//                                       style: TextStyle(
//                                         color: settings.themeMode == "Light"
//                                             ? Colors.blue
//                                             : const Color.fromARGB(
//                                                 255, 10, 10, 10),
//                                       ),
//                                     ),
//                                     onPressed: () {
//                                       Navigator.pop(ctx);
//                                       _fetchWeather(city: e);
//                                     },
//                                     backgroundColor:
//                                         settings.themeMode == "Light"
//                                             ? Colors.blue.withAlpha(26)
//                                             : Colors.white.withAlpha(26),
//                                   ),
//                                 ))
//                             .toList(),
//                       ),
//                     ),
//                   const SizedBox(height: 12),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (controller.text.trim().isNotEmpty) {
//                         Navigator.pop(ctx);
//                         final city = controller.text.trim();
//                         if (!_recentSearches.contains(city)) {
//                           setState(() {
//                             _recentSearches.insert(0, city);
//                             if (_recentSearches.length > 5) {
//                               _recentSearches.removeLast();
//                             }
//                           });
//                         }
//                         _fetchWeather(city: city);
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               "City is required",
//                               style: TextStyle(
//                                 color: settings.themeMode == "Light"
//                                     ? Colors.white
//                                     : Colors.white,
//                               ),
//                             ),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: settings.themeMode == "Light"
//                           ? Colors.blue.withAlpha(38)
//                           : Colors.white.withAlpha(38),
//                     ),
//                     child: Text(
//                       "Search",
//                       style: TextStyle(
//                         color: settings.themeMode == "Light"
//                             ? Colors.white
//                             : Colors.white,
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String get lottiePath {
//     if (_condition.toLowerCase().contains("cloud")) {
//       return "assets/lottie/cloudy.json";
//     } else if (_condition.toLowerCase().contains("rain")) {
//       return "assets/lottie/rain.json";
//     } else if (_condition.toLowerCase().contains("storm") ||
//         _condition.toLowerCase().contains("thunder")) {
//       return "assets/lottie/storm.json";
//     } else if (_condition.toLowerCase().contains("snow")) {
//       return "assets/lottie/snow.json";
//     } else if (_condition.toLowerCase().contains("clear")) {
//       return "assets/lottie/sunny.json";
//     } else {
//       return "assets/lottie/cloudy.json";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final settings = Provider.of<SettingsProvider>(context);
//     final glow = _glowColor(_condition, settings);

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: Text(
//           "Weather App",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: settings.themeMode == "Light" ? Colors.blue : Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(
//               Icons.search,
//               color: settings.themeMode == "Light" ? Colors.blue : Colors.white,
//             ),
//             onPressed: _showSearchDialog,
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.settings,
//               color: settings.themeMode == "Light" ? Colors.blue : Colors.white,
//             ),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const SettingsScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 700),
//             decoration: BoxDecoration(
//               color: settings.themeMode == "Light"
//                   ? Colors.white
//                   : settings.themeMode == "Dark"
//                       ? Colors.black
//                       : null,
//               gradient: settings.themeMode == "System"
//                   ? LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [glow.withAlpha(46), Colors.black87],
//                     )
//                   : null,
//             ),
//           ),
//           Center(
//             child: Padding(
//               padding: EdgeInsets.only(
//                 top: kToolbarHeight + MediaQuery.of(context).padding.top + 12,
//                 left: 18,
//                 right: 18,
//                 bottom: 18,
//               ),
//               child: GlassmorphicContainer(
//                 width: double.infinity,
//                 height: double.infinity,
//                 borderRadius: 28,
//                 blur: 30,
//                 alignment: Alignment.center,
//                 border: 1,
//                 linearGradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     settings.themeMode == "Light"
//                         ? Colors.blue.withAlpha(31)
//                         : Colors.white.withAlpha(31),
//                     settings.themeMode == "Light"
//                         ? Colors.blue.withAlpha(8)
//                         : Colors.white.withAlpha(8),
//                   ],
//                 ),
//                 borderGradient: LinearGradient(
//                   colors: [
//                     settings.themeMode == "Light"
//                         ? Colors.blue.withAlpha(89)
//                         : Colors.white.withAlpha(89),
//                     settings.themeMode == "Light"
//                         ? Colors.blue.withAlpha(13)
//                         : Colors.white.withAlpha(13),
//                   ],
//                 ),
//                 child: LayoutBuilder(
//                   builder: (context, constraints) {
//                     return SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(
//                           minHeight: constraints.maxHeight,
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(18.0),
//                           child: _isLoading
//                               ? const Center(child: CircularProgressIndicator())
//                               : _errorMessage != null
//                                   ? Center(
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             _errorMessage!,
//                                             style: TextStyle(
//                                               color:
//                                                   settings.themeMode == "Light"
//                                                       ? Colors.blue
//                                                       : Colors.white,
//                                               fontSize: 16,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 16),
//                                           ElevatedButton(
//                                             onPressed:
//                                                 _fetchWeatherWithPermission,
//                                             child: const Text("Retry"),
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   : Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const SizedBox(height: 20),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   "$_city, $_country",
//                                                   style: TextStyle(
//                                                     color: settings.themeMode ==
//                                                             "Light"
//                                                         ? Colors.blue
//                                                         : Colors.white,
//                                                     fontSize: 22,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(height: 6),
//                                                 Text(
//                                                   _condition.isNotEmpty
//                                                       ? _condition[0]
//                                                               .toUpperCase() +
//                                                           _condition
//                                                               .substring(1)
//                                                       : "",
//                                                   style: TextStyle(
//                                                     color: settings.themeMode ==
//                                                             "Light"
//                                                         ? Colors.blue
//                                                             .withOpacity(0.7)
//                                                         : Colors.white70,
//                                                     fontSize: 16,
//                                                     fontStyle: FontStyle.italic,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             if (_iconCode != null)
//                                               Image.network(
//                                                 'https://openweathermap.org/img/wn/${_iconCode!}@2x.png',
//                                                 width: 56,
//                                                 height: 56,
//                                               )
//                                           ],
//                                         ),
//                                         const SizedBox(height: 18),

//                                         // Animation + temp
//                                         SizedBox(
//                                           height: MediaQuery.of(context)
//                                                   .size
//                                                   .height *
//                                               0.3,
//                                           child: Column(
//                                             mainAxisSize: MainAxisSize.min,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Flexible(
//                                                 child: Stack(
//                                                   alignment: Alignment.center,
//                                                   children: [
//                                                     Container(
//                                                       decoration: BoxDecoration(
//                                                         shape: BoxShape.circle,
//                                                         boxShadow: [
//                                                           BoxShadow(
//                                                             color: glow,
//                                                             blurRadius: 50,
//                                                             spreadRadius: 12,
//                                                           )
//                                                         ],
//                                                       ),
//                                                     ),
//                                                     Lottie.asset(
//                                                       lottiePath,
//                                                       fit: BoxFit.contain,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 10),
//                                               Center(
//                                                 child: Text(
//                                                   _temperature +
//                                                       (settings.temperatureUnit ==
//                                                               '°C'
//                                                           ? "°C"
//                                                           : "°F"),
//                                                   style: TextStyle(
//                                                     color: settings.themeMode ==
//                                                             "Light"
//                                                         ? Colors.blue
//                                                         : Colors.white,
//                                                     fontSize: 32,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 12),
//                                               Center(
//                                                 child: Text(
//                                                   "$_feelsLike ${settings.temperatureUnit}",
//                                                   style: TextStyle(
//                                                     color: settings.themeMode ==
//                                                             "Light"
//                                                         ? Colors.blue
//                                                             .withOpacity(0.7)
//                                                         : Colors.white70,
//                                                     fontSize: 14,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),

//                                         const SizedBox(height: 24),

//                                         // Details row
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 8.0),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Expanded(
//                                                 child: Text(
//                                                   _humidity,
//                                                   textAlign: TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: settings.themeMode ==
//                                                             "Light"
//                                                         ? Colors.blue
//                                                             .withOpacity(0.7)
//                                                         : Colors.white70,
//                                                     fontSize: 13,
//                                                   ),
//                                                 ),
//                                               ),
//                                               Expanded(
//                                                 child: Text(
//                                                   _wind,
//                                                   textAlign: TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: settings.themeMode ==
//                                                             "Light"
//                                                         ? Colors.blue
//                                                             .withOpacity(0.7)
//                                                         : Colors.white70,
//                                                     fontSize: 13,
//                                                   ),
//                                                 ),
//                                               ),
//                                               Expanded(
//                                                 child: Text(
//                                                   _pressure,
//                                                   textAlign: TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: settings.themeMode ==
//                                                             "Light"
//                                                         ? Colors.blue
//                                                             .withOpacity(0.7)
//                                                         : Colors.white70,
//                                                     fontSize: 13,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),

//                                         const SizedBox(height: 20),
//                                         // Today timeline
//                                         SizedBox(
//                                           height: 80,
//                                           child: ListView.builder(
//                                             scrollDirection: Axis.horizontal,
//                                             itemCount: _hourly.length,
//                                             itemBuilder: (ctx, i) {
//                                               final h = _hourly[i];
//                                               final dt = DateTime
//                                                   .fromMillisecondsSinceEpoch(
//                                                       h['dt'] * 1000);
//                                               final hour = "${dt.hour}:00";

//                                               final tempValRaw =
//                                                   h['main']['temp'];
//                                               double tempVal =
//                                                   (tempValRaw is num)
//                                                       ? tempValRaw.toDouble()
//                                                       : 0.0;
//                                               if (settings.temperatureUnit ==
//                                                       "°F" &&
//                                                   tempVal < 200) {
//                                                 // Convert from °C to °F if needed
//                                                 tempVal = tempVal * 9 / 5 + 32;
//                                               }

//                                               final temp =
//                                                   "${tempVal.round()}°${settings.temperatureUnit == '°C' ? 'C' : 'F'}";
//                                               final icon =
//                                                   h['weather'][0]['icon'];

//                                               return Container(
//                                                 width: 70,
//                                                 margin: const EdgeInsets.only(
//                                                     right: 8),
//                                                 padding:
//                                                     const EdgeInsets.all(8),
//                                                 decoration: BoxDecoration(
//                                                   color: settings.themeMode ==
//                                                           "Light"
//                                                       ? Colors.blue
//                                                           .withAlpha(20)
//                                                       : Colors.white
//                                                           .withAlpha(20),
//                                                   borderRadius:
//                                                       BorderRadius.circular(16),
//                                                 ),
//                                                 child: Column(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: [
//                                                     Text(
//                                                       hour,
//                                                       style: TextStyle(
//                                                         color: settings
//                                                                     .themeMode ==
//                                                                 "Light"
//                                                             ? Colors.blue
//                                                                 .withOpacity(
//                                                                     0.7)
//                                                             : Colors.white70,
//                                                         fontSize: 12,
//                                                       ),
//                                                     ),
//                                                     Image.network(
//                                                       "https://openweathermap.org/img/wn/$icon.png",
//                                                       width: 28,
//                                                       height: 28,
//                                                     ),
//                                                     Text(
//                                                       temp,
//                                                       style: TextStyle(
//                                                         color:
//                                                             settings.themeMode ==
//                                                                     "Light"
//                                                                 ? Colors.blue
//                                                                 : Colors.white,
//                                                         fontSize: 13,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ),

//                                         const SizedBox(height: 16),

//                                         // Quick cards row
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceEvenly,
//                                           children: [
//                                             Expanded(
//                                               child: _buildQuickCard(
//                                                 "Air Quality",
//                                                 _aqiStatus,
//                                                 Icons.air,
//                                                 onTap: () {
//                                                   Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (_) =>
//                                                           AirQualityScreen(
//                                                         locationName:
//                                                             "$_city, $_country",
//                                                         latitude: _lastLat,
//                                                         longitude: _lastLon,
//                                                       ),
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             ),
//                                             const SizedBox(width: 8),
//                                             Expanded(
//                                               child: _buildQuickCard("UV Index",
//                                                   _uvIndex, Icons.wb_sunny),
//                                             ),
//                                             const SizedBox(width: 8),
//                                             Expanded(
//                                               child: _buildQuickCard(
//                                                 "Favorites",
//                                                 favoritesCount.toString(),
//                                                 Icons.favorite,
//                                                 onTap: () {
//                                                   Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (_) =>
//                                                           const FavouriteScreen(),
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 16),

//                                         // Bottom buttons row
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               bottom: 16.0),
//                                           child: Center(
//                                             child: Wrap(
//                                               alignment: WrapAlignment.center,
//                                               spacing: 8,
//                                               runSpacing: 8,
//                                               children: [
//                                                 ElevatedButton.icon(
//                                                   onPressed: () {
//                                                     final unit = context
//                                                                 .read<
//                                                                     SettingsProvider>()
//                                                                 .temperatureUnit ==
//                                                             "°C"
//                                                         ? "metric"
//                                                         : "imperial";

//                                                     Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (_) =>
//                                                             ForecastScreen(
//                                                                 unit: unit),
//                                                       ),
//                                                     );
//                                                   },
//                                                   style:
//                                                       ElevatedButton.styleFrom(
//                                                     backgroundColor:
//                                                         settings.themeMode ==
//                                                                 "Light"
//                                                             ? Colors.blue
//                                                                 .withAlpha(20)
//                                                             : Colors.white
//                                                                 .withAlpha(20),
//                                                     elevation: 0,
//                                                     shape:
//                                                         RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               14),
//                                                     ),
//                                                   ),
//                                                   icon: Icon(
//                                                     Icons.calendar_today,
//                                                     color: settings.themeMode ==
//                                                             "Light"
//                                                         ? Colors.blue
//                                                         : Colors.white,
//                                                   ),
//                                                   label: Text(
//                                                     "Forecast",
//                                                     style: TextStyle(
//                                                       color:
//                                                           settings.themeMode ==
//                                                                   "Light"
//                                                               ? Colors.blue
//                                                               : Colors.white,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 ElevatedButton.icon(
//                                                   onPressed: () =>
//                                                       Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (_) =>
//                                                           const RadarScreen(),
//                                                     ),
//                                                   ),
//                                                   style:
//                                                       ElevatedButton.styleFrom(
//                                                     backgroundColor:
//                                                         settings.themeMode ==
//                                                                 "Light"
//                                                             ? Colors.blue
//                                                                 .withAlpha(20)
//                                                             : Colors.white
//                                                                 .withAlpha(20),
//                                                     elevation: 0,
//                                                     shape:
//                                                         RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               14),
//                                                     ),
//                                                   ),
//                                                   icon: Icon(
//                                                     Icons.map,
//                                                     color: settings.themeMode ==
//                                                             "Light"
//                                                         ? Colors.blue
//                                                         : Colors.white,
//                                                   ),
//                                                   label: Text(
//                                                     "Radar",
//                                                     style: TextStyle(
//                                                       color:
//                                                           settings.themeMode ==
//                                                                   "Light"
//                                                               ? Colors.blue
//                                                               : Colors.white,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 ElevatedButton.icon(
//                                                   onPressed: () =>
//                                                       Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           AlertsAndSuggestionsPage(
//                                                         city: _city.isNotEmpty
//                                                             ? _city
//                                                             : "London",
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   style:
//                                                       ElevatedButton.styleFrom(
//                                                     backgroundColor:
//                                                         settings.themeMode ==
//                                                                 "Light"
//                                                             ? Colors.blue
//                                                                 .withAlpha(20)
//                                                             : Colors.white
//                                                                 .withAlpha(20),
//                                                     elevation: 0,
//                                                     shape:
//                                                         RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               14),
//                                                     ),
//                                                   ),
//                                                   icon: Icon(
//                                                     Icons.warning,
//                                                     color: settings.themeMode ==
//                                                             "Light"
//                                                         ? Colors.blue
//                                                         : Colors.white,
//                                                   ),
//                                                   label: Text(
//                                                     "Alerts & AI Suggestions",
//                                                     style: TextStyle(
//                                                       color:
//                                                           settings.themeMode ==
//                                                                   "Light"
//                                                               ? Colors.blue
//                                                               : Colors.white,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickCard(String title, String value, IconData icon,
//       {VoidCallback? onTap}) {
//     final settings = Provider.of<SettingsProvider>(context);
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 100,
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: settings.themeMode == "Light"
//               ? Colors.blue.withAlpha(20)
//               : Colors.white.withAlpha(20),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               color: settings.themeMode == "Light" ? Colors.blue : Colors.white,
//             ),
//             const SizedBox(height: 6),
//             Text(
//               title,
//               style: TextStyle(
//                 color: settings.themeMode == "Light"
//                     ? Colors.blue.withOpacity(0.7)
//                     : Colors.white70,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               value,
//               style: TextStyle(
//                 color:
//                     settings.themeMode == "Light" ? Colors.blue : Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import 'air_quality_screen.dart';
import 'settings_screen.dart';
import 'forecast_screen.dart';
import 'radar_screen.dart';
import 'alert_screen.dart';
import 'favorite_screen.dart';

// Provider
import '../provider/settings_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Weather state
  String _city = "";
  String _country = "";
  String _condition = "";
  String _temperature = "";
  String _feelsLike = "";
  String _humidity = "";
  String _wind = "";
  String _pressure = "";
  String? _iconCode;
  bool _isLoading = true; // Track loading state
  String? _errorMessage; // Track error message
  double? _lastLat; // Store last used latitude
  double? _lastLon; // Store last used longitude

  List<dynamic> _hourly = [];

  // AQI + UV state
  String _aqiStatus = "Loading...";
  String _uvIndex = "Loading...";

  // Recent searches
  final List<String> _recentSearches = [];

  final String apiKey =
      "b83f15578b1c0f6507504162e7e2c4c0"; // Replace with your API key

  int favoritesCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchWeatherWithPermission();
    loadFavoritesCount();
    // Listen to changes in SettingsProvider
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.addListener(_onSettingsChanged);
  }

  Future<void> loadFavoritesCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoritesCount = prefs.getStringList('favourites')?.length ?? 0;
    });
  }

  @override
  void dispose() {
    // Remove listener when disposing
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    // Re-fetch weather when units change
    if (_city.isNotEmpty) {
      _fetchWeather(city: _city);
    }
  }

  Future<void> _fetchWeatherWithPermission() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services disabled, use default city
      await _fetchWeather(city: "London");
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions denied, use default city
        await _fetchWeather(city: "London");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions permanently denied, use default city
      await _fetchWeather(city: "London");
      return;
    }

    // Permissions granted, fetch weather with geolocation
    await _fetchWeather();
  }

  Future<void> _fetchWeather({String? city}) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final tempUnit = settings.temperatureUnit;
      final unit = tempUnit == "°C" ? "metric" : "imperial";

      String url;
      Position? pos;

      if (city != null && city.isNotEmpty) {
        url =
            "https://api.openweathermap.org/data/2.5/weather?q=$city&units=$unit&appid=$apiKey";
      } else {
        pos = await Geolocator.getCurrentPosition(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.high));
        url =
            "https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&units=$unit&appid=$apiKey";
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("Weather API response: $data"); // Log response for debugging

        // Safely convert numeric fields
        final tempRaw = data['main']['temp'];
        final feelsLikeRaw = data['main']['feels_like'];
        final windSpeedRaw = data['wind']['speed'];
        final pressureValueRaw = data['main']['pressure'];
        final humidityRaw = data['main']['humidity'];

        double temp = (tempRaw is num) ? tempRaw.toDouble() : 0.0;
        double feelsLike =
            (feelsLikeRaw is num) ? feelsLikeRaw.toDouble() : 0.0;
        double windSpeed =
            (windSpeedRaw is num) ? windSpeedRaw.toDouble() : 0.0;
        double pressureValue =
            (pressureValueRaw is num) ? pressureValueRaw.toDouble() : 0.0;
        int humidity = (humidityRaw is num) ? humidityRaw.toInt() : 0;

        // Convert wind and pressure according to selected units
        String windDisplay;
        String pressureDisplay;

        if (settings.windUnit == "km/h") {
          windDisplay =
              "Wind: ${(windSpeed * (unit == "metric" ? 1 : 1.60934)).round()} km/h";
        } else {
          windDisplay =
              "Wind: ${(windSpeed * (unit == "metric" ? 0.621371 : 1)).round()} mph";
        }

        if (settings.pressureUnit == "hPa") {
          pressureDisplay = "Pressure: ${pressureValue.round()} hPa";
        } else {
          // Convert hPa to inHg
          pressureDisplay =
              "Pressure: ${(pressureValue * 0.029529983071445).toStringAsFixed(2)} inHg";
        }

        setState(() {
          _city = data["name"] ?? "Unknown";
          _country = data["sys"]["country"] ?? "";
          _condition = data["weather"][0]["description"] ?? "Unknown";
          _temperature = "${temp.round()}";
          _feelsLike = "Feels like: ${feelsLike.round()}";
          _humidity = "Humidity: $humidity%";
          _wind = windDisplay;
          _pressure = pressureDisplay;
          _iconCode = data['weather'][0]['icon'];
          _lastLat = data['coord']['lat']?.toDouble() ??
              pos?.latitude; // Store latitude
          _lastLon = data['coord']['lon']?.toDouble() ??
              pos?.longitude; // Store longitude
          _isLoading = false;
        });

        // Forecast (next 6 slots)
        final forecastUrl =
            "https://api.openweathermap.org/data/2.5/forecast?q=$_city,$_country&units=$unit&appid=$apiKey";
        final forecastRes = await http.get(Uri.parse(forecastUrl));
        if (forecastRes.statusCode == 200) {
          final forecastData = json.decode(forecastRes.body);
          debugPrint(
              "Forecast API response: $forecastData"); // Log forecast response
          setState(() {
            _hourly = forecastData["list"].take(6).toList();
          });
        }

        // AQI + UV
        if (_lastLat != null && _lastLon != null) {
          _fetchAirQualityAndUV(_lastLat!, _lastLon!, unit);
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load weather data: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error fetching weather: $e";
      });
      debugPrint("Weather error: $e");
    }
  }

  Future<void> _fetchAirQualityAndUV(
      double lat, double lon, String unit) async {
    try {
      // 1. AQI
      final aqiUrl =
          "https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey";
      final aqiRes = await http.get(Uri.parse(aqiUrl));
      if (aqiRes.statusCode == 200) {
        final aqiData = json.decode(aqiRes.body);
        int aqi = aqiData['list'][0]['main']['aqi'];
        setState(() {
          _aqiStatus = _mapAqiToLabel(aqi);
        });
      }

      // 2. UV Index
      final uvUrl =
          "https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,daily,alerts&units=$unit&appid=$apiKey";
      final uvRes = await http.get(Uri.parse(uvUrl));

      if (uvRes.statusCode == 200) {
        final uvData = json.decode(uvRes.body);
        final raw = uvData['current']['uvi'] ?? 0.0;
        final uv = (raw is num) ? raw.toDouble() : 0.0;
        setState(() {
          _uvIndex = _mapUvToLabel(uv);
        });
      } else {
        setState(() => _uvIndex = "N/A");
      }
    } catch (e) {
      setState(() {
        _aqiStatus = "Error";
        _uvIndex = "Error";
      });
    }
  }

  String _mapAqiToLabel(int aqi) {
    switch (aqi) {
      case 1:
        return "Good 🌿";
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

  String _mapUvToLabel(double uv) {
    if (uv < 3) return "Low ($uv) 🟢";
    if (uv < 6) return "Moderate ($uv) 🟡";
    if (uv < 8) return "High ($uv) 🟠";
    if (uv < 11) return "Very High ($uv) 🔴";
    return "Extreme ($uv) 🟣";
  }

  Color _glowColor(String cond, SettingsProvider settings) {
    final c = cond.toLowerCase();

    // Pick base glow color depending on condition
    Color base;
    if (c.contains("rain")) {
      base = Colors.blueAccent;
    } else if (c.contains("thunder")) {
      base = Colors.deepPurpleAccent;
    } else if (c.contains("snow")) {
      base = Colors.cyanAccent;
    } else if (c.contains("cloud")) {
      base = Colors.grey;
    } else if (c.contains("clear")) {
      base = Colors.orangeAccent;
    } else {
      base = Colors.indigo;
    }

    if (settings.themeMode == "Dark") {
      // Much softer for blending with dark background
      return base.withOpacity(0.2);
    } else {
      // Stronger for light/system backgrounds
      return base.withOpacity(0.2);
    }
  }

  void _showSearchDialog() {
    final controller = TextEditingController();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => Material(
        type: MaterialType.transparency,
        child: Center(
          child: GlassmorphicContainer(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 260,
            borderRadius: 20,
            blur: 20,
            border: 1,
            alignment: Alignment.center,
            linearGradient: LinearGradient(
              colors: [
                settings.themeMode == "Light"
                    ? Colors.white.withAlpha(38)
                    : Colors.white.withAlpha(38),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderGradient: LinearGradient(
              colors: [
                settings.themeMode == "Light"
                    ? Colors.blue.withAlpha(77)
                    : Colors.white.withAlpha(77),
                settings.themeMode == "Light"
                    ? Colors.blue.withAlpha(26)
                    : Colors.white.withAlpha(26),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Search City / Country",
                    style: TextStyle(
                      color: settings.themeMode == "Light"
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    style: TextStyle(
                      color: settings.themeMode == "Light"
                          ? const Color.fromARGB(255, 253, 253, 253)
                          : Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: "e.g. Paris, FR or New York, US",
                      hintStyle: TextStyle(
                        color: settings.themeMode == "Light"
                            ? const Color.fromARGB(255, 252, 253, 253)
                                .withOpacity(0.54)
                            : Colors.white54,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: settings.themeMode == "Light"
                              ? Colors.blue.withOpacity(0.38)
                              : Colors.white38,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: settings.themeMode == "Light"
                              ? Colors.blue
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_recentSearches.isNotEmpty)
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _recentSearches
                            .map((e) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: ActionChip(
                                    label: Text(
                                      e,
                                      style: TextStyle(
                                        color: settings.themeMode == "Light"
                                            ? Colors.blue
                                            : const Color.fromARGB(
                                                255, 10, 10, 10),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _fetchWeather(city: e);
                                    },
                                    backgroundColor:
                                        settings.themeMode == "Light"
                                            ? Colors.blue.withAlpha(26)
                                            : Colors.white.withAlpha(26),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        Navigator.pop(ctx);
                        final city = controller.text.trim();
                        if (!_recentSearches.contains(city)) {
                          setState(() {
                            _recentSearches.insert(0, city);
                            if (_recentSearches.length > 5) {
                              _recentSearches.removeLast();
                            }
                          });
                        }
                        _fetchWeather(city: city);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "City is required",
                              style: TextStyle(
                                color: settings.themeMode == "Light"
                                    ? Colors.white
                                    : Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: settings.themeMode == "Light"
                          ? Colors.blue.withAlpha(38)
                          : Colors.white.withAlpha(38),
                    ),
                    child: Text(
                      "Search",
                      style: TextStyle(
                        color: settings.themeMode == "Light"
                            ? Colors.white
                            : Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get lottiePath {
    if (_condition.toLowerCase().contains("cloud")) {
      return "assets/lottie/cloudy.json";
    } else if (_condition.toLowerCase().contains("rain")) {
      return "assets/lottie/rain.json";
    } else if (_condition.toLowerCase().contains("storm") ||
        _condition.toLowerCase().contains("thunder")) {
      return "assets/lottie/thunder.json";
    } else if (_condition.toLowerCase().contains("snow")) {
      return "assets/lottie/snow.json";
    } else if (_condition.toLowerCase().contains("clear")) {
      return "assets/lottie/sunny.json";
    } else if (_condition.toLowerCase().contains("fog") ||
        _condition.toLowerCase().contains("mist")) {
      return "assets/lottie/fog.json";
    } else {
      return "assets/lottie/cloudy.json";
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final glow = _glowColor(_condition, settings);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: settings.themeMode == "Light" ? Colors.blue : Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: settings.themeMode == "Light" ? Colors.blue : Colors.white,
            ),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: settings.themeMode == "Light" ? Colors.blue : Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            decoration: BoxDecoration(
              color: settings.themeMode == "Light"
                  ? Colors.white
                  : settings.themeMode == "Dark"
                      ? Colors.black
                      : null,
              gradient: settings.themeMode == "System"
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [glow.withAlpha(46), Colors.black87],
                    )
                  : null,
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.of(context).padding.top + 12,
                left: 18,
                right: 18,
                bottom: 18,
              ),
              child: GlassmorphicContainer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 28,
                blur: 30,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    settings.themeMode == "Light"
                        ? Colors.blue.withAlpha(31)
                        : Colors.white.withAlpha(31),
                    settings.themeMode == "Light"
                        ? Colors.blue.withAlpha(8)
                        : Colors.white.withAlpha(8),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    settings.themeMode == "Light"
                        ? Colors.blue.withAlpha(89)
                        : Colors.white.withAlpha(89),
                    settings.themeMode == "Light"
                        ? Colors.blue.withAlpha(13)
                        : Colors.white.withAlpha(13),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _errorMessage != null
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _errorMessage!,
                                            style: TextStyle(
                                              color:
                                                  settings.themeMode == "Light"
                                                      ? Colors.blue
                                                      : Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed:
                                                _fetchWeatherWithPermission,
                                            child: const Text("Retry"),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "$_city, $_country",
                                                  style: TextStyle(
                                                    color: settings.themeMode ==
                                                            "Light"
                                                        ? Colors.blue
                                                        : Colors.white,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  _condition.isNotEmpty
                                                      ? _condition[0]
                                                              .toUpperCase() +
                                                          _condition
                                                              .substring(1)
                                                      : "",
                                                  style: TextStyle(
                                                    color: settings.themeMode ==
                                                            "Light"
                                                        ? Colors.blue
                                                            .withOpacity(0.7)
                                                        : Colors.white70,
                                                    fontSize: 16,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (_iconCode != null)
                                              Image.network(
                                                'https://openweathermap.org/img/wn/${_iconCode!}@2x.png',
                                                width: 56,
                                                height: 56,
                                              )
                                          ],
                                        ),
                                        const SizedBox(height: 18),

                                        // Animation + temp
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: glow,
                                                            blurRadius: 50,
                                                            spreadRadius: 12,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Lottie.asset(
                                                      lottiePath,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Center(
                                                child: Text(
                                                  _temperature +
                                                      (settings.temperatureUnit ==
                                                              '°C'
                                                          ? "°C"
                                                          : "°F"),
                                                  style: TextStyle(
                                                    color: settings.themeMode ==
                                                            "Light"
                                                        ? Colors.blue
                                                        : Colors.white,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Center(
                                                child: Text(
                                                  "$_feelsLike ${settings.temperatureUnit}",
                                                  style: TextStyle(
                                                    color: settings.themeMode ==
                                                            "Light"
                                                        ? Colors.blue
                                                            .withOpacity(0.7)
                                                        : Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 24),

                                        // Details row
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _humidity,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: settings.themeMode ==
                                                            "Light"
                                                        ? Colors.blue
                                                            .withOpacity(0.7)
                                                        : Colors.white70,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  _wind,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: settings.themeMode ==
                                                            "Light"
                                                        ? Colors.blue
                                                            .withOpacity(0.7)
                                                        : Colors.white70,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  _pressure,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: settings.themeMode ==
                                                            "Light"
                                                        ? Colors.blue
                                                            .withOpacity(0.7)
                                                        : Colors.white70,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 20),
                                        // Today timeline
                                        SizedBox(
                                          height: 80,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _hourly.length,
                                            itemBuilder: (ctx, i) {
                                              final h = _hourly[i];
                                              final dt = DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      h['dt'] * 1000);
                                              final hour = "${dt.hour}:00";

                                              final tempValRaw =
                                                  h['main']['temp'];
                                              double tempVal =
                                                  (tempValRaw is num)
                                                      ? tempValRaw.toDouble()
                                                      : 0.0;
                                              if (settings.temperatureUnit ==
                                                      "°F" &&
                                                  tempVal < 200) {
                                                // Convert from °C to °F if needed
                                                tempVal = tempVal * 9 / 5 + 32;
                                              }

                                              final temp =
                                                  "${tempVal.round()}°${settings.temperatureUnit == '°C' ? 'C' : 'F'}";
                                              final icon =
                                                  h['weather'][0]['icon'];

                                              return Container(
                                                width: 70,
                                                margin: const EdgeInsets.only(
                                                    right: 8),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: settings.themeMode ==
                                                          "Light"
                                                      ? Colors.blue
                                                          .withAlpha(20)
                                                      : Colors.white
                                                          .withAlpha(20),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      hour,
                                                      style: TextStyle(
                                                        color: settings
                                                                    .themeMode ==
                                                                "Light"
                                                            ? Colors.blue
                                                                .withOpacity(
                                                                    0.7)
                                                            : Colors.white70,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    Image.network(
                                                      "https://openweathermap.org/img/wn/$icon.png",
                                                      width: 28,
                                                      height: 28,
                                                    ),
                                                    Text(
                                                      temp,
                                                      style: TextStyle(
                                                        color:
                                                            settings.themeMode ==
                                                                    "Light"
                                                                ? Colors.blue
                                                                : Colors.white,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        // Quick cards row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              child: _buildQuickCard(
                                                "Air Quality",
                                                _aqiStatus,
                                                Icons.air,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AirQualityScreen(
                                                        locationName:
                                                            "$_city, $_country",
                                                        latitude: _lastLat,
                                                        longitude: _lastLon,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: _buildQuickCard("UV Index",
                                                  _uvIndex, Icons.wb_sunny),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: _buildQuickCard(
                                                "Favorites",
                                                favoritesCount.toString(),
                                                Icons.favorite,
                                                onTap: () async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const FavouriteScreen(),
                                                    ),
                                                  );
                                                  loadFavoritesCount();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        // Bottom buttons row
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 16.0),
                                          child: Center(
                                            child: Wrap(
                                              alignment: WrapAlignment.center,
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    final unit = context
                                                                .read<
                                                                    SettingsProvider>()
                                                                .temperatureUnit ==
                                                            "°C"
                                                        ? "metric"
                                                        : "imperial";

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            ForecastScreen(
                                                                unit: unit),
                                                      ),
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        settings.themeMode ==
                                                                "Light"
                                                            ? Colors.blue
                                                                .withAlpha(20)
                                                            : Colors.white
                                                                .withAlpha(20),
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                    ),
                                                  ),
                                                  icon: Icon(
                                                    Icons.calendar_today,
                                                    color: settings.themeMode ==
                                                            "Light"
                                                        ? Colors.blue
                                                        : Colors.white,
                                                  ),
                                                  label: Text(
                                                    "Forecast",
                                                    style: TextStyle(
                                                      color:
                                                          settings.themeMode ==
                                                                  "Light"
                                                              ? Colors.blue
                                                              : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton.icon(
                                                  onPressed: () =>
                                                      Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const RadarScreen(),
                                                    ),
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        settings.themeMode ==
                                                                "Light"
                                                            ? Colors.blue
                                                                .withAlpha(20)
                                                            : Colors.white
                                                                .withAlpha(20),
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                    ),
                                                  ),
                                                  icon: Icon(
                                                    Icons.map,
                                                    color: settings.themeMode ==
                                                            "Light"
                                                        ? Colors.blue
                                                        : Colors.white,
                                                  ),
                                                  label: Text(
                                                    "Radar",
                                                    style: TextStyle(
                                                      color:
                                                          settings.themeMode ==
                                                                  "Light"
                                                              ? Colors.blue
                                                              : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton.icon(
                                                  onPressed: () =>
                                                      Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AlertsAndSuggestionsPage(
                                                        city: _city.isNotEmpty
                                                            ? _city
                                                            : "London",
                                                      ),
                                                    ),
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        settings.themeMode ==
                                                                "Light"
                                                            ? Colors.blue
                                                                .withAlpha(20)
                                                            : Colors.white
                                                                .withAlpha(20),
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                    ),
                                                  ),
                                                  icon: Icon(
                                                    Icons.warning,
                                                    color: settings.themeMode ==
                                                            "Light"
                                                        ? Colors.blue
                                                        : Colors.white,
                                                  ),
                                                  label: Text(
                                                    "Alerts & AI Suggestions",
                                                    style: TextStyle(
                                                      color:
                                                          settings.themeMode ==
                                                                  "Light"
                                                              ? Colors.blue
                                                              : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard(String title, String value, IconData icon,
      {VoidCallback? onTap}) {
    final settings = Provider.of<SettingsProvider>(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: settings.themeMode == "Light"
              ? Colors.blue.withAlpha(20)
              : Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: settings.themeMode == "Light" ? Colors.blue : Colors.white,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: settings.themeMode == "Light"
                    ? Colors.blue.withOpacity(0.7)
                    : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color:
                    settings.themeMode == "Light" ? Colors.blue : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
