import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart'; // ✅ Add this to pubspec.yaml

class ForecastScreen extends StatefulWidget {
  final String unit;
  const ForecastScreen({super.key, required this.unit});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  Map<String, dynamic>? _forecastData;
  bool _isLoading = true;
  String? _error;

  final String apiKey = "b83f15578b1c0f6507504162e7e2c4c0"; // ✅ your key

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    try {
      Position pos = await Geolocator.getCurrentPosition();

      final url =
          "https://api.openweathermap.org/data/2.5/forecast?lat=${pos.latitude}&lon=${pos.longitude}&units=${widget.unit}&appid=$apiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _forecastData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load forecast (${response.statusCode})";
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

  List<FlSpot> _getChartSpots() {
    if (_forecastData == null) return [];
    final list = _forecastData!['list'];
    return List.generate(list.length, (i) {
      final temp = (list[i]['main']['temp'] as num).toDouble();
      return FlSpot(i.toDouble(), temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("5-Day / 3-Hour Forecast")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    // ✅ Chart Section
                    SizedBox(
                      height: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: LineChart(
                          LineChartData(
                            minY: (_getChartSpots()
                                    .map((e) => e.y)
                                    .reduce((a, b) => a < b ? a : b)) -
                                2,
                            maxY: (_getChartSpots()
                                    .map((e) => e.y)
                                    .reduce((a, b) => a > b ? a : b)) +
                                2,
                            gridData: const FlGridData(show: true),
                            borderData: FlBorderData(show: true),
                            titlesData: const FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _getChartSpots(),
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ✅ List Section
                    Expanded(
                      child: ListView.builder(
                        itemCount: _forecastData?['list']?.length ?? 0,
                        itemBuilder: (context, index) {
                          final item = _forecastData!['list'][index];
                          final date = DateTime.fromMillisecondsSinceEpoch(
                              item['dt'] * 1000);
                          final temp = item['main']['temp'];
                          final description = item['weather'][0]['description'];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: Icon(Icons.cloud,
                                  color: Colors.blue.shade400),
                              title: Text(
                                "${date.day}-${date.month} ${date.hour}:00",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(description),
                              trailing: Text(
                                "${temp.toStringAsFixed(1)}° ${widget.unit == "metric" ? "C" : "F"}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
