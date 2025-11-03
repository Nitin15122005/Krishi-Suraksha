class AppWeather {
  final double temperature;
  final double humidity;
  final double precipitation;
  final double windSpeed;
  final int weatherCode;
  final String weatherCondition;

  AppWeather({
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.weatherCode,
    required this.weatherCondition,
  });

  // Factory constructor to parse the JSON
  factory AppWeather.fromJson(Map<String, dynamic> json) {
    return AppWeather(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      weatherCode: (json['weatherCode'] as num).toInt(),
      weatherCondition: json['weatherCondition'] as String,
    );
  }
}