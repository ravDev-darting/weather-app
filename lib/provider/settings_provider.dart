// import 'package:flutter/material.dart';

// class SettingsProvider extends ChangeNotifier {
//   // Default values
//   String _temperatureUnit = '°C';
//   String _windUnit = 'km/h';
//   String _pressureUnit = 'hPa';
//   String _themeMode = 'System'; // Light, Dark, System

//   // Getters
//   String get temperatureUnit => _temperatureUnit;
//   String get windUnit => _windUnit;
//   String get pressureUnit => _pressureUnit;
//   String get themeMode => _themeMode;

//   // Setters with notifyListeners
//   void setTemperatureUnit(String unit) {
//     _temperatureUnit = unit;
//     notifyListeners();
//   }

//   void setWindUnit(String unit) {
//     _windUnit = unit;
//     notifyListeners();
//   }

//   void setPressureUnit(String unit) {
//     _pressureUnit = unit;
//     notifyListeners();
//   }

//   void setThemeMode(String mode) {
//     _themeMode = mode;
//     notifyListeners();
//   }

//   // Helper for ThemeData
//   ThemeData getThemeData(BuildContext context) {
//     switch (_themeMode) {
//       case 'Light':
//         return ThemeData.light().copyWith(
//           scaffoldBackgroundColor: Colors.white,
//           textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.blue)),
//         );
//       case 'Dark':
//         return ThemeData.dark().copyWith(
//           scaffoldBackgroundColor: Colors.black,
//           textTheme:
//               const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
//         );
//       case 'System':
//       default:
//         return Theme.of(context);
//     }
//   }
// }

import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  // Default values
  String _temperatureUnit = '°C';
  String _windUnit = 'km/h';
  String _pressureUnit = 'hPa';
  String _themeMode = 'System'; // Light, Dark, System

  // Getters
  String get temperatureUnit => _temperatureUnit;
  String get windUnit => _windUnit;
  String get pressureUnit => _pressureUnit;
  String get themeMode => _themeMode;

  // Setters with notifyListeners
  void setTemperatureUnit(String unit) {
    _temperatureUnit = unit;
    notifyListeners();
  }

  void setWindUnit(String unit) {
    _windUnit = unit;
    notifyListeners();
  }

  void setPressureUnit(String unit) {
    _pressureUnit = unit;
    notifyListeners();
  }

  void setThemeMode(String mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Return background colors and text styles based on theme
  Color getBackgroundColor() {
    if (_themeMode == 'Light') return Colors.white;
    if (_themeMode == 'Dark') return Colors.black;
    return Colors.transparent; // System → keep your gradient/glassmorphic
  }

  Color getTextColor() {
    if (_themeMode == 'Light') return Colors.blue;
    if (_themeMode == 'Dark') return Colors.white;
    return Colors.white; // System → use existing gradient style (white text)
  }

  Color getBorderColor() {
    if (_themeMode == 'Light') return Colors.blue;
    if (_themeMode == 'Dark') return Colors.white;
    return Colors.white.withOpacity(0.3); // System
  }
}
