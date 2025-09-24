// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// // import 'package:glassmorphism/glassmorphism.dart';
// import 'package:lottie/lottie.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../provider/settings_provider.dart';

// class FavouriteScreen extends StatefulWidget {
//   const FavouriteScreen({super.key});

//   @override
//   _FavouriteScreenState createState() => _FavouriteScreenState();
// }

// class _FavouriteScreenState extends State<FavouriteScreen> {
//   List<String> favourites = [];
//   List<Map<String, dynamic>> weatherDataList = [];
//   bool isLoading = true;
//   final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";

//   @override
//   void initState() {
//     super.initState();
//     loadFavourites();
//   }

//   Future<void> loadFavourites() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       favourites = prefs.getStringList('favourites') ?? [];
//     });
//     await fetchWeathers();
//     setState(() {
//       isLoading = false;
//     });
//   }

//   Future<void> saveFavourites() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('favourites', favourites);
//   }

//   Future<void> fetchWeathers() async {
//     final settings = Provider.of<SettingsProvider>(context, listen: false);
//     final unit = settings.temperatureUnit == "°C" ? "metric" : "imperial";
//     weatherDataList.clear();

//     final futures = favourites.map((city) async {
//       return await fetchSingleWeather(city, unit);
//     }).toList();

//     final results = await Future.wait(futures);
//     weatherDataList = results.whereType<Map<String, dynamic>>().toList();
//   }

//   Future<Map<String, dynamic>?> fetchSingleWeather(
//       String city, String unit) async {
//     final url = Uri.parse(
//       "https://api.openweathermap.org/data/2.5/weather?q=$city&units=$unit&appid=$apiKey",
//     );
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return {
//           'city': city,
//           'temp': data['main']['temp'].toDouble().round(),
//           'condition': data['weather'][0]['main'],
//           'icon': data['weather'][0]['icon'],
//           'country': data['sys']['country'],
//           'humidity': data['main']['humidity'],
//           'wind_speed': data['wind']['speed'],
//         };
//       }
//     } catch (e) {
//       // handle silently
//     }
//     return null;
//   }

//   String getLottiePath(String condition) {
//     final cond = condition.toLowerCase();
//     if (cond.contains('clear')) return 'assets/lottie/sunny.json';
//     if (cond.contains('rain')) return 'assets/lottie/rain.json';
//     if (cond.contains('thunderstorm')) return 'assets/lottie/thunder.json';
//     if (cond.contains('snow')) return 'assets/lottie/snow.json';
//     if (cond.contains('cloud')) return 'assets/lottie/cloudy.json';
//     if (cond.contains('fog') || cond.contains('mist')) {
//       return 'assets/lottie/fog.json';
//     }
//     return 'assets/lottie/cloudy.json';
//   }

//   String getConditionEmoji(String condition) {
//     final cond = condition.toLowerCase();
//     if (cond == 'clear') return '☀️';
//     if (cond == 'clouds') return '☁️';
//     if (cond == 'rain') return '🌧️';
//     if (cond == 'thunderstorm') return '⛈️';
//     if (cond == 'snow') return '❄️';
//     if (cond == 'mist' || cond == 'fog') return '🌫️';
//     return '🌤';
//   }

//   String getWeatherSuggestion(String condition) {
//     final cond = condition.toLowerCase();
//     if (cond.contains('clear')) {
//       return 'Enjoy the sunshine! Great day for outdoor activities like picnics or sports.';
//     } else if (cond.contains('cloud')) {
//       return 'Mild and cloudy weather. Perfect for a casual walk or reading outside.';
//     } else if (cond.contains('rain')) {
//       return 'Stay dry! Consider indoor activities like reading a book or watching a movie.';
//     } else if (cond.contains('thunderstorm')) {
//       return 'Stay safe indoors. Avoid outdoor activities and unplug electronics if needed.';
//     } else if (cond.contains('snow')) {
//       return 'Bundle up! Time for winter fun like skiing or building a snowman.';
//     } else if (cond.contains('fog') || cond.contains('mist')) {
//       return 'Visibility is low. Be cautious while driving or walking outdoors.';
//     } else {
//       return 'Check the weather details and plan your day accordingly.';
//     }
//   }

//   void addFavourite() {
//     final controller = TextEditingController();
//     final settings = Provider.of<SettingsProvider>(context, listen: false);

//     Color textColor;
//     Color dialogBgColor;
//     Color addButtonColor;
//     Color cancelButtonColor;

//     switch (settings.themeMode) {
//       case "Light":
//         textColor = Colors.white;
//         dialogBgColor = const Color.fromARGB(255, 55, 161, 247);
//         addButtonColor = Colors.blue;
//         cancelButtonColor = const Color.fromARGB(179, 231, 229, 229);
//         break;
//       case "Dark":
//         textColor = Colors.black;
//         dialogBgColor = Colors.white;
//         addButtonColor = Colors.white;
//         cancelButtonColor = Colors.grey[700]!;
//         break;
//       default: // System
//         textColor = Colors.white;
//         // dialogBgColor = const Color.fromARGB(0, 239, 229, 229);
//         dialogBgColor = const Color.fromARGB(255, 112, 133, 253);
//         addButtonColor = Colors.indigo.withOpacity(0.8);
//         cancelButtonColor = Colors.deepPurple.withOpacity(0.8);
//     }

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: dialogBgColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           "Add Favourite Location",
//           style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
//         ),
//         content: TextField(
//           controller: controller,
//           style: TextStyle(color: textColor),
//           decoration: InputDecoration(
//             labelText: "City Name",
//             labelStyle: TextStyle(color: textColor),
//             enabledBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: textColor.withOpacity(0.5)),
//             ),
//             focusedBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: textColor),
//             ),
//           ),
//         ),
//         actions: [
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: addButtonColor),
//             onPressed: () async {
//               final city = controller.text.trim();
//               if (city.isNotEmpty && !favourites.contains(city)) {
//                 setState(() {
//                   favourites.add(city);
//                   isLoading = true;
//                 });
//                 await saveFavourites();
//                 final unit =
//                     settings.temperatureUnit == "°C" ? "metric" : "imperial";
//                 final data = await fetchSingleWeather(city, unit);
//                 setState(() {
//                   isLoading = false;
//                 });
//                 if (data != null) {
//                   setState(() {
//                     weatherDataList.add(data);
//                   });
//                 } else {
//                   setState(() {
//                     favourites.remove(city);
//                   });
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text('Failed to fetch weather for city')),
//                   );
//                 }
//               }
//               Navigator.pop(ctx);
//             },
//             child: Text("Add", style: TextStyle(color: textColor)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: cancelButtonColor),
//             onPressed: () => Navigator.pop(ctx),
//             child: Text("Cancel", style: TextStyle(color: textColor)),
//           ),
//         ],
//       ),
//     );
//   }

//   void removeFavourite(String city) async {
//     setState(() {
//       favourites.remove(city);
//       weatherDataList.removeWhere((data) => data['city'] == city);
//     });
//     await saveFavourites();
//   }

//   void showWeatherDetails(
//       BuildContext context, Map<String, dynamic> data, Color textColor) {
//     final settings = Provider.of<SettingsProvider>(context, listen: false);
//     final unitSymbol = settings.temperatureUnit;
//     final windUnit = settings.temperatureUnit == "°C" ? "m/s" : "mph";
//     final suggestion = getWeatherSuggestion(data['condition']);
//     final conditionEmoji = getConditionEmoji(data['condition']);

//     Color dialogBgColor;
//     Color dialogTextColor;
//     BorderSide dialogBorderSide;

//     switch (settings.themeMode) {
//       case "Light":
//         dialogBgColor = Colors.white;
//         dialogTextColor = Colors.blue;
//         dialogBorderSide = BorderSide.none;
//         break;
//       case "Dark":
//         dialogBgColor = Colors.black;
//         dialogTextColor = Colors.white;
//         dialogBorderSide = const BorderSide(color: Colors.white);
//         break;
//       default: // System
//         dialogBgColor = Colors.indigo.withOpacity(0.9);
//         dialogTextColor = Colors.white;
//         dialogBorderSide = BorderSide.none;
//     }

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: dialogBgColor,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: dialogBorderSide,
//         ),
//         title: Text(
//           "${data['city']}, ${data['country'] ?? ''}",
//           style: TextStyle(color: dialogTextColor, fontWeight: FontWeight.bold),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: 100,
//               height: 100,
//               child: Lottie.asset(getLottiePath(data['condition']),
//                   fit: BoxFit.contain),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 const Text('🌡️ ', style: TextStyle(fontSize: 18)),
//                 Text("Temperature: ${data['temp']}$unitSymbol",
//                     style: TextStyle(color: dialogTextColor, fontSize: 18)),
//               ],
//             ),
//             Row(
//               children: [
//                 Text('$conditionEmoji ', style: const TextStyle(fontSize: 16)),
//                 Text("Condition: ${data['condition']}",
//                     style: TextStyle(color: dialogTextColor, fontSize: 16)),
//               ],
//             ),
//             Row(
//               children: [
//                 const Text('💧 ', style: TextStyle(fontSize: 16)),
//                 Text("Humidity: ${data['humidity']}%",
//                     style: TextStyle(color: dialogTextColor, fontSize: 16)),
//               ],
//             ),
//             Row(
//               children: [
//                 const Text('🌬️ ', style: TextStyle(fontSize: 16)),
//                 Text(
//                     "Wind Speed: ${data['wind_speed'].toStringAsFixed(1)} $windUnit",
//                     style: TextStyle(color: dialogTextColor, fontSize: 16)),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 const Text('💡 ', style: TextStyle(fontSize: 16)),
//                 Text("AI Suggestion:",
//                     style: TextStyle(
//                         color: dialogTextColor,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//             Text(suggestion,
//                 style: TextStyle(color: dialogTextColor, fontSize: 14)),
//           ],
//         ),
//         actions: [
//           TextButton(
//             style: TextButton.styleFrom(foregroundColor: dialogTextColor),
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("Close"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final settings = Provider.of<SettingsProvider>(context);

//     Color bgColor;
//     Color textColor;
//     Color cardBgColor;
//     Color borderColor;

//     const bgGradient = LinearGradient(
//       colors: [
//         Colors.indigo,
//         Colors.deepPurple,
//       ],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     );

//     switch (settings.themeMode) {
//       case "Light":
//         bgColor = Colors.white;
//         textColor = Colors.blue;
//         cardBgColor = Colors.white;
//         borderColor = Colors.blue;
//         break;
//       case "Dark":
//         bgColor = Colors.black;
//         textColor = Colors.white;
//         cardBgColor = Colors.black;
//         borderColor = Colors.white;
//         break;
//       default: // System
//         bgColor = Colors.transparent;
//         textColor = Colors.white;
//         cardBgColor = Colors.white.withOpacity(0.1);
//         borderColor = Colors.white.withOpacity(0.2);
//     }

//     final decoration = settings.themeMode == "System"
//         ? const BoxDecoration(gradient: bgGradient)
//         : BoxDecoration(color: bgColor);

//     Widget bodyContent;
//     if (isLoading) {
//       bodyContent = const Center(child: CircularProgressIndicator());
//     } else if (favourites.isEmpty) {
//       bodyContent = Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("No favourites yet",
//                 style: TextStyle(color: textColor, fontSize: 18)),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: addFavourite,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: settings.themeMode == "System"
//                     ? Colors.indigo.withOpacity(0.8)
//                     : borderColor.withOpacity(0.2),
//               ),
//               child: Text("Add Location", style: TextStyle(color: textColor)),
//             ),
//           ],
//         ),
//       );
//     } else {
//       final listView = ListView.builder(
//         padding:
//             const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 16),
//         itemCount: weatherDataList.length,
//         itemBuilder: (context, index) {
//           final data = weatherDataList[index];
//           final itemWidget = Card(
//             color: cardBgColor,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//               side: BorderSide(color: borderColor),
//             ),
//             elevation: 4,
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: _buildItemContent(data, textColor),
//             ),
//           );

//           return Dismissible(
//             key: Key(data['city']),
//             direction: DismissDirection.endToStart,
//             background: Container(
//               color: Colors.red,
//               alignment: Alignment.centerRight,
//               padding: const EdgeInsets.only(right: 20),
//               child: const Icon(Icons.delete, color: Colors.white),
//             ),
//             onDismissed: (_) => removeFavourite(data['city']),
//             child: GestureDetector(
//               onTap: () {
//                 showWeatherDetails(context, data, textColor);
//               },
//               child: itemWidget,
//             ),
//           );
//         },
//       );

//       bodyContent = listView;
//     }

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: Text("Favourites",
//             style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add, color: textColor),
//             onPressed: addFavourite,
//           ),
//         ],
//       ),
//       body: Container(decoration: decoration, child: bodyContent),
//     );
//   }

//   Widget _buildItemContent(Map<String, dynamic> data, Color textColor) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         // Left block
//         Flexible(
//           child: Row(
//             children: [
//               Icon(Icons.location_city, color: textColor),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("${data['city']}, ${data['country'] ?? ''}",
//                       style: TextStyle(
//                           color: textColor,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Text(getConditionEmoji(data['condition']),
//                           style: const TextStyle(fontSize: 16)),
//                       const SizedBox(width: 4),
//                       Text(data['condition'],
//                           style: TextStyle(
//                               color: textColor.withOpacity(0.7), fontSize: 14)),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text("Humidity: ${data['humidity']}%",
//                       style: TextStyle(
//                           color: textColor.withOpacity(0.7), fontSize: 12)),
//                   Text("Wind: ${data['wind_speed'].toStringAsFixed(1)} m/s",
//                       style: TextStyle(
//                           color: textColor.withOpacity(0.7), fontSize: 12)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         // Right block
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               children: [
//                 const Text("🌡 ", style: TextStyle(fontSize: 16)),
//                 Text("${data['temp']}°",
//                     style: TextStyle(color: textColor, fontSize: 16)),
//               ],
//             ),
//             const SizedBox(height: 8),
//             SizedBox(
//               width: 40,
//               height: 40,
//               child: Lottie.asset(getLottiePath(data['condition']),
//                   fit: BoxFit.contain),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/settings_provider.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  List<String> favourites = [];
  List<Map<String, dynamic>> weatherDataList = [];
  bool isLoading = true;
  final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0";

  @override
  void initState() {
    super.initState();
    loadFavourites();
  }

  Future<void> loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favourites = prefs.getStringList('favourites') ?? [];
    });
    await fetchWeathers();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favourites', favourites);
  }

  Future<void> fetchWeathers() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final unit = settings.temperatureUnit == "°C" ? "metric" : "imperial";
    weatherDataList.clear();

    final futures = favourites.map((city) async {
      return await fetchSingleWeather(city, unit);
    }).toList();

    final results = await Future.wait(futures);
    weatherDataList = results.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>?> fetchSingleWeather(
      String city, String unit) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&units=$unit&appid=$apiKey",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'city': city,
          'temp': data['main']['temp'].toDouble().round(),
          'condition': data['weather'][0]['main'],
          'icon': data['weather'][0]['icon'],
          'country': data['sys']['country'],
          'humidity': data['main']['humidity'],
          'wind_speed': data['wind']['speed'],
        };
      }
    } catch (e) {
      // handle silently
    }
    return null;
  }

  String getLottiePath(String condition) {
    final cond = condition.toLowerCase();
    if (cond.contains('clear')) return 'assets/lottie/sunny.json';
    if (cond.contains('rain')) return 'assets/lottie/rain.json';
    if (cond.contains('thunderstorm')) return 'assets/lottie/thunder.json';
    if (cond.contains('snow')) return 'assets/lottie/snow.json';
    if (cond.contains('cloud')) return 'assets/lottie/cloudy.json';
    if (cond.contains('fog') || cond.contains('mist')) {
      return 'assets/lottie/fog.json';
    }
    return 'assets/lottie/cloudy.json';
  }

  String getConditionEmoji(String condition) {
    final cond = condition.toLowerCase();
    if (cond == 'clear') return '☀️';
    if (cond == 'clouds') return '☁️';
    if (cond == 'rain') return '🌧️';
    if (cond == 'thunderstorm') return '⛈️';
    if (cond == 'snow') return '❄️';
    if (cond == 'mist' || cond == 'fog') return '🌫️';
    return '🌤';
  }

  String getWeatherSuggestion(String condition) {
    final cond = condition.toLowerCase();
    if (cond.contains('clear')) {
      return 'Enjoy the sunshine! Great day for outdoor activities like picnics or sports.';
    } else if (cond.contains('cloud')) {
      return 'Mild and cloudy weather. Perfect for a casual walk or reading outside.';
    } else if (cond.contains('rain')) {
      return 'Stay dry! Consider indoor activities like reading a book or watching a movie.';
    } else if (cond.contains('thunderstorm')) {
      return 'Stay safe indoors. Avoid outdoor activities and unplug electronics if needed.';
    } else if (cond.contains('snow')) {
      return 'Bundle up! Time for winter fun like skiing or building a snowman.';
    } else if (cond.contains('fog') || cond.contains('mist')) {
      return 'Visibility is low. Be cautious while driving or walking outdoors.';
    } else {
      return 'Check the weather details and plan your day accordingly.';
    }
  }

  void addFavourite() {
    final controller = TextEditingController();
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    Color textColor;
    Color dialogBgColor;
    Color addButtonColor;
    Color cancelButtonColor;

    switch (settings.themeMode) {
      case "Light":
        textColor = Colors.white;
        dialogBgColor = const Color.fromARGB(255, 55, 161, 247);
        addButtonColor = Colors.blue;
        cancelButtonColor = const Color.fromARGB(179, 231, 229, 229);
        break;
      case "Dark":
        textColor = Colors.black;
        dialogBgColor = Colors.white;
        addButtonColor = Colors.white;
        cancelButtonColor = Colors.grey[700]!;
        break;
      default: // System
        textColor = Colors.white;
        // dialogBgColor = const Color.fromARGB(0, 239, 229, 229);
        dialogBgColor = const Color.fromARGB(255, 112, 133, 253);
        addButtonColor = Colors.indigo.withOpacity(0.8);
        cancelButtonColor = Colors.deepPurple.withOpacity(0.8);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Add Favourite Location",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: "City Name",
            labelStyle: TextStyle(color: textColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: textColor.withOpacity(0.5)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: textColor),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: addButtonColor),
            onPressed: () async {
              final city = controller.text.trim();
              if (city.isNotEmpty && !favourites.contains(city)) {
                setState(() {
                  favourites.add(city);
                  isLoading = true;
                });
                await saveFavourites();
                final unit =
                    settings.temperatureUnit == "°C" ? "metric" : "imperial";
                final data = await fetchSingleWeather(city, unit);
                setState(() {
                  isLoading = false;
                });
                if (data != null) {
                  setState(() {
                    weatherDataList.add(data);
                  });
                } else {
                  setState(() {
                    favourites.remove(city);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to fetch weather for city')),
                  );
                }
              }
              Navigator.pop(ctx);
            },
            child: Text("Add", style: TextStyle(color: textColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: cancelButtonColor),
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  void removeFavourite(String city) async {
    setState(() {
      favourites.remove(city);
      weatherDataList.removeWhere((data) => data['city'] == city);
    });
    await saveFavourites();
  }

  void showWeatherDetails(
      BuildContext context, Map<String, dynamic> data, Color textColor) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final unitSymbol = settings.temperatureUnit;
    final windUnit = settings.temperatureUnit == "°C" ? "m/s" : "mph";
    final suggestion = getWeatherSuggestion(data['condition']);
    final conditionEmoji = getConditionEmoji(data['condition']);

    Color dialogBgColor;
    Color dialogTextColor;
    BorderSide dialogBorderSide;

    switch (settings.themeMode) {
      case "Light":
        dialogBgColor = Colors.white;
        dialogTextColor = Colors.blue;
        dialogBorderSide = BorderSide.none;
        break;
      case "Dark":
        dialogBgColor = Colors.black;
        dialogTextColor = Colors.white;
        dialogBorderSide = const BorderSide(color: Colors.white);
        break;
      default: // System
        dialogBgColor = Colors.indigo.withOpacity(0.9);
        dialogTextColor = Colors.white;
        dialogBorderSide = BorderSide.none;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: dialogBorderSide,
        ),
        title: Text(
          "${data['city']}, ${data['country'] ?? ''}",
          style: TextStyle(color: dialogTextColor, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Lottie.asset(getLottiePath(data['condition']),
                  fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('🌡️ ', style: TextStyle(fontSize: 18)),
                Text("Temperature: ${data['temp']}$unitSymbol",
                    style: TextStyle(color: dialogTextColor, fontSize: 18)),
              ],
            ),
            Row(
              children: [
                Text('$conditionEmoji ', style: const TextStyle(fontSize: 16)),
                Text("Condition: ${data['condition']}",
                    style: TextStyle(color: dialogTextColor, fontSize: 16)),
              ],
            ),
            Row(
              children: [
                const Text('💧 ', style: TextStyle(fontSize: 16)),
                Text("Humidity: ${data['humidity']}%",
                    style: TextStyle(color: dialogTextColor, fontSize: 16)),
              ],
            ),
            Row(
              children: [
                const Text('🌬️ ', style: TextStyle(fontSize: 16)),
                Text(
                    "Wind Speed: ${data['wind_speed'].toStringAsFixed(1)} $windUnit",
                    style: TextStyle(color: dialogTextColor, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 16)),
                Text("AI Suggestion:",
                    style: TextStyle(
                        color: dialogTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Text(suggestion,
                style: TextStyle(color: dialogTextColor, fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: dialogTextColor),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    Color bgColor;
    Color textColor;
    Color cardBgColor;
    Color borderColor;
    String windUnit = settings.temperatureUnit == "°C" ? "m/s" : "mph";

    const bgGradient = LinearGradient(
      colors: [
        Colors.indigo,
        Colors.deepPurple,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    switch (settings.themeMode) {
      case "Light":
        bgColor = Colors.white;
        textColor = Colors.blue;
        cardBgColor = Colors.white;
        borderColor = Colors.blue;
        break;
      case "Dark":
        bgColor = Colors.black;
        textColor = Colors.white;
        cardBgColor = Colors.black;
        borderColor = Colors.white;
        break;
      default: // System
        bgColor = Colors.transparent;
        textColor = Colors.white;
        cardBgColor = Colors.white.withOpacity(0.1);
        borderColor = Colors.white.withOpacity(0.2);
    }

    final decoration = settings.themeMode == "System"
        ? const BoxDecoration(gradient: bgGradient)
        : BoxDecoration(color: bgColor);

    Widget bodyContent;
    if (isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (favourites.isEmpty) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("No favourites yet",
                style: TextStyle(color: textColor, fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: addFavourite,
              style: ElevatedButton.styleFrom(
                backgroundColor: settings.themeMode == "System"
                    ? Colors.indigo.withOpacity(0.8)
                    : borderColor.withOpacity(0.2),
              ),
              child: Text("Add Location", style: TextStyle(color: textColor)),
            ),
          ],
        ),
      );
    } else {
      bodyContent = ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        itemCount: weatherDataList.length,
        itemBuilder: (context, index) {
          final data = weatherDataList[index];
          final itemWidget = Card(
            color: cardBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderColor),
            ),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildItemContent(data, textColor, windUnit),
            ),
          );

          return Dismissible(
            key: Key(data['city']),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => removeFavourite(data['city']),
            child: GestureDetector(
              onTap: () {
                showWeatherDetails(context, data, textColor);
              },
              child: itemWidget,
            ),
          );
        },
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Favourites",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: textColor),
            onPressed: addFavourite,
          ),
        ],
      ),
      body: Container(
        decoration: decoration,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),
            Expanded(
              child: bodyContent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemContent(
      Map<String, dynamic> data, Color textColor, String windUnit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left block
        Flexible(
          child: Row(
            children: [
              Icon(Icons.location_city, color: textColor),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${data['city']}, ${data['country'] ?? ''}",
                      style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(getConditionEmoji(data['condition']),
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(data['condition'],
                          style: TextStyle(
                              color: textColor.withOpacity(0.7), fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("Humidity: ${data['humidity']}%",
                      style: TextStyle(
                          color: textColor.withOpacity(0.7), fontSize: 12)),
                  Text(
                      "Wind: ${data['wind_speed'].toStringAsFixed(1)} $windUnit",
                      style: TextStyle(
                          color: textColor.withOpacity(0.7), fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        // Right block
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Text("🌡 ", style: TextStyle(fontSize: 16)),
                Text("${data['temp']}°",
                    style: TextStyle(color: textColor, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 40,
              height: 40,
              child: Lottie.asset(getLottiePath(data['condition']),
                  fit: BoxFit.contain),
            ),
          ],
        ),
      ],
    );
  }
}
