import 'dart:math';
import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../models/race_event.dart';
import '../models/team.dart';
import '../models/race_strategy.dart';
import '../models/race_result.dart';

class AdvancedRaceEngine {
  static final Random _random = Random();
  static Map<String, List<RaceStrategy>> _playerStrategyHistory = {};
  static Map<String, int> _playerWinStreak = {};

  // 🏎️ محاكاة السباق الرئيسية المتقدمة
  static Map<String, dynamic> simulateAdvancedRace({
    required Team playerTeam,
    required RaceStrategy strategy,
    required List<Team> aiTeams,
    required RaceEvent raceEvent,
    WeatherType initialWeather = WeatherType.dry,
    double raceDifficulty = 0.5,
  }) {
    List<LapData> lapData = [];
    List<DynamicRaceEvent> raceEvents = [];
    Map<String, CarStatus> carStatuses = {};

    // 🌦️ نظام طقس ديناميكي
    WeatherSimulation weatherSim = WeatherSimulation(initialWeather);

    // 🏁 تهيئة حالة جميع السيارات
    _initializeCarStatuses(carStatuses, playerTeam, aiTeams, strategy);

    // 🏎️ محاكاة كل لفة بشكل منفصل
    for (int lap = 1; lap <= raceEvent.totalLaps; lap++) {
      WeatherType currentWeather = weatherSim.getWeatherForLap(lap);

      // محاكاة لفة لكل متسابق
      LapData currentLapData = _simulateLap(
        lap: lap,
        playerTeam: playerTeam,
        aiTeams: aiTeams,
        carStatuses: carStatuses,
        weather: currentWeather,
        difficulty: raceDifficulty,
        strategy: strategy,
      );

      lapData.add(currentLapData);

      // توليد أحداث خلال اللفة
      raceEvents.addAll(
        _generateLapEvents(
          lap,
          currentLapData,
          carStatuses[playerTeam.id]!,
          currentWeather,
          raceDifficulty,
        ),
      );

      // تحديث استهلاك الوقود وتآكل الإطارات
      _updateCarStatusForLap(
        carStatuses,
        lap,
        currentWeather,
        strategy,
        raceDifficulty,
      );

      // Pit Stop تلقائي
      _handlePitStops(carStatuses, lap, strategy, raceEvents, playerTeam.id);

      // تغييرات في الترتيب
      _updateRacePositions(carStatuses, currentLapData);

      // كشف نهاية السباق
      if (lap == raceEvent.totalLaps) {
        break;
      }
    }

    return _calculateFinalResults(
      lapData,
      raceEvents,
      carStatuses,
      playerTeam,
      aiTeams,
      raceDifficulty,
    );
  }

  // 🏁 تهيئة حالة السيارات
  static void _initializeCarStatuses(
    Map<String, CarStatus> carStatuses,
    Team playerTeam,
    List<Team> aiTeams,
    RaceStrategy strategy,
  ) {
    // سائق اللاعب 1
    carStatuses['${playerTeam.id}_1'] = CarStatus(
      teamId: playerTeam.id,
      isDriver1: true,
      tireType: strategy.tireChoice,
      currentPosition: 10, // بداية من المركز 10
    );

    // سائق اللاعب 2
    carStatuses['${playerTeam.id}_2'] = CarStatus(
      teamId: playerTeam.id,
      isDriver1: false,
      tireType: strategy.tireChoice,
      currentPosition: 15, // بداية من المركز 15
    );

    // سائقي الـ AI
    for (int i = 0; i < aiTeams.length; i++) {
      RaceStrategy aiStrategy = _generateSmartAIStrategy(
        initialWeather: WeatherType.dry,
        playerId: playerTeam.id,
        aiIndex: i,
        playerTeam: playerTeam,
        difficulty: 0.5,
      );

      carStatuses['${aiTeams[i].id}_1'] = CarStatus(
        teamId: aiTeams[i].id,
        isDriver1: true,
        tireType: aiStrategy.tireChoice,
        currentPosition: i * 2 + 1,
      );

      carStatuses['${aiTeams[i].id}_2'] = CarStatus(
        teamId: aiTeams[i].id,
        isDriver1: false,
        tireType: aiStrategy.tireChoice,
        currentPosition: i * 2 + 2,
      );
    }
  }

  // 🏎️ محاكاة لفة فردية بدقة عالية
  static LapData _simulateLap({
    required int lap,
    required Team playerTeam,
    required List<Team> aiTeams,
    required Map<String, CarStatus> carStatuses,
    required WeatherType weather,
    required double difficulty,
    required RaceStrategy strategy,
  }) {
    Map<String, double> lapTimes = {};
    Map<String, double> sectorTimes = {};
    Map<String, List<String>> lapEvents = {};

    // محاكاة كل متسابق بشكل منفصل
    for (String carId in carStatuses.keys) {
      CarStatus status = carStatuses[carId]!;
      if (status.inPit) continue; // تخطي السيارات في Pit Stop

      bool isPlayer = carId.startsWith(playerTeam.id);
      Team team = isPlayer
          ? playerTeam
          : aiTeams.firstWhere((t) => carId.startsWith(t.id));

      // حساب وقت اللفة مع عوامل متعددة
      double lapTime = _calculateLapTime(
        team: team,
        carStatus: status,
        weather: weather,
        difficulty: difficulty,
        isPlayer: isPlayer,
        strategy: strategy,
        lap: lap,
      );

      lapTimes[carId] = lapTime;

      // أوقات القطاعات
      sectorTimes[carId] = _calculateSectorTimes(lapTime, status, weather);

      // أحداث اللفة
      lapEvents[carId] = _generateDriverEvents(
        carId,
        status,
        weather,
        difficulty,
        isPlayer,
      );
    }

    return LapData(
      lapNumber: lap,
      lapTimes: lapTimes,
      sectorTimes: sectorTimes,
      lapEvents: lapEvents,
      weather: weather,
    );
  }

  // ⏱️ حساب وقت اللفة بدقة عالية
  static double _calculateLapTime({
    required Team team,
    required CarStatus carStatus,
    required WeatherType weather,
    required double difficulty,
    required bool isPlayer,
    required RaceStrategy strategy,
    required int lap,
  }) {
    double baseTime = 85.0; // وقت أساسي للفة

    // تأثير الأداء العام للفريق
    double teamPerformance = team.overallPerformance / 100.0;
    baseTime *= (1.1 - (teamPerformance * 0.2));

    // تأثير السائق
    Driver driver = carStatus.isDriver1 ? team.driver1 : team.driver2;
    double driverSkill = driver.overallRating / 100.0;
    baseTime *= (1.05 - (driverSkill * 0.1));

    // تأثير الإطارات
    double tireEffect = _calculateTireEffect(
      carStatus.tireWear,
      carStatus.tireType,
      weather,
    );
    baseTime *= tireEffect;

    // تأثير الوقود (السيارة أخف مع انخفاض الوقود)
    double fuelEffect = 1.0 + (carStatus.fuelLevel / 100.0 * 0.1);
    baseTime *= fuelEffect;

    // تأثير الطقس
    double weatherEffect = _calculateWeatherEffect(weather, carStatus.tireType);
    baseTime *= weatherEffect;

    // تأثير الإستراتيجية
    double strategyEffect = _calculateStrategyEffect(
      strategy,
      weather,
      lap,
      isPlayer,
    );
    baseTime *= strategyEffect;

    // عنصر عشوائي واقعي
    double randomVariation = _calculateRandomVariation(difficulty, isPlayer);
    baseTime *= randomVariation;

    // تأثير الزخم وDRS
    double momentumEffect = _calculateMomentumEffect(carStatus, lap);
    baseTime *= momentumEffect;

    return baseTime;
  }

  // 🛞 تأثير حالة الإطارات
  static double _calculateTireEffect(
    double tireWear,
    TireType tireType,
    WeatherType weather,
  ) {
    double baseEffect = 1.0;

    // تأثير التآكل
    if (tireWear > 80)
      baseEffect = 1.0;
    else if (tireWear > 60)
      baseEffect = 1.02;
    else if (tireWear > 40)
      baseEffect = 1.05;
    else if (tireWear > 20)
      baseEffect = 1.08;
    else
      baseEffect = 1.12;

    // تأثير عدم توافق الإطارات مع الطقس
    if (weather == WeatherType.wet && tireType != TireType.wet) {
      baseEffect *= 1.15;
    } else if (weather == WeatherType.dry && tireType == TireType.wet) {
      baseEffect *= 1.12;
    }

    return baseEffect;
  }

  // 🌦️ تأثير الطقس
  static double _calculateWeatherEffect(
    WeatherType weather,
    TireType tireType,
  ) {
    switch (weather) {
      case WeatherType.dry:
        return tireType == TireType.wet ? 1.08 : 1.0;
      case WeatherType.changeable:
        return 1.03;
      case WeatherType.wet:
        return tireType == TireType.wet ? 1.05 : 1.25;
    }
  }

  // 🎯 تأثير الإستراتيجية
  static double _calculateStrategyEffect(
    RaceStrategy strategy,
    WeatherType weather,
    int lap,
    bool isPlayer,
  ) {
    double effect = 1.0;

    // تأثير العدوانية
    switch (strategy.aggression) {
      case AggressionLevel.aggressive:
        effect *= isPlayer ? 0.98 : 0.99; // أسرع ولكن مخاطرة أعلى
        break;
      case AggressionLevel.conservative:
        effect *= isPlayer ? 1.02 : 1.01; // أبطأ ولكن أكثر أماناً
        break;
      case AggressionLevel.balanced:
        effect *= 1.0;
        break;
    }

    // تأثير توقيت Pit Stop
    if (lap == strategy.pitStopLap && isPlayer) {
      effect *= 1.15; // عقوبة Pit Stop
    }

    // تأثير تعديل الطقس
    if (strategy.weatherAdjustment) {
      effect *= 0.99;
    }

    return effect;
  }

  // 🎲 عنصر عشوائي واقعي
  static double _calculateRandomVariation(double difficulty, bool isPlayer) {
    double baseVariation = 0.02; // ±2% تغيير

    if (isPlayer) {
      // لاعب: عشوائية أقل في المستويات الصعبة
      baseVariation *= (1.5 - difficulty);
    } else {
      // AI: عشوائية أكثر ذكاءً
      baseVariation *= (0.8 + difficulty * 0.4);
    }

    return 1.0 + (_random.nextDouble() * 2 - 1) * baseVariation;
  }

  // 🚀 تأثير الزخم وDRS
  static double _calculateMomentumEffect(CarStatus carStatus, int lap) {
    double effect = 1.0;

    // تأثير الزخم (أداء أفضل بعد التجاوزات الناجحة)
    if (carStatus.consecutiveOvertakes > 0) {
      effect *= (1.0 - (carStatus.consecutiveOvertakes * 0.005));
    }

    // تأثير DRS (في القطاعات المستقيمة)
    if (carStatus.hasDRS) {
      effect *= 0.995;
    }

    // تأثير إعياء السائق
    if (lap > 40) {
      effect *= 1.005;
    }

    // تأثير الضغط في المراكز المتقدمة
    if (carStatus.currentPosition <= 3) {
      effect *= 0.998;
    }

    return effect;
  }

  // ⏱️ حساب أوقات القطاعات
  static double _calculateSectorTimes(
    double lapTime,
    CarStatus status,
    WeatherType weather,
  ) {
    // توزيع وقت اللفة على 3 قطاعات مع تأثيرات مختلفة
    double sector1 = lapTime * 0.32; // قطاع مستقيمي
    double sector2 = lapTime * 0.36; // قطاع منعطفات
    double sector3 = lapTime * 0.32; // قطاع مختلط

    // تأثير DRS على القطاع المستقيم
    if (status.hasDRS) {
      sector1 *= 0.99;
    }

    // تأثير الإطارات على قطاع المنعطفات
    if (status.tireWear < 50) {
      sector2 *= 1.03;
    }

    return sector1 + sector2 + sector3;
  }

  // 🎲 توليد أحداث السائق خلال اللفة
  static List<String> _generateDriverEvents(
    String carId,
    CarStatus status,
    WeatherType weather,
    double difficulty,
    bool isPlayer,
  ) {
    List<String> events = [];

    // أحداث التجاوز
    if (status.consecutiveOvertakes > 0 && _random.nextDouble() < 0.3) {
      events.add("🎯 تجاوز ناجح للمركز ${status.currentPosition}");
    }

    // أحداث الأخطاء
    if (_random.nextDouble() < _getMistakeChance(difficulty, isPlayer)) {
      List<String> mistakes = [
        "⚠️ خطأ في المنعطف - فقد 0.3 ثانية",
        "🔄 خروج بسيط عن المسار - فقد 0.5 ثانية",
        "🎯 تجاوز فاشل - خسر وقتاً",
      ];
      events.add(mistakes[_random.nextInt(mistakes.length)]);
    }

    // أحداث related إلى حالة السيارة
    if (status.tireWear < 30 && _random.nextDouble() < 0.4) {
      events.add("🔄 الإطارات متآكلة بشدة - تأثر الأداء");
    }

    if (status.fuelLevel < 20 && _random.nextDouble() < 0.4) {
      events.add("⛽ الوقود منخفض - تقليل الأداء");
    }

    return events;
  }

  static double _getMistakeChance(double difficulty, bool isPlayer) {
    double baseChance = 0.1;

    if (isPlayer) {
      return baseChance * (0.5 + difficulty * 0.5);
    } else {
      return baseChance * (1.0 - difficulty * 0.3);
    }
  }

  // ⛽ تحديث حالة السيارة بعد كل لفة
  static void _updateCarStatusForLap(
    Map<String, CarStatus> carStatuses,
    int lap,
    WeatherType weather,
    RaceStrategy strategy,
    double difficulty,
  ) {
    carStatuses.forEach((carId, status) {
      if (status.inPit) {
        status.pitStopTimeRemaining -= 1000; // تقليل وقت Pit Stop
        if (status.pitStopTimeRemaining <= 0) {
          status.inPit = false;
          status.tireWear = 100.0;
          status.fuelLevel = 100.0;
        }
        return;
      }

      // استهلاك الوقود
      double fuelConsumption = _calculateFuelConsumption(
        strategy,
        weather,
        difficulty,
        status,
      );
      status.fuelLevel = (status.fuelLevel - fuelConsumption).clamp(0, 100);

      // تآكل الإطارات
      double tireWear = _calculateTireWear(
        strategy,
        weather,
        lap,
        difficulty,
        status,
      );
      status.tireWear = (status.tireWear - tireWear).clamp(0, 100);

      // تحديث الزخم
      status.updateMomentum();

      // تحديث DRS
      status.hasDRS = _shouldHaveDRS(status, lap);
    });
  }

  static double _calculateFuelConsumption(
    RaceStrategy strategy,
    WeatherType weather,
    double difficulty,
    CarStatus status,
  ) {
    double baseConsumption = 1.8; // كجم/لفة

    // تأثير العدوانية
    switch (strategy.aggression) {
      case AggressionLevel.aggressive:
        baseConsumption *= 1.4;
        break;
      case AggressionLevel.conservative:
        baseConsumption *= 0.7;
        break;
      case AggressionLevel.balanced:
        baseConsumption *= 1.0;
        break;
    }

    // تأثير الطقس
    switch (weather) {
      case WeatherType.wet:
        baseConsumption *= 1.3;
        break;
      case WeatherType.changeable:
        baseConsumption *= 1.15;
        break;
      case WeatherType.dry:
        baseConsumption *= 1.0;
        break;
    }

    // تأثير تقدم السباق (السيارة أخف مع انخفاض الوقود)
    double lapFactor = 1.0 - (status.fuelLevel / 100.0 * 0.1);
    baseConsumption *= lapFactor;

    return baseConsumption.clamp(0.5, 3.0);
  }

  static double _calculateTireWear(
    RaceStrategy strategy,
    WeatherType weather,
    int lap,
    double difficulty,
    CarStatus status,
  ) {
    double wear = 0.0;

    // التآكل الأساسي حسب نوع الإطار
    switch (status.tireType) {
      case TireType.soft:
        wear = 2.0 + (lap * 0.025); // تآكل سريع
        break;
      case TireType.medium:
        wear = 1.4 + (lap * 0.018);
        break;
      case TireType.hard:
        wear = 0.9 + (lap * 0.012); // تآكل بطيء
        break;
      case TireType.wet:
        wear = 1.6 + (lap * 0.020);
        break;
    }

    // تأثير الطقس
    if (weather == WeatherType.wet && status.tireType != TireType.wet) {
      wear *= 2.2; // تآكل سريع جداً
    } else if (weather == WeatherType.dry && status.tireType == TireType.wet) {
      wear *= 1.9; // تآكل سريع على الأرض الجافة
    }

    // تأثير درجة حرارة الطريق
    if (weather == WeatherType.dry) {
      wear *= 1.1; // تآكل أعلى في الطقس الحار
    }

    // تأثير الصعوبة
    wear *= (0.8 + difficulty * 0.4);

    return wear.clamp(0.5, 3.0);
  }

  // 🔧 نظام Pit Stop متقدم
  static void _handlePitStops(
    Map<String, CarStatus> carStatuses,
    int currentLap,
    RaceStrategy strategy,
    List<DynamicRaceEvent> raceEvents,
    String playerTeamId,
  ) {
    carStatuses.forEach((carId, status) {
      bool isPlayer = carId.startsWith(playerTeamId);

      // Pit Stop تلقائي بناء على الإستراتيجية
      if (currentLap == strategy.pitStopLap && isPlayer && !status.inPit) {
        _executePitStop(status, strategy, currentLap, raceEvents, true);
      }

      // Pit Stop طارئ بسبب الإطارات أو الوقود
      if (!status.inPit && _needsEmergencyPitStop(status)) {
        _executeEmergencyPitStop(status, currentLap, raceEvents, isPlayer);
      }

      // Pit Stop للـ AI
      if (!isPlayer && !status.inPit && _shouldAIPitStop(status, currentLap)) {
        _executePitStop(status, strategy, currentLap, raceEvents, false);
      }
    });
  }

  static void _executePitStop(
    CarStatus status,
    RaceStrategy strategy,
    int lap,
    List<DynamicRaceEvent> events,
    bool isPlayer,
  ) {
    status.inPit = true;
    int totalTime = _calculatePitStopTime(strategy, status);
    status.pitStopTimeRemaining = totalTime;

    String teamType = isPlayer ? "فريقك" : "المنافس";

    events.add(
      DynamicRaceEvent(
        type: EventType.pitStop,
        lap: lap,
        message: "🛞 $teamType - Pit Stop ${totalTime ~/ 1000} ثانية",
        affectedTeam: status.teamId,
        severity: EventSeverity.info,
      ),
    );
  }

  static int _calculatePitStopTime(RaceStrategy strategy, CarStatus status) {
    int baseTime = 22000; // 22 ثانية أساسية

    // وقت تغيير الإطارات
    switch (strategy.tireChoice) {
      case TireType.soft:
        baseTime += 1000;
        break;
      case TireType.medium:
        baseTime += 1500;
        break;
      case TireType.hard:
        baseTime += 2000;
        break;
      case TireType.wet:
        baseTime += 2500;
        break;
    }

    // وقت التزود بالوقود
    int fuelTime = ((100 - status.fuelLevel) * 20).toInt();
    baseTime += fuelTime;

    // أخطاء الطاقم (عشوائية)
    if (_random.nextDouble() < 0.05) {
      baseTime += 3000; // خطأ في التثبيت
    }

    return baseTime;
  }

  static bool _needsEmergencyPitStop(CarStatus status) {
    return status.tireWear < 20 || status.fuelLevel < 15;
  }

  static bool _shouldAIPitStop(CarStatus status, int lap) {
    return (lap > 20 && status.tireWear < 40) ||
        (lap > 30 && status.fuelLevel < 30);
  }

  static void _executeEmergencyPitStop(
    CarStatus status,
    int lap,
    List<DynamicRaceEvent> events,
    bool isPlayer,
  ) {
    status.inPit = true;
    int emergencyTime = 25000; // Pit Stop طارئ أطول

    String teamType = isPlayer ? "فريقك" : "المنافس";
    String reason = status.tireWear < 20 ? "الإطارات" : "الوقود";

    events.add(
      DynamicRaceEvent(
        type: EventType.pitStop,
        lap: lap,
        message:
            "🆘 $teamType - Pit Stop طارئ ($reason) ${emergencyTime ~/ 1000} ثانية",
        affectedTeam: status.teamId,
        severity: EventSeverity.warning,
      ),
    );

    status.pitStopTimeRemaining = emergencyTime;
    status.tireWear = 100.0;
    status.fuelLevel = 100.0;
  }

  // 🏁 تحديث المراكز بشكل واقعي
  static void _updateRacePositions(
    Map<String, CarStatus> carStatuses,
    LapData lapData,
  ) {
    // ترتيب السيارات بناء على وقت اللفة
    List<MapEntry<String, double>> sortedTimes =
        lapData.lapTimes.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

    // تحديث مراكز جميع المتسابقين
    for (int i = 0; i < sortedTimes.length; i++) {
      String carId = sortedTimes[i].key;
      CarStatus status = carStatuses[carId]!;

      int newPosition = i + 1;

      // حساب التجاوزات
      if (newPosition < status.currentPosition) {
        status.consecutiveOvertakes++;
        status.totalOvertakes += (status.currentPosition - newPosition);
      } else if (newPosition > status.currentPosition) {
        status.consecutiveOvertakes = 0;
      }

      status.currentPosition = newPosition;
      status.lastLapTime = sortedTimes[i].value;
    }
  }

  static bool _shouldHaveDRS(CarStatus status, int lap) {
    return status.currentPosition > 1 && lap > 2 && _random.nextDouble() < 0.7;
  }

  // 🎲 توليد أحداث اللفة
  static List<DynamicRaceEvent> _generateLapEvents(
    int lap,
    LapData lapData,
    CarStatus playerStatus,
    WeatherType weather,
    double difficulty,
  ) {
    List<DynamicRaceEvent> events = [];

    // أحداث الطقس
    if (lap == 1) {
      events.add(
        DynamicRaceEvent(
          type: EventType.weather,
          lap: lap,
          message: _getWeatherMessage(weather),
          severity: EventSeverity.info,
        ),
      );
    }

    // أحداث الأداء
    if (playerStatus.consecutiveOvertakes >= 2) {
      events.add(
        DynamicRaceEvent(
          type: EventType.overtake,
          lap: lap,
          message:
              "🚀 زخم قوي! ${playerStatus.consecutiveOvertakes} تجاوزات متتالية",
          severity: EventSeverity.success,
        ),
      );
    }

    // أحداث عشوائية
    if (_random.nextDouble() < 0.1) {
      events.add(
        DynamicRaceEvent(
          type: EventType.incident,
          lap: lap,
          message: _getRandomIncident(),
          severity: EventSeverity.warning,
        ),
      );
    }

    return events;
  }

  static String _getWeatherMessage(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry:
        return "☀️ طقس جاف - ظروف مثالية";
      case WeatherType.changeable:
        return "🌤️ طقس متغير - كن مستعداً لأي تغيير";
      case WeatherType.wet:
        return "🌧️ طقس ممطر - إطارات مطرية مطلوبة";
    }
  }

  static String _getRandomIncident() {
    List<String> incidents = [
      "🚩 سيارة安全 في منطقة الهروب",
      "🔄 تحطم بين سيارتين في المنعطف الأخير",
      "⚡ مشكلة تقنية لأحد المنافسين",
      "🛑 سيارة تخرج من السباق",
    ];
    return incidents[_random.nextInt(incidents.length)];
  }

  // 📊 حساب النتائج النهائية
  static Map<String, dynamic> _calculateFinalResults(
    List<LapData> lapData,
    List<DynamicRaceEvent> raceEvents,
    Map<String, CarStatus> carStatuses,
    Team playerTeam,
    List<Team> aiTeams,
    double difficulty,
  ) {
    // حساب إجمالي الأوقات
    Map<String, double> totalTimes = {};
    for (LapData lap in lapData) {
      lap.lapTimes.forEach((carId, time) {
        totalTimes[carId] = (totalTimes[carId] ?? 0) + time;
      });
    }

    // ترتيب النهائي
    List<MapEntry<String, double>> sortedTimes = totalTimes.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // إيجاد مركز اللاعب
    int playerPosition = _getPlayerPosition(sortedTimes, playerTeam.id);
    int playerPoints = _calculatePoints(playerPosition);

    return {
      'finalPosition': playerPosition,
      'totalLaps': lapData.length,
      'raceEvents': raceEvents.map((e) => e.toMap()).toList(),
      'pointsEarned': playerPoints,
      'prizeMoney': _calculatePrizeMoney(playerPosition, difficulty),
      'fastestLap': _getFastestLap(lapData, playerTeam.id),
      'overtakes': _getPlayerOvertakes(carStatuses, playerTeam.id),
      'strategyRating': _calculateAdvancedStrategyRating(
        lapData,
        carStatuses,
        playerTeam.id,
        playerPosition,
        difficulty,
      ),
      'raceStandings': _generateDetailedStandings(
        sortedTimes,
        playerTeam,
        aiTeams,
        carStatuses,
      ),
      'lapAnalysis': _generateLapAnalysis(lapData, playerTeam.id),

      'carStatus': _getFinalCarStatus(carStatuses, playerTeam.id),
      'difficultyLevel': _getDifficultyText(difficulty),
    };
  }

  static int _getPlayerPosition(
    List<MapEntry<String, double>> sortedTimes,
    String playerTeamId,
  ) {
    for (int i = 0; i < sortedTimes.length; i++) {
      if (sortedTimes[i].key.startsWith(playerTeamId)) {
        return i + 1;
      }
    }
    return sortedTimes.length;
  }

  static int _getPlayerOvertakes(
    Map<String, CarStatus> carStatuses,
    String playerTeamId,
  ) {
    int totalOvertakes = 0;
    carStatuses.forEach((carId, status) {
      if (carId.startsWith(playerTeamId)) {
        totalOvertakes += status.totalOvertakes;
      }
    });
    return totalOvertakes;
  }

  static bool _getFastestLap(List<LapData> lapData, String playerTeamId) {
    double fastestTime = double.infinity;
    String fastestCar = '';

    for (LapData lap in lapData) {
      lap.lapTimes.forEach((carId, time) {
        if (time < fastestTime) {
          fastestTime = time;
          fastestCar = carId;
        }
      });
    }

    return fastestCar.startsWith(playerTeamId);
  }

  static int _calculatePoints(int position) {
    List<int> pointsSystem = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1];
    return position <= pointsSystem.length ? pointsSystem[position - 1] : 0;
  }

  static int _calculatePrizeMoney(int position, double difficulty) {
    List<int> basePrizeSystem = [
      1000000,
      750000,
      500000,
      400000,
      300000,
      250000,
      200000,
      150000,
      100000,
      50000,
      25000,
      20000,
      15000,
      10000,
      5000,
      2500,
      2000,
      1500,
      1000,
      500,
    ];

    int basePrize = position <= basePrizeSystem.length
        ? basePrizeSystem[position - 1]
        : 1000;

    // مضاعفة الجوائز في المستويات الصعبة
    if (difficulty <= 0.25) {
      return basePrize;
    } else if (difficulty <= 0.5) {
      return (basePrize * 1.2).toInt();
    } else if (difficulty <= 0.75) {
      return (basePrize * 1.5).toInt();
    } else {
      return basePrize * 2;
    }
  }

  static int _calculateAdvancedStrategyRating(
    List<LapData> lapData,
    Map<String, CarStatus> carStatuses,
    String playerTeamId,
    int finalPosition,
    double difficulty,
  ) {
    int rating = 50;

    // تأثير المركز النهائي
    rating += (11 - finalPosition) * 5;

    // تأثير التجاوزات
    int overtakes = _getPlayerOvertakes(carStatuses, playerTeamId);
    rating += overtakes * 2;

    // تأثير الاتساق في الأداء
    double consistency = _calculateConsistency(lapData, playerTeamId);
    rating += (consistency ~/ 10);

    // تأثير إستراتيجية Pit Stop
    rating += _evaluatePitStopStrategy(lapData, carStatuses, playerTeamId);

    // تأثير الصعوبة
    rating = (rating * _getRatingMultiplier(difficulty)).toInt();

    return rating.clamp(0, 100);
  }

  static double _calculateConsistency(
    List<LapData> lapData,
    String playerTeamId,
  ) {
    List<double> playerLapTimes = lapData
        .map((data) => data.lapTimes[playerTeamId + '_1'] ?? 0)
        .where((time) => time > 0)
        .toList();

    if (playerLapTimes.length < 2) return 0.0;

    double average =
        playerLapTimes.reduce((a, b) => a + b) / playerLapTimes.length;
    double variance =
        playerLapTimes
            .map((time) => pow(time - average, 2))
            .reduce((a, b) => a + b) /
        playerLapTimes.length;
    return (1.0 / (sqrt(variance) + 1)) * 100;
  }

  static int _evaluatePitStopStrategy(
    List<LapData> lapData,
    Map<String, CarStatus> carStatuses,
    String playerTeamId,
  ) {
    CarStatus? playerStatus = carStatuses[playerTeamId + '_1'];
    if (playerStatus == null) return 0;

    // تحليل تأثير Pit Stop على الأداء
    int rating = 0;

    // تحسين الأداء بعد Pit Stop
    for (int i = 1; i < lapData.length; i++) {
      if (lapData[i].lapTimes[playerTeamId + '_1']! <
          lapData[i - 1].lapTimes[playerTeamId + '_1']! * 0.98) {
        rating += 5;
      }
    }

    return rating.clamp(0, 20);
  }

  static double _getRatingMultiplier(double difficulty) {
    if (difficulty <= 0.25) return 0.9;
    if (difficulty <= 0.5) return 1.0;
    if (difficulty <= 0.75) return 1.1;
    return 1.2;
  }

  static List<Map<String, dynamic>> _generateDetailedStandings(
    List<MapEntry<String, double>> sortedTimes,
    Team playerTeam,
    List<Team> aiTeams,
    Map<String, CarStatus> carStatuses,
  ) {
    List<Map<String, dynamic>> standings = [];

    for (int i = 0; i < sortedTimes.length; i++) {
      String carId = sortedTimes[i].key;
      CarStatus status = carStatuses[carId]!;
      bool isPlayer = carId.startsWith(playerTeam.id);
      Team team = isPlayer
          ? playerTeam
          : aiTeams.firstWhere((t) => carId.startsWith(t.id));
      Driver driver = status.isDriver1 ? team.driver1 : team.driver2;

      standings.add({
        'position': i + 1,
        'name': isPlayer
            ? '${driver.name} (سائق ${status.isDriver1 ? 1 : 2})'
            : driver.name,
        'team': team.name,
        'time': _formatRaceTime(sortedTimes[i].value),
        'gap': i == 0
            ? '0.000'
            : '+${(sortedTimes[i].value - sortedTimes[0].value).toStringAsFixed(3)}',
        'points': _calculatePoints(i + 1),
        'isPlayer': isPlayer,
        'driverNumber': status.isDriver1 ? 1 : 2,
        'tireWear': status.tireWear.toInt(),
        'fuelLevel': status.fuelLevel.toInt(),
        'overtakes': status.totalOvertakes,
      });
    }

    return standings;
  }

  static String _formatRaceTime(double totalSeconds) {
    int minutes = (totalSeconds / 60).floor();
    double seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toStringAsFixed(3).padLeft(6, '0')}';
  }

  static Map<String, dynamic> _generateLapAnalysis(
    List<LapData> lapData,
    String playerTeamId,
  ) {
    List<double> playerLapTimes = lapData
        .map((data) => data.lapTimes[playerTeamId + '_1'] ?? 0)
        .where((time) => time > 0)
        .toList();

    if (playerLapTimes.isEmpty) {
      return {
        'bestLap': 0.0,
        'averageLap': 0.0,
        'consistency': 0.0,
        'performanceTrend': 'stable',
        'tirePerformance': 'unknown',
      };
    }

    double bestLap = playerLapTimes.reduce((a, b) => a < b ? a : b);
    double averageLap =
        playerLapTimes.reduce((a, b) => a + b) / playerLapTimes.length;
    double consistency = _calculateConsistency(lapData, playerTeamId);

    return {
      'bestLap': bestLap,
      'averageLap': averageLap,
      'consistency': consistency,
      'performanceTrend': _calculatePerformanceTrend(playerLapTimes),
      'tirePerformance': _analyzeTirePerformance(lapData, playerTeamId),
      'lapTimes': playerLapTimes,
    };
  }

  static String _calculatePerformanceTrend(List<double> lapTimes) {
    if (lapTimes.length < 3) return 'stable';

    double firstHalf =
        lapTimes.sublist(0, lapTimes.length ~/ 2).reduce((a, b) => a + b) /
        (lapTimes.length ~/ 2);
    double secondHalf =
        lapTimes.sublist(lapTimes.length ~/ 2).reduce((a, b) => a + b) /
        (lapTimes.length - lapTimes.length ~/ 2);

    if (secondHalf < firstHalf * 0.98) return 'improving';
    if (secondHalf > firstHalf * 1.02) return 'declining';
    return 'stable';
  }

  static String _analyzeTirePerformance(
    List<LapData> lapData,
    String playerTeamId,
  ) {
    List<double> lapTimes = lapData
        .map((data) => data.lapTimes[playerTeamId + '_1'] ?? 0)
        .where((time) => time > 0)
        .toList();

    if (lapTimes.length < 10) return 'insufficient_data';

    // تحليل تدهور الأداء بسبب الإطارات
    double firstQuarter =
        lapTimes.sublist(0, lapTimes.length ~/ 4).reduce((a, b) => a + b) /
        (lapTimes.length ~/ 4);
    double lastQuarter =
        lapTimes.sublist(lapTimes.length * 3 ~/ 4).reduce((a, b) => a + b) /
        (lapTimes.length - lapTimes.length * 3 ~/ 4);

    double degradation = (lastQuarter - firstQuarter) / firstQuarter;

    if (degradation < 0.02) return 'excellent';
    if (degradation < 0.05) return 'good';
    if (degradation < 0.08) return 'average';
    return 'poor';
  }

  static Map<String, dynamic> _getFinalCarStatus(
    Map<String, CarStatus> carStatuses,
    String playerTeamId,
  ) {
    CarStatus? playerStatus = carStatuses[playerTeamId + '_1'];
    if (playerStatus == null) return {};

    return {
      'tireWear': playerStatus.tireWear.toInt(),
      'fuelLevel': playerStatus.fuelLevel.toInt(),
      'finalPosition': playerStatus.currentPosition,
      'totalOvertakes': playerStatus.totalOvertakes,
      'consecutiveOvertakes': playerStatus.consecutiveOvertakes,
      'hasDRS': playerStatus.hasDRS,
    };
  }

  static String _getDifficultyText(double difficulty) {
    if (difficulty <= 0.25) return "سهل";
    if (difficulty <= 0.5) return "متوسط";
    if (difficulty <= 0.75) return "صعب";
    return "خبير";
  }

  // 🤖 توليد إستراتيجية ذكية للـ AI
  static RaceStrategy _generateSmartAIStrategy({
    required WeatherType initialWeather,
    required String playerId,
    required int aiIndex,
    required Team playerTeam,
    required double difficulty,
  }) {
    int minPitStopLap, maxPitStopLap;
    AggressionLevel aggression;

    // تحسين إستراتيجية الـ AI حسب مستوى الصعوبة
    if (difficulty <= 0.25) {
      minPitStopLap = 10;
      maxPitStopLap = 20;
      aggression = AggressionLevel.conservative;
    } else if (difficulty <= 0.5) {
      minPitStopLap = 15;
      maxPitStopLap = 25;
      aggression = AggressionLevel.balanced;
    } else if (difficulty <= 0.75) {
      minPitStopLap = 20;
      maxPitStopLap = 30;
      aggression = _random.nextDouble() > 0.7
          ? AggressionLevel.aggressive
          : AggressionLevel.balanced;
    } else {
      minPitStopLap = 25;
      maxPitStopLap = 35;
      aggression = AggressionLevel.aggressive;
    }

    return RaceStrategy(
      tireChoice: _getAppropriateTire(initialWeather),
      pitStopLap:
          minPitStopLap + _random.nextInt(maxPitStopLap - minPitStopLap + 1),
      aggression: aggression,
      fuelLoad: 95 + _random.nextInt(11),
      weatherAdjustment: _random.nextDouble() > 0.3,
    );
  }

  static TireType _getAppropriateTire(WeatherType weather) {
    if (weather == WeatherType.wet) {
      return TireType.wet;
    } else {
      // AI يختار إطارات متنوعة بشكل استراتيجي
      List<TireType> dryTires = [TireType.soft, TireType.medium, TireType.hard];
      return dryTires[_random.nextInt(dryTires.length)];
    }
  }

  // 🎯 دوال محاكاة السباق السريع (للتوافق مع النظام القديم)
  static Map<String, dynamic> simulateRace({
    required Team playerTeam,
    required RaceStrategy strategy,
    required List<Team> aiTeams,
    required RaceEvent raceEvent,
    WeatherType weather = WeatherType.dry,
    bool weatherChanges = false,
    required double raceDifficulty,
  }) {
    return simulateAdvancedRace(
      playerTeam: playerTeam,
      strategy: strategy,
      aiTeams: aiTeams,
      raceEvent: raceEvent,
      initialWeather: weather,
      raceDifficulty: raceDifficulty,
    );
  }
}

// 🏎️ نماذج البيانات المتقدمة
class CarStatus {
  final String teamId;
  final bool isDriver1;
  double fuelLevel;
  double tireWear;
  TireType tireType;
  int currentPosition;
  double lastLapTime;
  int consecutiveOvertakes;
  int totalOvertakes;
  bool hasDRS;
  bool inPit;
  int pitStopTimeRemaining;

  CarStatus({
    required this.teamId,
    required this.isDriver1,
    this.fuelLevel = 100.0,
    this.tireWear = 100.0,
    required this.tireType,
    this.currentPosition = 20,
    this.lastLapTime = 0.0,
    this.consecutiveOvertakes = 0,
    this.totalOvertakes = 0,
    this.hasDRS = false,
    this.inPit = false,
    this.pitStopTimeRemaining = 0,
  });

  void updateMomentum() {
    if (consecutiveOvertakes > 0) {
      consecutiveOvertakes = (consecutiveOvertakes * 0.8)
          .toInt(); // تضاؤل الزخم
    }
  }
}

class LapData {
  final int lapNumber;
  final Map<String, double> lapTimes;
  final Map<String, double> sectorTimes;
  final Map<String, List<String>> lapEvents;
  final WeatherType weather;

  LapData({
    required this.lapNumber,
    required this.lapTimes,
    required this.sectorTimes,
    required this.lapEvents,
    required this.weather,
  });
}

class DynamicRaceEvent {
  final EventType type;
  final int lap;
  final String message;
  final String? affectedTeam;
  final EventSeverity severity;
  final DateTime timestamp;

  DynamicRaceEvent({
    required this.type,
    required this.lap,
    required this.message,
    this.affectedTeam,
    required this.severity,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'lap': lap,
      'message': message,
      'affectedTeam': affectedTeam,
      'severity': severity.toString(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class WeatherSimulation {
  WeatherType currentWeather;
  int changeLap = -1;
  static final Random _random = Random();

  WeatherSimulation(this.currentWeather);

  WeatherType getWeatherForLap(int lap) {
    // 30% فرصة لتغير الطقس بعد منتصف السباق
    if (changeLap == -1 && lap > 15 && _random.nextDouble() < 0.3) {
      changeLap = lap;
      currentWeather = currentWeather == WeatherType.dry
          ? WeatherType.wet
          : WeatherType.dry;
    }

    return currentWeather;
  }
}

enum EventType { weather, overtake, incident, pitStop, technical, safetyCar }

enum EventSeverity { info, warning, success, error, critical }

// 🎯 دوال تنفيذ Pit Stop المتقدمة
class PitStopEngine {
  static final Random _random = Random();

  static Map<String, dynamic> executePitStop({
    required RaceStrategy currentStrategy,
    required TireType newTireChoice,
    required int currentLap,
    required double currentFuel,
    required int refuelAmount,
    required double difficulty,
  }) {
    int pitStopTime = 22000; // 22 ثانية أساسية

    // تعديل الوقت حسب نوع الإطارات
    switch (newTireChoice) {
      case TireType.soft:
        pitStopTime += 1000; // أسرع تركيب
        break;
      case TireType.medium:
        pitStopTime += 1500;
        break;
      case TireType.hard:
        pitStopTime += 2000; // أبطأ تركيب
        break;
      case TireType.wet:
        pitStopTime += 2500; // الأبطأ
        break;
    }

    // وقت التزود بالوقود (2 ثانية لكل 1% وقود)
    int refuelTime = (refuelAmount * 2000).toInt();
    pitStopTime += refuelTime;

    // أخطاء الطاقم (تزداد مع الصعوبة)
    if (_random.nextDouble() < _getPitStopErrorChance(difficulty)) {
      pitStopTime += 5000; // خطأ كبير
    }

    // كفاءة الطاقم (تتحسن مع الخبرة)
    pitStopTime = (pitStopTime * _getPitStopEfficiency(difficulty)).toInt();

    return {
      'timeLost': pitStopTime,
      'newTireWear': 100.0, // إطارات جديدة
      'newFuelLevel': (currentFuel + refuelAmount).clamp(0, 100),
      'tireType': newTireChoice,
      'pitStopLap': currentLap,
      'hadIssues': pitStopTime > 25000,
    };
  }

  static double _getPitStopErrorChance(double difficulty) {
    if (difficulty <= 0.25) return 0.02;
    if (difficulty <= 0.5) return 0.05;
    if (difficulty <= 0.75) return 0.08;
    return 0.12;
  }

  static double _getPitStopEfficiency(double difficulty) {
    if (difficulty <= 0.25) return 0.95; // أكثر كفاءة
    if (difficulty <= 0.5) return 1.0;
    if (difficulty <= 0.75) return 1.05;
    return 1.1; // أقل كفاءة
  }
}

// 📊 نظام الإحصائيات المتقدم
class RaceAnalytics {
  static Map<String, dynamic> analyzeRacePerformance(
    List<LapData> lapData,
    String teamId,
  ) {
    List<double> lapTimes = lapData
        .map((data) => data.lapTimes[teamId + '_1'] ?? 0)
        .where((time) => time > 0)
        .toList();

    if (lapTimes.isEmpty) return {};

    return {
      'performanceMetrics': {
        'bestLap': lapTimes.reduce((a, b) => a < b ? a : b),
        'worstLap': lapTimes.reduce((a, b) => a > b ? a : b),
        'averageLap': lapTimes.reduce((a, b) => a + b) / lapTimes.length,
        'consistency': _calculateLapConsistency(lapTimes),
        'degradationRate': _calculateTireDegradation(lapTimes),
      },
      'racePhases': {
        'startPhase': _analyzeRacePhase(
          lapTimes.sublist(0, min(10, lapTimes.length)),
        ),
        'middlePhase': _analyzeRacePhase(
          lapTimes.sublist(
            min(10, lapTimes.length),
            max(lapTimes.length - 10, min(10, lapTimes.length)),
          ),
        ),
        'endPhase': _analyzeRacePhase(
          lapTimes.sublist(max(lapTimes.length - 10, 0)),
        ),
      },
    };
  }

  static double _calculateLapConsistency(List<double> lapTimes) {
    if (lapTimes.length < 2) return 100.0;

    double average = lapTimes.reduce((a, b) => a + b) / lapTimes.length;
    double variance =
        lapTimes.map((time) => pow(time - average, 2)).reduce((a, b) => a + b) /
        lapTimes.length;
    double stdDev = sqrt(variance);

    return (1.0 / (stdDev / average + 0.01)) * 10;
  }

  static double _calculateTireDegradation(List<double> lapTimes) {
    if (lapTimes.length < 10) return 0.0;

    double firstSegment =
        lapTimes.sublist(0, lapTimes.length ~/ 3).reduce((a, b) => a + b) /
        (lapTimes.length ~/ 3);
    double lastSegment =
        lapTimes.sublist(lapTimes.length * 2 ~/ 3).reduce((a, b) => a + b) /
        (lapTimes.length - lapTimes.length * 2 ~/ 3);

    return ((lastSegment - firstSegment) / firstSegment) * 100;
  }

  static Map<String, dynamic> _analyzeRacePhase(List<double> phaseLapTimes) {
    if (phaseLapTimes.isEmpty) return {};

    return {
      'averageTime':
          phaseLapTimes.reduce((a, b) => a + b) / phaseLapTimes.length,
      'bestTime': phaseLapTimes.reduce((a, b) => a < b ? a : b),
      'consistency': _calculateLapConsistency(phaseLapTimes),
      'trend': _calculatePhaseTrend(phaseLapTimes),
    };
  }

  static String _calculatePhaseTrend(List<double> phaseLapTimes) {
    if (phaseLapTimes.length < 3) return 'stable';

    double firstHalf =
        phaseLapTimes
            .sublist(0, phaseLapTimes.length ~/ 2)
            .reduce((a, b) => a + b) /
        (phaseLapTimes.length ~/ 2);
    double secondHalf =
        phaseLapTimes
            .sublist(phaseLapTimes.length ~/ 2)
            .reduce((a, b) => a + b) /
        (phaseLapTimes.length - phaseLapTimes.length ~/ 2);

    if (secondHalf < firstHalf * 0.98) return 'improving';
    if (secondHalf > firstHalf * 1.02) return 'declining';
    return 'stable';
  }
}
