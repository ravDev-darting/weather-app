# 🌦 Weather App

A modern, elegant weather application built with **Flutter**, featuring real-time weather updates, forecasts, interactive radar maps, AI-powered suggestions, and a **glassmorphism theme**.

---

## 🛠 Tech Stack

- Flutter & Dart
- REST APIs for weather data
- Provider for state management
- Glassmorphism UI with animations

## 🚀 Features

### 🌤 1. Home Screen

- Quick weather overview: temperature, feels like, condition, humidity, wind, pressure.
- Small today timeline (next 6 hours).
- Quick cards/buttons: **Air Quality (AQI + health suggestion)**, **UV Index**, **Favorites**.
- Search bar for city or country (styled according to theme).

### 📅 2. Forecast Screen

- Hourly Forecast (24 hours) with temperature, wind, and rain probability.
- 5-day Forecast (3-hour intervals).
- Sunrise & Sunset times.
- Moon phases.
- Graphs: temperature and rainfall trends.

### 🛰 3. Radar / Map Screen

- Live radar for rain, snow, and storm tracking.
- Temperature heatmap.
- Wind speed & direction map.
- Air quality map.
- Region zoom & selection.

### ⚠ 4. Alerts & AI Suggestions

- Real-time weather alerts (storms, floods, heatwaves, etc.).
- AI Smart Suggestions:
  - “Carry an umbrella today.”
  - “Good day for running.”
  - “Use sunscreen, UV index is high.”
- Custom alerts: users can set conditions (e.g., notify me if rain chance > 60%).

### 👤 5. Settings Screen

- **Units**:
  - Temperature: °C / °F
  - Wind: km/h / mph
  - Pressure: hPa / inHg
- **Appearance**:
  - Theme: Light, Dark, System
  - **Glassmorphism UI theme** for modern look

---

## 📱 App Screenshots

### 🌤 Home Screen (System theme)

<img src="screenshots/weather/home_screen_system_theme.png" width="300"/>

### 🌤 Home Screen (Light theme)

<img src="screenshots/weather/home_screen_light_theme.png" width="300"/>

### 🌤 Home Screen (Dark theme)

<img src="screenshots/weather/home_screen_dark_theme.png" width="300"/>

### 🌤 Forecast Screen (System theme)

<img src="screenshots/weather/forecast_screen.png" width="300"/>

### 🌤 Forecast Screen (Dark theme)

<img src="screenshots/weather/remain_forecast_screen_dark_mood.png" width="300"/>

### 🌤 Radar Screen ( show temperature light theme)

<img src="screenshots/weather/radar_screen_light_theme.png" width="300"/>

### 🌤 Radar Screen ( show cloud system theme)

<img src="screenshots/weather/radar_screen_system _theme.png" width="300"/>

### 🌤 Radar Screen ( show percipitation dark theme)

<img src="screenshots/weather/radar_screen_dark_theme.png" width="300"/>
<img src="screenshots/weather" width="300"/>

### 🌤 Air Quality Screen (according to weather)

<img src="screenshots/weather/air_quality_good.png" width="300"/>

### 🌤 Air Quality Screen (according to weather)

<img src="screenshots/weather/air_quality_moderate.png" width="300"/>

### 🌤 Favourite Screen (system theme)

<img src="screenshots/weather/favourite_screen.png" width="300"/>

### 🌤 Favourite Screen (deatil)

<img src="screenshots/weather/favourite_screen_detail.png" width="300"/>

### 🌤 alert & Ai suggestions Screen (system theme)

<img src="screenshots/weather/alerts_ai_suggestions_screen.png" width="300"/>

### 🌤 Setting Screen (system theme)

<img src="screenshots/weather/setting-screen.png" width="300"/>

## 📦 Installation

### Option 1: Install from GitHub Releases

1. Go to the **[Releases Section](https://github.com/ravDev-darting/weather-app/releases/tag/v1.0.0)**.
2. Download the latest file:
   - For Android devices → `app-release.apk`
   - For Play Store upload → `app-release.aab`
3. Install on your device.
   > ⚠️ You may see a warning like _"This file may be harmful"_ — this happens because the app is not from Google Play. You can safely proceed if you trust the source.

### Option 2: Build from Source

1. Clone this repo:

```bash
  git clone https://github.com/ravDev-darting/weather-app

# Go to project folder

cd weather-app

# Install dependencies

flutter pub get

# Run on device

flutter run

```
