import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../config/api_config.dart';
import '../models/air_quality_data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AirQualityService {
  Future<Position> _getCurrentLocation() async {
    print('[_getCurrentLocation] Attempting to get current location...');
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('[_getCurrentLocation] Location services are disabled.');
      throw Exception('Location services are disabled.');
    }
    print('[_getCurrentLocation] Location services are enabled.');

    var status = await Permission.location.status;
    print('[_getCurrentLocation] Location permission status: $status');

    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      print('[_getCurrentLocation] Requesting location permissions...');
      status = await Permission.location.request();
      print(
          '[_getCurrentLocation] Location permission status after request: $status');
      if (status.isDenied ||
          status.isRestricted ||
          status.isPermanentlyDenied) {
        print(
            '[_getCurrentLocation] Location permissions are denied or restricted after request.');
        throw Exception('Location permissions are denied or restricted.');
      }
    }

    if (status.isGranted) {
      print(
          '[_getCurrentLocation] Location permissions are granted. Getting position...');
      try {
        final position = await Geolocator.getCurrentPosition();
        print(
            '[_getCurrentLocation] Successfully got position: ${position.latitude}, ${position.longitude}');
        return position;
      } catch (e) {
        print('[_getCurrentLocation] Error getting position: $e');
        throw Exception('Error getting current position: $e');
      }
    } else {
      print('[_getCurrentLocation] Location permissions are not granted.');
      throw Exception('Location permissions are not granted.');
    }
  }

  Future<AirQualityData> getNearestCityAirQuality() async {
    print('[getNearestCityAirQuality] Checking connectivity...');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print('[getNearestCityAirQuality] No internet connection.');
      throw Exception(
          'No internet connection. Please check your network settings.');
    }
    print('[getNearestCityAirQuality] Internet connection available.');

    try {
      print('[getNearestCityAirQuality] Getting current location...');
      final position = await _getCurrentLocation();
      print(
          '[getNearestCityAirQuality] Calling getCityAirQuality with lat: ${position.latitude}, lon: ${position.longitude}');
      return await getCityAirQuality(position.latitude, position.longitude);
    } catch (e) {
      print(
          '[getNearestCityAirQuality] Error in getting nearest city air quality: $e');
      throw Exception('Error getting air quality data: $e');
    }
  }

  Future<AirQualityData> getCityAirQuality(double lat, double lon) async {
    print('[getCityAirQuality] Checking connectivity...');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print('[getCityAirQuality] No internet connection.');
      throw Exception(
          'No internet connection. Please check your network settings.');
    }
    print('[getCityAirQuality] Internet connection available.');

    try {
      final url = Uri.parse(
        '${ApiConfig.openweathermapBaseUrl}?lat=$lat&lon=$lon&appid=${ApiConfig.openweathermapApiKey}',
      );
      print('[getCityAirQuality] Calling API with URL: $url');
      final response = await http.get(url);
      print(
          '[getCityAirQuality] Received API response with status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('[getCityAirQuality] API response successful. Decoding JSON...');
        final jsonBody = json.decode(response.body);
        print(
            '[getCityAirQuality] JSON decoded. Parsing into AirQualityData...');
        return AirQualityData.fromJson(jsonBody);
      } else {
        print(
            '[getCityAirQuality] API error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load air quality data: Status ${response.statusCode}');
      }
    } catch (e) {
      print('[getCityAirQuality] Error getting air quality data: $e');
      throw Exception('Error getting air quality data: $e');
    }
  }
}
