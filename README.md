# Shifaf Air PK (civics_app)

<p align="center">
  <img src="web/icons/Icon-192.png" alt="App Icon" width="120" />
</p>

<p align="center">
  <b>Real-time Air Quality & Weather News for Pakistan</b><br/>
  <i>Cross-platform Flutter app for Android, iOS, Web, Windows, Linux, and macOS</i>
</p>

<p align="center">
  <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-3.7.0-blue?logo=flutter" alt="Flutter" /></a>
  <a href="#license"><img src="https://img.shields.io/badge/license-MIT-green" alt="License" /></a>
  <a href="#platforms"><img src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue" alt="Platforms" /></a>
</p>

---

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
- [Configuration & API Keys](#configuration--api-keys)
- [Project Structure](#project-structure)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)
- [Credits](#credits)

---

## Overview

<b>Shifaf Air PK</b> is a modern, cross-platform Flutter application that provides real-time air quality data (AQI) for cities across Pakistan. It also aggregates weather and air-related news, and offers a beautiful, responsive UI with dark/light mode support. The app leverages geolocation to show AQI for your current location and allows searching for any Pakistani city.

---

## Features

- 🌍 <b>Location-based AQI:</b> Get real-time air quality for your current location.
- 🏙️ <b>City Search:</b> Search and view AQI for any city in Pakistan.
- 📰 <b>Weather & Air News:</b> Aggregated, filtered news about weather, pollution, and air quality in Pakistan.
- 🌗 <b>Dark/Light Mode:</b> Toggle between beautiful light and dark themes.
- 📊 <b>Modern UI:</b> Google Fonts, animated charts, shimmer loading effects.
- 🔒 <b>Permissions:</b> Handles location and network permissions gracefully.
- 🖥️ <b>Multi-platform:</b> Runs on Android, iOS, Web, Windows, Linux, and macOS.

---


## Getting Started

### Prerequisites
- [Flutter SDK 3.7.0+](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- Platform-specific requirements (Android Studio, Xcode, etc.)

### Installation

```bash
# Clone the repository
$ git clone <your-repo-url>
$ cd shfaf air

# Install dependencies
$ flutter pub get

# Run the app (choose your platform)
$ flutter run         # For mobile/web/desktop
```

### Platform Notes
- <b>Android/iOS:</b> Ensure emulators or devices are set up. Location permissions are required.
- <b>Web:</b> Supported out of the box. Use Chrome for best experience.
- <b>Windows/Linux/macOS:</b> Desktop support enabled. See [Flutter desktop docs](https://docs.flutter.dev/desktop).

---

## Configuration & API Keys

This app uses the following APIs:
- [OpenWeatherMap Air Pollution API](https://openweathermap.org/api/air-pollution)
- [GNews API](https://gnews.io/docs/)

API keys are currently hardcoded in `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String openweathermapApiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  static const String gnewsApiKey = 'YOUR_GNEWS_API_KEY';
}
```
<b>For production:</b> Move API keys to environment variables or secure storage. See [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) for best practices.

---

## Project Structure

```
lib/
  main.dart                # App entry point
  services/                # Air quality, news, and location services
  models/                  # Data models (air quality, cities)
  config/                  # API configuration
android/                   # Android native code & config
ios/                       # iOS native code & config
web/                       # Web assets & manifest
windows/, linux/, macos/   # Desktop platform code
```

---

## Testing

Basic widget tests are included:
```bash
flutter test
```
Add more tests in the `test/` directory to improve coverage.

---

## Contributing

Contributions are welcome! Please open issues or pull requests for bug fixes, features, or improvements.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Credits

- [Flutter](https://flutter.dev/)
- [OpenWeatherMap](https://openweathermap.org/)
- [GNews](https://gnews.io/)
- [Google Fonts](https://fonts.google.com/)
- [fl_chart](https://pub.dev/packages/fl_chart)
- [shimmer](https://pub.dev/packages/shimmer)
- [geolocator](https://pub.dev/packages/geolocator)
- [connectivity_plus](https://pub.dev/packages/connectivity_plus)

<p align="center">
  <b>Made with ❤️ using Flutter</b>
</p>
