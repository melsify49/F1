import 'race_strategy.dart';

class RaceResult {
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
  final List<Map<String, dynamic>> raceStandings; // 🆕 ترتيب المتسابقين

  RaceResult({
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
    required this.raceStandings, // 🆕 إضافة raceStandings
  });

  String get positionText {
    if (finalPosition == 1) return "الفائز 🏆";
    if (finalPosition <= 3) return "المركز $finalPosition 🥈";
    if (finalPosition <= 10) return "المركز $finalPosition ✅";
    return "المركز $finalPosition";
  }

  String get weatherText {
    switch (weather) {
      case WeatherType.dry:
        return 'جاف ☀️';
      case WeatherType.changeable:
        return 'متغير 🌤️';
      case WeatherType.wet:
        return 'ممطر 🌧️';
    }
  }

  String get difficultyText {
    if (difficulty <= 0.25) return "سهل 🟢";
    if (difficulty <= 0.5) return "متوسط 🟡";
    if (difficulty <= 0.75) return "صعب 🟠";
    return "خبير 🔴";
  }

  String get driversPerformance {
    if (driver1Position <= 3 && driver2Position <= 3) {
      return "أداء متميز من كلا السائقين! 🏆🏆";
    } else if (driver1Position <= 5 && driver2Position <= 5) {
      return "أداء قوي من الفريق 💪";
    } else if (driver1Position <= 10 || driver2Position <= 10) {
      return "أداء جيد بالنقاط ✅";
    } else {
      return "أداء يحتاج تحسين 📊";
    }
  }

  // 🆕 خاصية للحصول على أفضل مركز في الفريق
  int get bestTeamPosition {
    return driver1Position < driver2Position ? driver1Position : driver2Position;
  }

  // 🆕 خاصية للحصول على إجمالي النقاط
  int get totalPoints {
    return _calculatePoints(driver1Position) + _calculatePoints(driver2Position);
  }

  // 🆕 دالة حساب النقاط
  int _calculatePoints(int position) {
    List<int> pointsSystem = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1];
    return position <= pointsSystem.length ? pointsSystem[position - 1] : 0;
  }

  Map<String, dynamic> toJson() {
    return {
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
      'weather': weather.index,
      'difficulty': difficulty,
      'raceStandings': raceStandings, // 🆕 حفظ ترتيب المتسابقين
    };
  }

  factory RaceResult.fromJson(Map<String, dynamic> json) {
    return RaceResult(
      finalPosition: json['finalPosition'],
      driver1Position: json['driver1Position'] ?? json['finalPosition'],
      driver2Position: json['driver2Position'] ?? json['finalPosition'],
      pointsEarned: json['pointsEarned'],
      prizeMoney: json['prizeMoney'],
      raceEvents: List<String>.from(json['raceEvents']),
      overtakes: json['overtakes'],
      fastestLap: json['fastestLap'],
      strategyRating: json['strategyRating'],
      completedLaps: json['completedLaps'],
      pitStopLap: json['pitStopLap'] ?? 20,
      weather: WeatherType.values[json['weather'] ?? 0],
      difficulty: json['difficulty']?.toDouble() ?? 0.5,
      raceStandings: List<Map<String, dynamic>>.from(json['raceStandings'] ?? []), // 🆕 تحميل ترتيب المتسابقين
    );
  }

  // 🆕 دالة لإنشاء RaceResult من بيانات simulateRace
  factory RaceResult.fromRaceData(Map<String, dynamic> raceData) {
    return RaceResult(
      finalPosition: raceData['finalPosition'],
      driver1Position: raceData['driver1Position'],
      driver2Position: raceData['driver2Position'],
      pointsEarned: raceData['pointsEarned'],
      prizeMoney: raceData['prizeMoney'],
      raceEvents: List<String>.from(raceData['raceEvents']),
      overtakes: raceData['overtakes'],
      fastestLap: raceData['fastestLap'],
      strategyRating: raceData['strategyRating'],
      completedLaps: raceData['completedLaps'],
      pitStopLap: raceData['pitStopLap'],
      weather: _parseWeather(raceData['finalWeather']),
      difficulty: double.tryParse(raceData['difficulty']?.toString() ?? '0.5') ?? 0.5,
      raceStandings: List<Map<String, dynamic>>.from(raceData['raceStandings'] ?? _generateDefaultStandings()), // 🆕 ترتيب المتسابقين
    );
  }

  // 🆕 دالة لإنشاء ترتيب افتراضي إذا لم يكن موجوداً
  static List<Map<String, dynamic>> _generateDefaultStandings() {
    return [
      {
        'position': 1,
        'name': 'فيرستابين',
        'team': 'ريد بول',
        'time': '+0.000',
        'points': 25,
        'isPlayer': false,
        'driverNumber': 1,
      },
      {
        'position': 2,
        'name': 'هاميلتون',
        'team': 'مرسيدس',
        'time': '+5.234',
        'points': 18,
        'isPlayer': false,
        'driverNumber': 1,
      },
      {
        'position': 3,
        'name': 'لوكليرك',
        'team': 'فيراري',
        'time': '+8.567',
        'points': 15,
        'isPlayer': false,
        'driverNumber': 1,
      },
      {
        'position': 4,
        'name': 'ساينز',
        'team': 'فيراري',
        'time': '+12.891',
        'points': 12,
        'isPlayer': false,
        'driverNumber': 2,
      },
      {
        'position': 5,
        'name': 'بيريز',
        'team': 'ريد بول',
        'time': '+15.234',
        'points': 10,
        'isPlayer': false,
        'driverNumber': 2,
      },
    ];
  }

  // 🆕 دالة مساعدة لتحويل الطقس
  static WeatherType _parseWeather(dynamic weatherData) {
    if (weatherData is WeatherType) {
      return weatherData;
    } else if (weatherData is String) {
      switch (weatherData) {
        case 'dry': return WeatherType.dry;
        case 'wet': return WeatherType.wet;
        case 'changeable': return WeatherType.changeable;
        default: return WeatherType.dry;
      }
    } else {
      return WeatherType.dry;
    }
  }

  // 🆕 دالة للحصول على ترتيب السائقين في الفريق
  List<Map<String, dynamic>> get teamDriversStandings {
    return raceStandings.where((driver) {
      final isPlayerDriver1 = driver['name'].toString().contains('سائق 1') || driver['isPlayer'] == true;
      final isPlayerDriver2 = driver['name'].toString().contains('سائق 2') || driver['isPlayer'] == true;
      return isPlayerDriver1 || isPlayerDriver2;
    }).toList();
  }

  // 🆕 دالة للحصول على ترتيب المتسابقين مع تمييز اللاعب
  List<Map<String, dynamic>> getStandingsWithPlayerHighlight() {
    return raceStandings.map((driver) {
      return {
        ...driver,
        'isHighlighted': driver['isPlayer'] == true,
      };
    }).toList();
  }
}