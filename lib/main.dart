import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'services/air_quality_service.dart';
import 'models/air_quality_data.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/api_config.dart';
import 'models/pakistan_cities.dart';
import 'services/news_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/location_service.dart';
import 'package:geolocator/geolocator.dart';

const Color kPrimaryAir = Color(0xFF87CEEB); // Light Sky Blue
const Color kAccentAir = Color(0xFFB2EBF2); // Soft Cyan
const Color kBackgroundAir = Color(0xFFE3F6FD); // Very Light Blue
const Color kButtonAir = Color(0xFF00BFFF); // Deep Sky Blue

// ValueNotifier to manage theme mode
ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const AQIApp());
}

class AQIApp extends StatelessWidget {
  const AQIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'Shifaf Air PK',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: kPrimaryAir,
            scaffoldBackgroundColor: kBackgroundAir,
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: kPrimaryAir,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: kButtonAir,
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: kButtonAir,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            textTheme: GoogleFonts.poppinsTextTheme().apply(
              bodyColor: Colors.black87, // Default text color for light mode
              displayColor: Colors.black87,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blueGrey,
            primaryColor: Colors.blueGrey[700],
            scaffoldBackgroundColor: Colors.grey[900],
            cardColor: Colors.grey[800],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blueGrey[900],
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.blueGrey[600],
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            textTheme: GoogleFonts.poppinsTextTheme().apply(
              bodyColor: Colors.white70, // Default text color for dark mode
              displayColor: Colors.white70,
            ),
            // Add more dark theme customizations here
          ),
          themeMode: currentThemeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AirQualityService _airQualityService = AirQualityService();
  AirQualityData? _airQualityData;
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadAirQualityData();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _locationError = null;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString();
      });
    }
  }

  Future<void> _loadAirQualityData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _airQualityService.getNearestCityAirQuality();
      setState(() {
        _airQualityData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToCitySearch() async {
    final result = await Navigator.push<AirQualityData?>(
      context,
      MaterialPageRoute(builder: (context) => const CitySearchScreen()),
    );
    if (result != null) {
      setState(() {
        _airQualityData = result;
        _error = null;
      });
    }
  }

  void _navigateToNews() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewsScreen()),
    );
  }

  void _toggleTheme() {
    themeModeNotifier.value =
        themeModeNotifier.value == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        themeModeNotifier.value ==
        ThemeMode.dark; // Check theme mode directly from notifier
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shifaf Air PK'),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.brightness_7 : Icons.brightness_4,
            ), // Sun/Moon icon based on mode
            onPressed: _toggleTheme,
            tooltip:
                isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
          _buildLocationButton(),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildLocationInfo(),
            ),
          ),
          Expanded(
            // Add this Expanded widget
            child:
                _isLoading
                    ? _buildLoadingShimmer()
                    : _error != null
                    ? _buildErrorWidget()
                    : _airQualityData != null
                    ? _buildAirQualityContent()
                    : const Center(child: Text('No data available')),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'news',
            onPressed: _navigateToNews,
            child: const Icon(Icons.article),
            tooltip: 'Weather & Air News',
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'search',
            onPressed: _navigateToCitySearch,
            child: const Icon(Icons.search),
            tooltip: 'Search Pakistani City',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return IconButton(
      icon: const Icon(Icons.my_location),
      onPressed: _getCurrentLocation,
      tooltip: 'Get Current Location',
    );
  }

  Widget _buildLocationInfo() {
    if (_locationError != null) {
      return Text(
        'Location error: $_locationError',
        style: const TextStyle(color: Colors.red),
        overflow: TextOverflow.ellipsis, // Add this
        maxLines: 2, // Add this
      );
    }

    if (_currentPosition == null) {
      return const Text('Getting location...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        shrinkWrap: true, // Add this
        physics: const NeverScrollableScrollPhysics(), // Add this
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error ?? 'An error occurred'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAirQualityData,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildAirQualityContent() {
    final data = _airQualityData!;
    return Expanded(
      // Add this Expanded widget
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationCard(data),
            const SizedBox(height: 16),
            _buildAQICard(data),
            const SizedBox(height: 16),
            _buildPollutantsCard(data),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(AirQualityData data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  // Add this
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lat: ${data.latitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Lon: ${data.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateFormat('MMM dd, yyyy HH:mm').format(data.timestamp)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAQICard(AirQualityData data) {
    // Use the aqi from OpenWeatherMap data
    final aqi = data.aqi; // Use the OpenWeatherMap integer AQI
    final category = _getAQICategory(
      aqi.toDouble(),
    ); // Pass as double for existing category function signature
    final color = _getAQIColor(
      category,
    ); // Keep using category for color mapping

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Air Quality Index',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value:
                                aqi / 5.0, // Scale for OpenWeatherMap AQI (1-5)
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            strokeWidth: 12,
                          ),
                        ),
                        Text(
                          aqi.toString(), // Display integer AQI
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: color),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollutantsCard(AirQualityData data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pollutants', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildPollutantBar('PM2.5', data.pm25),
            _buildPollutantBar('PM10', data.pm10),
            _buildPollutantBar('O3', data.o3),
            _buildPollutantBar('NO2', data.no2),
            _buildPollutantBar('SO2', data.so2),
            _buildPollutantBar('CO', data.co),
          ],
        ),
      ),
    );
  }

  Widget _buildPollutantBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(label), Text(value.toStringAsFixed(1))],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 500,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getPollutantColor(value),
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  String _getAQICategory(double aqi) {
    // OpenWeatherMap AQI is 1-5
    if (aqi == 1) return 'Good';
    if (aqi == 2) return 'Fair';
    if (aqi == 3) return 'Moderate';
    if (aqi == 4) return 'Poor';
    if (aqi == 5) return 'Very Poor';
    return 'Unknown'; // Handle unexpected values
  }

  Color _getAQIColor(String category) {
    switch (category) {
      case 'Good':
        return Colors.green;
      case 'Fair':
        return Colors.yellow;
      case 'Moderate':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      case 'Very Poor':
        return Colors.purple;
      default:
        return Colors.blueGrey; // Default color for unknown category
    }
  }

  Color _getPollutantColor(double value) {
    if (value <= 50) return Colors.green;
    if (value <= 100) return Colors.yellow[700]!;
    if (value <= 150) return Colors.orange;
    if (value <= 200) return Colors.red;
    if (value <= 300) return Colors.purple;
    return Colors.brown[900]!;
  }
}

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  List<Map<String, dynamic>> _filteredCities = pakistanCities;
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredCities =
          pakistanCities
              .where((city) => city['name'].toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> _selectCity(Map<String, dynamic> city) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AirQualityService().getCityAirQuality(
        city['lat'],
        city['lon'],
      );
      if (mounted) {
        Navigator.pop(context, data);
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shifaf Air PK')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search city',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child:
                _filteredCities.isEmpty && !_loading
                    ? const Center(child: Text('No cities found'))
                    : ListView.builder(
                      itemCount: _filteredCities.length,
                      itemBuilder: (context, index) {
                        final city = _filteredCities[index];
                        return ListTile(
                          title: Text(city['name']),
                          subtitle: Text(
                            'Lat: ${city['lat']}, Lon: ${city['lon']}',
                          ),
                          onTap: _loading ? null : () => _selectCity(city),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<NewsArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsService().fetchPakistanWeatherAirNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather & Air News')),
      body: FutureBuilder<List<NewsArticle>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No news found.'));
          }
          final news = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: news.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final article = news[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(article.title),
                  subtitle: Text(
                    '${article.source}${article.publishedAt != null ? '\n${article.publishedAt!.substring(0, 10)}' : ''}',
                  ),
                  onTap: () {
                    // Open the news article in the browser
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text(article.title),
                            content: Text('Open this article in your browser?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final url = Uri.parse(article.url);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Could not open article: ${article.url}',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Open'),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
