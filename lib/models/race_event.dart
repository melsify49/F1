import 'race_strategy.dart';

class RaceEvent {
  final String id;
  final String name;
  final String country;
  final String city;
  final String circuitName;
  final int totalLaps;
  final int circuitLength;
  final int lapRecord;
  final WeatherType baseWeather;
  final double difficulty;
  final List<String> characteristics;

  RaceEvent({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.circuitName,
    required this.totalLaps,
    required this.circuitLength,
    required this.lapRecord,
    required this.baseWeather,
    required this.difficulty,
    required this.characteristics,
  });

  String get weatherEmoji {
    switch (baseWeather) {
      case WeatherType.dry: return '☀️';
      case WeatherType.changeable: return '🌤️';
      case WeatherType.wet: return '🌧️';
    }
  }

  String get difficultyLevel {
    if (difficulty >= 1.8) return 'صعب جداً 🔴';
    if (difficulty >= 1.4) return 'صعب 🟠';
    if (difficulty >= 1.0) return 'متوسط 🟡';
    return 'سهل 🟢';
  }
}