// في ملف race_result.dart - تحديث النموذج
// [file name]: race_result.dart (محدث)
// [file content begin]
import 'package:myapp/models/race_strategy.dart';

class RaceResult {
  final String raceId;
  final String raceName;
  final int round;
  final String teamId;
  final int finalPosition;
  final int driver1Position;
  final int driver2Position;
  final int pointsEarned;
  final int prizeMoney;
  final List<String> raceEvents;
  final int overtakes;
  final bool fastestLap;
  final int strategyRating;
  final int completedLaps;
  final int pitStopLap;
  final WeatherType weather;
  final double difficulty;
  final List<Map<String, dynamic>> raceStandings;
  final String driver1Name; // جديد
  final String driver2Name; // جديد
  final DateTime raceDate; // جديد

  RaceResult({
    required this.raceId,
    required this.raceName,
    required this.round,
    required this.teamId,
    required this.finalPosition,
    required this.driver1Position,
    required this.driver2Position,
    required this.pointsEarned,
    required this.prizeMoney,
    required this.raceEvents,
    required this.overtakes,
    required this.fastestLap,
    required this.strategyRating,
    required this.completedLaps,
    required this.pitStopLap,
    required this.weather,
    required this.difficulty,
    required this.raceStandings,
    required this.driver1Name,
    required this.driver2Name,
    required this.raceDate,
  });

  // تحديث دالة toJson و fromJson لإضافة الحقول الجديدة
  Map<String, dynamic> toJson() {
    return {
      'raceId': raceId,
      'raceName': raceName,
      'round': round,
      'teamId': teamId,
      'finalPosition': finalPosition,
      'driver1Position': driver1Position,
      'driver2Position': driver2Position,
      'pointsEarned': pointsEarned,
      'prizeMoney': prizeMoney,
      'raceEvents': raceEvents,
      'overtakes': overtakes,
      'fastestLap': fastestLap,
      'strategyRating': strategyRating,
      'completedLaps': completedLaps,
      'pitStopLap': pitStopLap,
      'weather': weather.toString(),
      'difficulty': difficulty,
      'raceStandings': raceStandings,
      'driver1Name': driver1Name,
      'driver2Name': driver2Name,
      'raceDate': raceDate.toIso8601String(),
    };
  }

  factory RaceResult.fromJson(Map<String, dynamic> json) {
    return RaceResult(
      raceId: json['raceId'],
      raceName: json['raceName'],
      round: json['round'],
      teamId: json['teamId'],
      finalPosition: json['finalPosition'],
      driver1Position: json['driver1Position'],
      driver2Position: json['driver2Position'],
      pointsEarned: json['pointsEarned'],
      prizeMoney: json['prizeMoney'],
      raceEvents: List<String>.from(json['raceEvents']),
      overtakes: json['overtakes'],
      fastestLap: json['fastestLap'],
      strategyRating: json['strategyRating'],
      completedLaps: json['completedLaps'],
      pitStopLap: json['pitStopLap'],
      weather: _parseWeather(json['weather']),
      difficulty: (json['difficulty'] as num).toDouble(),
      raceStandings: List<Map<String, dynamic>>.from(json['raceStandings']),
      driver1Name: json['driver1Name'],
      driver2Name: json['driver2Name'],
      raceDate: DateTime.parse(json['raceDate']),
    );
  }

  static WeatherType _parseWeather(String weather) {
    switch (weather) {
      case 'WeatherType.dry': return WeatherType.dry;
      case 'WeatherType.wet': return WeatherType.wet;
      case 'WeatherType.changeable': return WeatherType.changeable;
      default: return WeatherType.dry;
    }
  }
}
// [file content end]