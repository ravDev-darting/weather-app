import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool darkMode;
  final String unit;
  final Function(bool, String) onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.darkMode,
    required this.unit,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _darkMode;
  late String _unit;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.darkMode;
    _unit = widget.unit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: _darkMode,
              onChanged: (val) {
                setState(() => _darkMode = val);
                widget.onSettingsChanged(_darkMode, _unit);
              },
            ),
            ListTile(
              title: const Text("Units"),
              trailing: DropdownButton<String>(
                value: _unit,
                items: const [
                  DropdownMenuItem(
                      value: "metric", child: Text("Celsius (°C)")),
                  DropdownMenuItem(
                      value: "imperial", child: Text("Fahrenheit (°F)")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _unit = val);
                    widget.onSettingsChanged(_darkMode, _unit);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
