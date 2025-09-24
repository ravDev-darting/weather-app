// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:glassmorphism/glassmorphism.dart';
// import 'package:provider/provider.dart';
// import '../provider/settings_provider.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final settings = Provider.of<SettingsProvider>(context);

//     // Define dynamic colors based on themeMode
//     final isLight = settings.themeMode == "Light";
//     final isDark = settings.themeMode == "Dark";
//     final isSystem = settings.themeMode == "System";

//     final Color bgColor = isLight
//         ? Colors.white
//         : isDark
//             ? Colors.black
//             : Colors.transparent; // for System → gradient below

//     final Color textColor = isLight ? Colors.blue : Colors.white;
//     final Color borderColor = isLight ? Colors.blue : Colors.white;

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: Text(
//           "Settings",
//           style: TextStyle(color: textColor),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: IconThemeData(color: textColor),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           color: isLight || isDark ? bgColor : null,
//           gradient: isSystem
//               ? const LinearGradient(
//                   // colors: [
//                   //   Color.fromARGB(255, 74, 71, 71),
//                   //   Color.fromARGB(179, 187, 182, 182)
//                   // ],
//                   colors: [
//                     Colors.indigo,
//                     Colors.deepPurple,
//                     Colors.black,
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 )
//               : null,
//         ),
//         child: SafeArea(
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               GlassmorphicContainer(
//                 width: double.infinity,
//                 height: 400,
//                 borderRadius: 20,
//                 blur: 20,
//                 alignment: Alignment.center,
//                 border: 1,
//                 linearGradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.white.withOpacity(0.3),
//                     Colors.grey.shade200.withOpacity(0.2),
//                   ],
//                   stops: const [0.1, 1],
//                 ),
//                 borderGradient: LinearGradient(
//                   colors: [
//                     Colors.white.withOpacity(0.6),
//                     Colors.grey.withOpacity(0.3),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Units",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: textColor,
//                         ),
//                       ),
//                       const SizedBox(height: 10),

//                       // Temperature
//                       _buildDropdownTile(
//                         icon: Icons.thermostat,
//                         title: "Temperature",
//                         value: settings.temperatureUnit,
//                         options: ['°C', '°F'],
//                         onChanged: (value) =>
//                             settings.setTemperatureUnit(value),
//                         textColor: textColor,
//                         borderColor: borderColor,
//                         isLight: isLight,
//                       ),

//                       // Wind Speed
//                       _buildDropdownTile(
//                         icon: Icons.air,
//                         title: "Wind Speed",
//                         value: settings.windUnit,
//                         options: ['km/h', 'mph'],
//                         onChanged: (value) => settings.setWindUnit(value),
//                         textColor: textColor,
//                         borderColor: borderColor,
//                         isLight: isLight,
//                       ),

//                       // Pressure
//                       _buildDropdownTile(
//                         icon: Icons.compress,
//                         title: "Pressure",
//                         value: settings.pressureUnit,
//                         options: ['hPa', 'inHg'],
//                         onChanged: (value) => settings.setPressureUnit(value),
//                         textColor: textColor,
//                         borderColor: borderColor,
//                         isLight: isLight,
//                       ),

//                       const SizedBox(height: 20),
//                       Text(
//                         "Appearance",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: textColor,
//                         ),
//                       ),
//                       const SizedBox(height: 10),

//                       // Theme Mode
//                       _buildDropdownTile(
//                         icon: Icons.brightness_6,
//                         title: "Theme",
//                         value: settings.themeMode,
//                         options: ['Light', 'Dark', 'System'],
//                         onChanged: (value) => settings.setThemeMode(value),
//                         textColor: textColor,
//                         borderColor: borderColor,
//                         isLight: isLight,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdownTile({
//     required IconData icon,
//     required String title,
//     required String value,
//     required List<String> options,
//     required ValueChanged<String> onChanged,
//     required Color textColor,
//     required Color borderColor,
//     required bool isLight,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: textColor),
//       title: Text(
//         title,
//         style: TextStyle(
//           fontWeight: FontWeight.w500,
//           color: textColor,
//         ),
//       ),
//       trailing: DropdownButton<String>(
//         value: value,
//         dropdownColor: isLight ? Colors.grey.shade200 : Colors.indigo,
//         style: TextStyle(color: textColor),
//         items: options
//             .map(
//               (opt) => DropdownMenuItem(
//                 value: opt,
//                 child: Text(opt, style: TextStyle(color: textColor)),
//               ),
//             )
//             .toList(),
//         onChanged: (val) => onChanged(val!),
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';
import '../provider/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    // Define dynamic colors based on themeMode
    final isLight = settings.themeMode == "Light";
    final isDark = settings.themeMode == "Dark";
    final isSystem = settings.themeMode == "System";

    final Color bgColor = isLight
        ? Colors.white
        : isDark
            ? Colors.black
            : Colors.transparent; // for System → gradient below

    final Color textColor = isLight ? Colors.blue : Colors.white;
    final Color borderColor = isLight ? Colors.blue : Colors.white;

    // Dynamic glassmorphic colors
    Color glassBgStart;
    Color glassBgEnd;
    Color glassBorderStart;
    Color glassBorderEnd;

    if (isLight) {
      glassBgStart = Colors.blue.withOpacity(0.1);
      glassBgEnd = Colors.blue.withOpacity(0.05);
      glassBorderStart = Colors.blue.withOpacity(0.5);
      glassBorderEnd = Colors.blue.withOpacity(0.2);
    } else if (isDark) {
      glassBgStart = Colors.white.withOpacity(0.05);
      glassBgEnd = Colors.white.withOpacity(0.02);
      glassBorderStart = Colors.white.withOpacity(0.3);
      glassBorderEnd = Colors.white.withOpacity(0.1);
    } else {
      // System
      glassBgStart = Colors.white.withOpacity(0.3);
      glassBgEnd = Colors.grey.shade200.withOpacity(0.2);
      glassBorderStart = Colors.white.withOpacity(0.6);
      glassBorderEnd = Colors.grey.withOpacity(0.3);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isLight || isDark ? bgColor : null,
          gradient: isSystem
              ? const LinearGradient(
                  colors: [
                    Colors.indigo,
                    Colors.deepPurple,
                    Colors.black,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassmorphicContainer(
                width: double.infinity,
                height: 400,
                borderRadius: 20,
                blur: 20,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    glassBgStart,
                    glassBgEnd,
                  ],
                  stops: const [0.1, 1],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    glassBorderStart,
                    glassBorderEnd,
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Units",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Temperature
                      _buildDropdownTile(
                        icon: Icons.thermostat,
                        title: "Temperature",
                        value: settings.temperatureUnit,
                        options: ['°C', '°F'],
                        onChanged: (value) =>
                            settings.setTemperatureUnit(value),
                        textColor: textColor,
                        borderColor: borderColor,
                        isLight: isLight,
                        isDark: isDark,
                      ),

                      // Wind Speed
                      _buildDropdownTile(
                        icon: Icons.air,
                        title: "Wind Speed",
                        value: settings.windUnit,
                        options: ['km/h', 'mph'],
                        onChanged: (value) => settings.setWindUnit(value),
                        textColor: textColor,
                        borderColor: borderColor,
                        isLight: isLight,
                        isDark: isDark,
                      ),

                      // Pressure
                      _buildDropdownTile(
                        icon: Icons.compress,
                        title: "Pressure",
                        value: settings.pressureUnit,
                        options: ['hPa', 'inHg'],
                        onChanged: (value) => settings.setPressureUnit(value),
                        textColor: textColor,
                        borderColor: borderColor,
                        isLight: isLight,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 20),
                      Text(
                        "Appearance",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Theme Mode
                      _buildDropdownTile(
                        icon: Icons.brightness_6,
                        title: "Theme",
                        value: settings.themeMode,
                        options: ['Light', 'Dark', 'System'],
                        onChanged: (value) => settings.setThemeMode(value),
                        textColor: textColor,
                        borderColor: borderColor,
                        isLight: isLight,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
    required Color textColor,
    required Color borderColor,
    required bool isLight,
    required bool isDark,
  }) {
    Color dropdownColor = isLight
        ? Colors.white
        : isDark
            ? Colors.grey[800]!
            : Colors.indigo;

    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: dropdownColor,
        style: TextStyle(color: textColor),
        items: options
            .map(
              (opt) => DropdownMenuItem(
                value: opt,
                child: Text(opt, style: TextStyle(color: textColor)),
              ),
            )
            .toList(),
        onChanged: (val) => onChanged(val!),
      ),
    );
  }
}
