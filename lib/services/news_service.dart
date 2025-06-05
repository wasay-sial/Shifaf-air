import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'dart:io'; // Import for SocketException
import 'package:http/http.dart'; // Import for ClientException
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity_plus

class NewsArticle {
  final String title;
  final String url;
  final String source;
  final String? publishedAt;

  NewsArticle({
    required this.title,
    required this.url,
    required this.source,
    this.publishedAt,
  });
}

class NewsService {
  static const List<String> includeKeywords = [
    'weather', 'smog', 'pollution', 'air quality', 'heatwave', 'rain', 'storm',
    'dust', 'fog', 'temperature', 'climate', 'monsoon', 'humidity', 'uv', 'sun', 'cold', 'hot', 'wind', 'flood', 'drought'
  ];
  static const List<String> excludeKeywords = [
    'minister', 'government', 'politics', 'election', 'assembly', 'bill', 'law',
    'party', 'pm', 'president', 'senate', 'cabinet', 'political', 'mna', 'mps', 'pti', 'pml', 'ppp', 'mqm', 'jui', 'jamat', 'imran', 'nawaz', 'bhutto', 'zardari', 'sharif', 'maryam', 'bilawal', 'asif', 'shehbaz', 'khan', 'aziz', 'abbasi', 'parliament', 'court', 'sc', 'chief justice', 'judge', 'verdict', 'case', 'arrest', 'bail', 'punjab', 'sindh', 'balochistan', 'kpk', 'khyber', 'pakhtunkhwa', 'islamabad', 'karachi', 'lahore', 'rawalpindi', 'quetta', 'peshawar', 'multan', 'faisalabad', 'gujranwala', 'sialkot', 'sukkur', 'hyderabad', 'larkana', 'sheikhupura', 'rahim yar khan', 'jhang', 'dera ghazi khan', 'gujrat'
  ];

  Future<List<NewsArticle>> fetchPakistanWeatherAirNews() async {
    // Check for network connectivity first
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('No internet connection. Please check your network settings.');
    }

    try {
      final url = Uri.parse(
        '${ApiConfig.gnewsBaseUrl}?q=weather+OR+air+OR+pollution+Pakistan&lang=en&country=pk&max=20&token=${ApiConfig.gnewsApiKey}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List articles = data['articles'];
        List<NewsArticle> filteredArticles = [];
        for (final articleJson in articles) {
          final title = articleJson['title']?.toLowerCase() ?? '';
          final description = articleJson['description']?.toLowerCase() ?? '';
          final text = '$title $description';

          final hasInclude = includeKeywords.any((kw) => text.contains(kw));
          final hasExclude = excludeKeywords.any((kw) => text.contains(kw));

          if (hasInclude && !hasExclude) {
            filteredArticles.add(NewsArticle(
              title: articleJson['title'] ?? '',
              url: articleJson['url'] ?? '',
              source: articleJson['source']?['name'] ?? '',
              publishedAt: articleJson['publishedAt'],
            ));
          }
        }
        // Sort by date, newest first (optional, GNews might return sorted)
        filteredArticles.sort((a, b) => (b.publishedAt ?? '').compareTo(a.publishedAt ?? ''));
        return filteredArticles;
      } else {
        // Handle non-200 status codes
        print('News API error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load news: Status code ${response.statusCode}');
      }
    } on SocketException catch (e) {
      // Handle network connectivity errors
      print('Network error fetching news: $e');
      throw Exception('Network error. Please check your internet connection.');
    } on ClientException catch (e) {
      // Handle other HTTP client errors
      print('HTTP client error fetching news: $e');
      throw Exception('Failed to fetch news data. Please try again later.');
    } on FormatException catch (e) {
      // Handle JSON decoding errors
      print('JSON format error fetching news: $e');
      throw Exception('Failed to process news data. Data format error.');
    } catch (e) {
      // Handle any other unexpected errors
      print('An unexpected error occurred while fetching news: $e');
      throw Exception('An unexpected error occurred while loading news.');
    }
  }
} 