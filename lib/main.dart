// import 'package:flutter/material.dart';
// import 'screens/home_screen.dart';
// // import 'package:google_fonts/google_fonts.dart';

// void main() {
//   runApp(const WeatherApp());
// }

// class WeatherApp extends StatefulWidget {
//   const WeatherApp({super.key});

//   @override
//   State<WeatherApp> createState() => _WeatherAppState();
// }

// class _WeatherAppState extends State<WeatherApp> {
//   bool _darkMode = false;
//   String _unit = "metric";

//   // Global messenger key for SnackBars
//   final GlobalKey<ScaffoldMessengerState> _messengerKey =
//       GlobalKey<ScaffoldMessengerState>();

//   void _updateSettings(bool darkMode, String unit) {
//     setState(() {
//       _darkMode = darkMode;
//       _unit = unit;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       scaffoldMessengerKey: _messengerKey,
//       theme: ThemeData(
//         brightness: _darkMode ? Brightness.dark : Brightness.light,
//         scaffoldBackgroundColor:
//             _darkMode ? Colors.black : Colors.white, // glass looks better
//         useMaterial3: true, // smoother widgets
//         // textTheme: GoogleFonts.poppinsTextTheme(
//         //   // Applies Poppins to all text
//         //   Theme.of(context).textTheme,
//         // ),
//       ),
//       home: HomeScreen(
//         unit: _unit,
//         darkMode: _darkMode,
//         onSettingsChanged: _updateSettings,
//         // messengerKey: _messengerKey, // pass down for showing SnackBars
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/settings_provider.dart';
import 'screens/home_screen.dart';
import 'provider/favorites_provider.dart'; // Add this import

void main() {
  runApp(
    // ChangeNotifierProvider(
    //   create: (_) => SettingsProvider(),
    //   child: const MyApp(),
    // ),

    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(
            create: (context) => FavoritesProvider()), // Add this
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Weather App',
            theme: ThemeData.light().copyWith(
              scaffoldBackgroundColor: Colors.white,
              primaryColor: Colors.blue,
            ),
            darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.black,
              primaryColor: Colors.deepPurple,
            ),
            themeMode: settings.themeMode == "Light"
                ? ThemeMode.light
                : settings.themeMode == "Dark"
                    ? ThemeMode.dark
                    : ThemeMode.system,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
