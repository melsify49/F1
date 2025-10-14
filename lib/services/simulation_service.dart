import 'dart:async';
import 'dart:math';
import 'package:myapp/models/race_event.dart';

import '../models/team.dart';
import '../models/race_strategy.dart';
import '../models/race_result.dart';
import 'game_engine.dart';

class SimulationService {
  final StreamController<Map<String, dynamic>> _raceStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get raceStream => _raceStreamController.stream;

  // في simulation_service.dart - تحديث دالة المحاكاة
  Future<RaceResult> simulateFullRace({
  required Team playerTeam,
  required RaceStrategy strategy,
  required List<Team> aiTeams,
  required int currentRaceNumber,
  RaceEvent? raceEvent,
}) async {
  
  WeatherType initialWeather = raceEvent?.baseWeather ?? _getRandomWeather();
  int totalLaps = raceEvent?.totalLaps ?? 58;
  double difficulty = raceEvent?.difficulty ?? 1.0;

  final result = GameEngine.simulateRace(
    playerTeam: playerTeam,
    strategy: strategy,
    aiTeams: aiTeams,
    weather: initialWeather,
    weatherChanges: true,
    raceDifficulty: difficulty,
    raceEvent: raceEvent!,
  );

  _simulateLiveUpdates(result, initialWeather, true, playerTeam, totalLaps);

  // استخدام المُنشئ مع جميع البيانات
  return RaceResult(
    finalPosition: result['finalPosition'] ?? 0,
    driver1Position: result['driver1Position'] ?? result['finalPosition'] ?? 0,
    driver2Position: result['driver2Position'] ?? result['finalPosition'] ?? 0,
    pointsEarned: result['pointsEarned'] ?? 0,
    prizeMoney: result['prizeMoney'] ?? 0,
    raceEvents: List<String>.from(result['raceEvents'] ?? []),
    overtakes: result['overtakes'] ?? 0,
    fastestLap: result['fastestLap'] ?? false,
    strategyRating: result['strategyRating'] ?? 0,
    completedLaps: result['completedLaps'] ?? totalLaps,
    pitStopLap: result['pitStopLap'] ?? strategy.pitStopLap,
    weather: _parseWeather(result['finalWeather'] ?? initialWeather),
    difficulty: double.tryParse(result['difficulty']?.toString() ?? difficulty.toString()) ?? difficulty,
    raceStandings: List<Map<String, dynamic>>.from(result['raceStandings'] ?? []),
  );
}

// دالة مساعدة لتحويل الطقس
WeatherType _parseWeather(dynamic weatherData) {
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

  void _simulateLiveUpdates(
    Map<String, dynamic> result,
    WeatherType initialWeather,
    bool weatherChanges,
    Team playerTeam,
     int totalLaps,
  ) {
    final events = result['raceEvents'] as List<String>;
    // final totalLaps = 58;
    WeatherType currentWeather = initialWeather;
    int currentPosition = 10; // بداية من المركز 10

    for (int lap = 1; lap <= totalLaps; lap++) {
      Timer(Duration(milliseconds: 200 * lap), () {
        // 🌦️ محاكاة تغير الطقس أثناء السباق
        if (weatherChanges && lap % 15 == 0 && Random().nextDouble() < 0.3) {
          currentWeather = _simulateLapWeatherChange(currentWeather);
        }

        // 🎲 تغيير واقعي في المراكز
        currentPosition = _calculateRealisticPosition(
          lap,
          result['finalPosition'],
          playerTeam,
        );

        Map<String, dynamic> update = {
          'type': 'lap_update',
          'currentLap': lap,
          'totalLaps': totalLaps,
          'position': currentPosition,
          'weather': currentWeather,
        };

        // إضافة أحداث في لفات محددة
        if (lap == 1) {
          update['event'] =
              "🏁 بداية السباق! الطقس: ${_getWeatherName(initialWeather)}";
        } else if (lap == result['pitStopLap']) {
          update['event'] = "🛞 Pit Stop! تغيير الإطارات";
        } else if (events.isNotEmpty && lap % 12 == 0) {
          int eventIndex = (lap ~/ 12 - 1) % events.length;
          if (eventIndex < events.length) {
            update['event'] = events[eventIndex];
          }
        } else if (Random().nextDouble() < 0.1) {
          // أحداث عشوائية أثناء السباق
          update['event'] = _getRandomRaceEvent(lap, currentPosition);
        }

        _raceStreamController.add(update);
      });
    }

    // تحديث النهاية
    Timer(Duration(milliseconds: 200 * totalLaps + 500), () {
      _raceStreamController.add({
        'type': 'race_finished',
        'finalResult': result,
      });
    });
  }

  int _calculateRealisticPosition(int lap, int finalPosition, Team playerTeam) {
    int startPosition = 10;
    double progress = lap / 58.0;

    // 🎲 عنصر عشوائي واقعي
    double randomFactor = 0.8 + Random().nextDouble() * 0.4;

    // 📈 تقدم تدريجي مع تقلبات
    if (progress < 0.2) return startPosition;
    if (progress < 0.4) {
      return (startPosition - 1 * randomFactor).round().clamp(1, 20);
    }
    if (progress < 0.6) {
      return (startPosition - 2 * randomFactor).round().clamp(1, 20);
    }
    if (progress < 0.8) {
      return (startPosition - 3 * randomFactor).round().clamp(1, 20);
    }

    // 📉 تقلبات في النهاية
    int variation = Random().nextInt(3) - 1; // -1, 0, +1
    return (finalPosition + variation).clamp(1, 20);
  }

  String _getRandomRaceEvent(int lap, int position) {
    List<String> events = [
      "🎯 تجاوز ناجح في المنعطف",
      "🔄 فقدان وقت في المنعطف",
      "⚡ سرعة عالية في القطاع المستقيم",
      "🛞 تآكل الإطارات يؤثر على الأداء",
      "⛽ استهلاك وقود جيد",
    ];

    if (position <= 3) {
      events.addAll(["🔥 منافسة شرسة على المركز الأول", "🚀 ضغط على المتصدر"]);
    }

    if (position >= 15) {
      events.addAll([
        "💪 محاولة للعودة للمراكز الأمامية",
        "🛠️ صعوبة في الأداء",
      ]);
    }

    return events[Random().nextInt(events.length)];
  }

  // 🌦️ الحصول على طقس عشوائي
  WeatherType _getRandomWeather() {
    double chance = Random().nextDouble();
    if (chance < 0.6) return WeatherType.dry;
    if (chance < 0.85) return WeatherType.changeable;
    return WeatherType.wet;
  }

  // في simulation_service.dart - عدل الدالة دي
  // void _simulateLiveUpdates(Map<String, dynamic> result, WeatherType initialWeather, bool weatherChanges) {
  //   final events = result['raceEvents'] as List<String>;
  //   final totalLaps = 58; // ✅ تأكد إنها 58 مش 3
  //   WeatherType currentWeather = initialWeather;

  //   for (int lap = 1; lap <= totalLaps; lap++) {
  //     Timer(Duration(milliseconds: 100 * lap), () {

  //       // 🌦️ محاكاة تغير الطقس أثناء السباق
  //       if (weatherChanges && lap % 15 == 0 && Random().nextDouble() < 0.3) {
  //         currentWeather = _simulateLapWeatherChange(currentWeather);
  //       }

  //       Map<String, dynamic> update = {
  //         'type': 'lap_update',
  //         'currentLap': lap,
  //         'totalLaps': totalLaps, // ✅ تأكد إن totalLaps = 58
  //         'position': _calculatePosition(lap, result['finalPosition']),
  //         'weather': currentWeather,
  //       };

  //       // إضافة أحداث في لفات محددة
  //       if (lap == 1) {
  //         update['event'] = "🏁 بداية السباق! الطقس: ${_getWeatherName(initialWeather)}";
  //       } else if (lap == result['pitStopLap']) {
  //         update['event'] = "🛞 Pit Stop!";
  //       } else if (events.isNotEmpty && lap % 12 == 0) {
  //         int eventIndex = (lap ~/ 12 - 1) % events.length;
  //         update['event'] = events[eventIndex];
  //       }

  //       _raceStreamController.add(update);
  //     });
  //   }

  //   // ✅ تأكد إن النهاية بعد كل اللفات
  //   Timer(Duration(milliseconds: 100 * totalLaps + 500), () {
  //     _raceStreamController.add({
  //       'type': 'race_finished',
  //       'finalResult': result,
  //     });
  //   });
  // }
  //   // 🌦️ تغير الطقس أثناء اللفة
  WeatherType _simulateLapWeatherChange(WeatherType currentWeather) {
    double chance = Random().nextDouble();

    switch (currentWeather) {
      case WeatherType.dry:
        return chance < 0.4 ? WeatherType.changeable : WeatherType.dry;
      case WeatherType.changeable:
        if (chance < 0.3) return WeatherType.wet;
        if (chance < 0.6) return WeatherType.dry;
        return WeatherType.changeable;
      case WeatherType.wet:
        return chance < 0.35 ? WeatherType.changeable : WeatherType.wet;
    }
  }

  String _getWeatherName(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry:
        return 'جاف ☀️';
      case WeatherType.changeable:
        return 'غائم 🌤️';
      case WeatherType.wet:
        return 'ممطر 🌧️';
    }
  }

  int _calculatePosition(int lap, int finalPosition) {
    int startPosition = 10;
    double progress = lap / 58.0;

    if (progress < 0.3) return startPosition;
    if (progress < 0.6) return startPosition - 2;
    if (progress < 0.8) return startPosition - 4;
    return finalPosition;
  }

  void dispose() {
    _raceStreamController.close();
  }
}
