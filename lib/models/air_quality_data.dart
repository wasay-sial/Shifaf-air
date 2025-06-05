class AirQualityData {
  final double pm25;
  final double pm10;
  final double o3;
  final double no2;
  final double so2;
  final double co;
  final double? nh3;
  final double? no;
  final int aqi;
  final DateTime timestamp;
  final double latitude;
  final double longitude;

  AirQualityData({
    required this.pm25,
    required this.pm10,
    required this.o3,
    required this.no2,
    required this.so2,
    required this.co,
    this.nh3,
    this.no,
    required this.aqi,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    final data = json['list'][0];
    final components = data['components'];
    final main = data['main'];
    final coord = json['coord'];

    return AirQualityData(
      pm25: (components['pm2_5'] ?? 0.0).toDouble(),
      pm10: (components['pm10'] ?? 0.0).toDouble(),
      o3: (components['o3'] ?? 0.0).toDouble(),
      no2: (components['no2'] ?? 0.0).toDouble(),
      so2: (components['so2'] ?? 0.0).toDouble(),
      co: (components['co'] ?? 0.0).toDouble(),
      nh3: (components['nh3'] as num?)?.toDouble() ?? 0.0,
      no: (components['no'] as num?)?.toDouble() ?? 0.0,
      aqi: main['aqi'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000),
      latitude: coord['lat'].toDouble(),
      longitude: coord['lon'].toDouble(),
    );
  }
}
