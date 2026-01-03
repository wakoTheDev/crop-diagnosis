class Weather {
  final String id;
  final double latitude;
  final double longitude;
  final double? temperature;
  final double? humidity;
  final double? rainfall;
  final double? windSpeed;
  final String? condition;
  final List<WeatherForecast>? forecast;
  final DateTime lastUpdated;
  
  Weather({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.temperature,
    this.humidity,
    this.rainfall,
    this.windSpeed,
    this.condition,
    this.forecast,
    required this.lastUpdated,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
      'wind_speed': windSpeed,
      'condition': condition,
      'forecast_data': forecast?.map((f) => f.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
  
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      id: json['id'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      temperature: json['temperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      rainfall: json['rainfall']?.toDouble(),
      windSpeed: json['wind_speed']?.toDouble(),
      condition: json['condition'],
      forecast: json['forecast_data'] != null
          ? (json['forecast_data'] as List)
              .map((f) => WeatherForecast.fromJson(f))
              .toList()
          : null,
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}

class WeatherForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double rainfall;
  final String condition;
  
  WeatherForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.rainfall,
    required this.condition,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'max_temp': maxTemp,
      'min_temp': minTemp,
      'rainfall': rainfall,
      'condition': condition,
    };
  }
  
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.parse(json['date']),
      maxTemp: json['max_temp'].toDouble(),
      minTemp: json['min_temp'].toDouble(),
      rainfall: json['rainfall'].toDouble(),
      condition: json['condition'],
    );
  }
}
