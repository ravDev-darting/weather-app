import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:glassmorphism/glassmorphism.dart';

class AnimatedWeatherScreen extends StatelessWidget {
  final String condition;
  final String? iconCode;
  final String city;
  final String country;
  final String temperature;
  final String unit;

  const AnimatedWeatherScreen({
    super.key,
    required this.condition,
    this.iconCode,
    required this.city,
    required this.country,
    required this.temperature,
    required this.unit,
  });

  /// Choose a local Lottie animation based on condition
  String _chooseLottie(String cond) {
    final c = cond.toLowerCase();
    if (c.contains('rain') || c.contains('drizzle'))
      return 'assets/lottie/rain.json';
    if (c.contains('thunder') || c.contains('storm'))
      return 'assets/lottie/thunder.json';
    if (c.contains('snow')) return 'assets/lottie/snow.json';
    if (c.contains('cloud')) return 'assets/lottie/cloudy.json';
    if (c.contains('clear') || c.contains('sun'))
      return 'assets/lottie/sunny.json';
    if (c.contains('mist') || c.contains('fog') || c.contains('haze'))
      return 'assets/lottie/fog.json';
    return 'assets/lottie/cloudy.json'; // fallback
  }

  Color _glowColor(String cond) {
    final c = cond.toLowerCase();
    if (c.contains('rain')) return Colors.blueAccent.withOpacity(0.6);
    if (c.contains('thunder')) return Colors.deepPurple.withOpacity(0.6);
    if (c.contains('snow')) return Colors.cyanAccent.withOpacity(0.6);
    if (c.contains('cloud')) return Colors.grey.withOpacity(0.6);
    if (c.contains('clear')) return Colors.orange.withOpacity(0.6);
    return Colors.indigo.withOpacity(0.5);
  }

  @override
  Widget build(BuildContext context) {
    final lottiePath = _chooseLottie(condition);
    final glow = _glowColor(condition);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Animated Weather'),
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  glow.withOpacity(0.18),
                  Colors.black87,
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 36),
              child: GlassmorphicContainer(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.75,
                borderRadius: 28,
                blur: 30,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.03),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.35),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$city, $country',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                condition[0].toUpperCase() +
                                    condition.substring(1),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          if (iconCode != null)
                            Image.network(
                              'https://openweathermap.org/img/wn/${iconCode!}@2x.png',
                              width: 56,
                              height: 56,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: glow,
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 320,
                              height: 320,
                              child: Lottie.asset(
                                lottiePath,
                                fit: BoxFit.contain,
                                repeat: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        temperature,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.08),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                            ),
                            onPressed: () =>
                                Navigator.pushNamed(context, '/forecast'),
                            icon: const Icon(Icons.calendar_today,
                                color: Colors.white),
                            label: const Text('Forecast',
                                style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.08),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                            ),
                            onPressed: () =>
                                Navigator.pushNamed(context, '/radar'),
                            icon: const Icon(Icons.map, color: Colors.white),
                            label: const Text('Radar',
                                style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.08),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                            ),
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            label: const Text('Back',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
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
