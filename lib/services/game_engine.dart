import 'dart:math';
import '../models/driver.dart';
import '../models/race_event.dart';
import '../models/team.dart';
import '../models/race_strategy.dart';
import '../models/race_result.dart';

class GameEngine {
  static final Random _random = Random();
  static Map<String, List<RaceStrategy>> _playerStrategyHistory = {};
  static Map<String, int> _playerWinStreak = {};

  static Map<String, dynamic> simulateRace({
    required Team playerTeam,
    required RaceStrategy strategy,
    required List<Team> aiTeams,
    required RaceEvent raceEvent,
    WeatherType weather = WeatherType.dry,
    bool weatherChanges = false,
    required double raceDifficulty,
  }) {
    // int totalLaps = raceEvent.totalLaps;
    
    // 🔄 تحديث تاريخ إستراتيجيات اللاعب
    _updatePlayerStrategyHistory(playerTeam.id, strategy);
    
    // 🌦️ محاكاة تغير الطقس أثناء السباق
    WeatherType finalWeather = weather;
    List<String> weatherEvents = [];
    
    if (weatherChanges && _random.nextDouble() < 0.4) {
      finalWeather = _simulateWeatherChange(weather, weatherEvents);
    }

    // حساب أداء اللاعب مع عنصر عشوائي قوي
    double playerPerformance1 = _calculatePlayerPerformance(
      playerTeam,
      strategy,
      finalWeather,
      raceDifficulty,
      isDriver1: true,
    );

    double playerPerformance2 = _calculatePlayerPerformance(
      playerTeam,
      strategy,
      finalWeather,
      raceDifficulty,
      isDriver1: false,
    );

    // 🤖 حساب أداء المنافسين الأذكياء (كل فريق له سائقين)
    List<double> aiPerformances = [];
    for (Team aiTeam in aiTeams) {
      RaceStrategy aiStrategy1 = _generateSmartAIStrategy(
        finalWeather, 
        playerTeam.id, 
        aiTeams.indexOf(aiTeam), 
        playerTeam,
        raceDifficulty,
      );
      RaceStrategy aiStrategy2 = _generateSmartAIStrategy(
        finalWeather, 
        playerTeam.id, 
        aiTeams.indexOf(aiTeam), 
        playerTeam,
        raceDifficulty,
      );
      
      double aiPerformance1 = _calculateAIPerformance(
        aiTeam, 
        aiStrategy1, 
        finalWeather, 
        playerTeam,
        raceDifficulty,
        isDriver1: true,
      );
      
      double aiPerformance2 = _calculateAIPerformance(
        aiTeam, 
        aiStrategy2, 
        finalWeather, 
        playerTeam,
        raceDifficulty,
        isDriver1: false,
      );
      
      aiPerformances.add(aiPerformance1);
      aiPerformances.add(aiPerformance2);
    }

    // 🔥 نظام تصنيف واقعي مع منافسة شرسة
    List<RacePosition> allPositions = _calculateRealisticPositions(
      playerPerformance1,
      playerPerformance2,
      aiPerformances, 
      playerTeam, 
      aiTeams
    );

    // الحصول على مركز كل سائق من الفريق
    int playerPosition1 = _getDriverPosition(allPositions, playerTeam.id, true);
    int playerPosition2 = _getDriverPosition(allPositions, playerTeam.id, false);
    
    // استخدام المركز الأفضل للفريق
    int bestPlayerPosition = playerPosition1 < playerPosition2 ? playerPosition1 : playerPosition2;
    int points = _calculatePoints(playerPosition1) + _calculatePoints(playerPosition2);

    // 🎲 أحداث عشوائية تؤثر على النتيجة
    List<String> raceEvents = _generateDynamicRaceEvents(
      strategy,
      bestPlayerPosition,
      finalWeather,
      weatherEvents,
      playerTeam,
      raceDifficulty,
    );

    // أسرع لفة (نادرة)
    bool hasFastestLap = _random.nextDouble() < _getFastestLapChance(bestPlayerPosition, raceDifficulty);

    // إنشاء ترتيب المتسابقين
    List<Map<String, dynamic>> raceStandings = _generateRaceStandings(
      allPositions,
      playerTeam,
      aiTeams,
    );

    return {
      'finalPosition': bestPlayerPosition,
      'driver1Position': playerPosition1,
      'driver2Position': playerPosition2,
      'pointsEarned': points,
      'prizeMoney': _calculatePrizeMoney(bestPlayerPosition, raceDifficulty),
      'raceEvents': raceEvents,
      'overtakes': _calculateOvertakes(bestPlayerPosition),
      'fastestLap': hasFastestLap,
      'strategyRating': _calculateStrategyRating(
        strategy,
        bestPlayerPosition,
        finalWeather,
        playerTeam,
        aiTeams,
        raceDifficulty,
      ),
      'completedLaps' : raceEvent.totalLaps,
      'pitStopLap': strategy.pitStopLap,
      'finalWeather': finalWeather,
      'difficulty': raceDifficulty.toString(),
      'raceStandings': raceStandings, // إضافة ترتيب المتسابقين
    };
  }

  // 🎯 أداء اللاعب مع عنصر عشوائي ومخاطرة
  static double _calculatePlayerPerformance(
    Team team,
    RaceStrategy strategy,
    WeatherType weather,
    double difficulty, {
    required bool isDriver1,
  }) {
    Driver driver = isDriver1 ? team.driver1 : team.driver2;
    double driverSkill = driver.overallRating;
    double basePerformance = team.carPerformance;
    double strategyScore = strategy.calculateStrategyScore(weather);
    
    // 🔥 عنصر عشوائي قوي (يختلف حسب الصعوبة)
    double randomFactor = _getPlayerRandomFactor(difficulty);
    
    // 📉 عقوبة الفوز المتتالي
    double winStreakPenalty = _calculateWinStreakPenalty(team.id);
    
    // 🎲 مخاطرة الإستراتيجية العدوانية
    double riskFactor = _calculateRiskFactor(strategy);
    
    // 🎯 تأثير مستوى الصعوبة
    double difficultyMultiplier = _getDifficultyMultiplier(difficulty);

    return (basePerformance * 0.4 + driverSkill * 0.4 + strategyScore * 0.2) * 
           randomFactor * winStreakPenalty * riskFactor * difficultyMultiplier;
  }

  // 🤖 أداء الذكاء الاصطناعي المحسن
  static double _calculateAIPerformance(
    Team aiTeam,
    RaceStrategy aiStrategy,
    WeatherType weather,
    Team playerTeam,
    double difficulty, {
    required bool isDriver1,
  }) {
    Driver driver = isDriver1 ? aiTeam.driver1 : aiTeam.driver2;
    double driverSkill = driver.overallRating;
    double basePerformance = aiTeam.carPerformance;
    double strategyScore = aiStrategy.calculateStrategyScore(weather);
    
    // 🎯 AI يصبح أقوى ضد اللاعبين الناجحين
    double antiPlayerBoost = _calculateAntiPlayerBoost(playerTeam);
    
    // 🔥 عنصر عشوائي للـ AI (يختلف حسب الصعوبة)
    double randomFactor = _getAIRandomFactor(difficulty);
    
    // 🎯 تعزيز الـ AI حسب مستوى الصعوبة
    double difficultyBoost = _getAIDifficultyBoost(difficulty);

    return (basePerformance * 0.4 + driverSkill * 0.4 + strategyScore * 0.2) * 
           randomFactor * antiPlayerBoost * difficultyBoost;
  }

  // 🎯 عوامل العشوائية حسب مستوى الصعوبة
  static double _getPlayerRandomFactor(double difficulty) {
    if (difficulty <= 0.25) { // سهل
      return 0.9 + _random.nextDouble() * 0.2;
    } else if (difficulty <= 0.5) { // متوسط
      return 0.85 + _random.nextDouble() * 0.3;
    } else if (difficulty <= 0.75) { // صعب
      return 0.8 + _random.nextDouble() * 0.4;
    } else { // خبير
      return 0.75 + _random.nextDouble() * 0.5;
    }
  }

  static double _getAIRandomFactor(double difficulty) {
    if (difficulty <= 0.25) {
      return 0.8 + _random.nextDouble() * 0.2;
    } else if (difficulty <= 0.5) {
      return 0.85 + _random.nextDouble() * 0.25;
    } else if (difficulty <= 0.75) {
      return 0.9 + _random.nextDouble() * 0.2;
    } else {
      return 0.95 + _random.nextDouble() * 0.1;
    }
  }

  // 🎯 مضاعفات الصعوبة
  static double _getDifficultyMultiplier(double difficulty) {
    if (difficulty <= 0.25) return 1.2;
    if (difficulty <= 0.5) return 1.0;
    if (difficulty <= 0.75) return 0.9;
    return 0.8;
  }

  static double _getAIDifficultyBoost(double difficulty) {
    if (difficulty <= 0.25) return 0.9;
    if (difficulty <= 0.5) return 1.0;
    if (difficulty <= 0.75) return 1.1;
    return 1.2;
  }

  // 📉 عقوبة الفوز المتتالي
  static double _calculateWinStreakPenalty(String playerId) {
    int winStreak = _playerWinStreak[playerId] ?? 0;
    if (winStreak <= 2) return 1.0;
    if (winStreak <= 5) return 0.9;
    if (winStreak <= 8) return 0.8;
    return 0.7;
  }

  // 🎲 مخاطرة الإستراتيجية
  static double _calculateRiskFactor(RaceStrategy strategy) {
    switch (strategy.aggression) {
      case AggressionLevel.conservative:
        return 0.9;
      case AggressionLevel.balanced:
        return 1.0;
      case AggressionLevel.aggressive:
        return _random.nextDouble() < 0.6 ? 1.3 : 0.7;
    }
  }

  // 🎯 تعزيز الـ AI ضد اللاعبين الناجحين
  static double _calculateAntiPlayerBoost(Team playerTeam) {
    double playerStrength = playerTeam.overallPerformance / 100.0;
    int racesWon = playerTeam.racesWon;
    
    if (racesWon <= 3) return 1.0;
    if (racesWon <= 8) return 1.1;
    if (racesWon <= 15) return 1.2;
    return 1.3;
  }

  // 🏁 نظام تصنيف واقعي
  static List<RacePosition> _calculateRealisticPositions(
    double playerPerformance1,
    double playerPerformance2,
    List<double> aiPerformances,
    Team playerTeam,
    List<Team> aiTeams,
  ) {
    List<RacePosition> positions = [];
    
    // إضافة سائقي اللاعب
    positions.add(RacePosition(
      teamId: playerTeam.id,
      performance: playerPerformance1,
      isPlayer: true,
      isDriver1: true,
    ));
    
    positions.add(RacePosition(
      teamId: playerTeam.id,
      performance: playerPerformance2,
      isPlayer: true,
      isDriver1: false,
    ));
    
    // إضافة سائقي الـ AI
    int aiDriverIndex = 0;
    for (int i = 0; i < aiTeams.length; i++) {
      positions.add(RacePosition(
        teamId: aiTeams[i].id,
        performance: aiPerformances[aiDriverIndex],
        isPlayer: false,
        isDriver1: true,
      ));
      aiDriverIndex++;
      
      positions.add(RacePosition(
        teamId: aiTeams[i].id,
        performance: aiPerformances[aiDriverIndex],
        isPlayer: false,
        isDriver1: false,
      ));
      aiDriverIndex++;
    }
    
    positions.sort((a, b) => b.performance.compareTo(a.performance));
    
    return positions;
  }

  static int _getDriverPosition(List<RacePosition> positions, String teamId, bool isDriver1) {
    for (int i = 0; i < positions.length; i++) {
      if (positions[i].teamId == teamId && positions[i].isDriver1 == isDriver1) {
        return i + 1;
      }
    }
    return positions.length;
  }

  static int _getPlayerPosition(List<RacePosition> positions, String playerId) {
    int bestPosition = positions.length;
    for (int i = 0; i < positions.length; i++) {
      if (positions[i].teamId == playerId && positions[i].isPlayer) {
        if (i + 1 < bestPosition) {
          bestPosition = i + 1;
        }
      }
    }
    return bestPosition;
  }

  // 🎲 أحداث ديناميكية تؤثر على النتيجة
  static List<String> _generateDynamicRaceEvents(
    RaceStrategy strategy,
    int position,
    WeatherType weather,
    List<String> weatherEvents,
    Team playerTeam,
    double difficulty,
  ) {
    List<String> events = [...weatherEvents];
    Random random = Random();

    // فرصة الأحداث حسب مستوى الصعوبة
    double negativeEventChance = _getNegativeEventChance(difficulty);
    double positiveEventChance = _getPositiveEventChance(difficulty);

    if (random.nextDouble() < negativeEventChance) {
      events.add(_getRandomNegativeEvent(strategy, position, difficulty));
    }
    
    if (random.nextDouble() < positiveEventChance) {
      events.add(_getRandomPositiveEvent(difficulty));
    }

    events.add(_getPositionEvent(position, playerTeam.racesWon, difficulty));

    return events;
  }

  static double _getNegativeEventChance(double difficulty) {
    if (difficulty <= 0.25) return 0.2;
    if (difficulty <= 0.5) return 0.3;
    if (difficulty <= 0.75) return 0.4;
    return 0.5;
  }

  static double _getPositiveEventChance(double difficulty) {
    if (difficulty <= 0.25) return 0.3;
    if (difficulty <= 0.5) return 0.2;
    if (difficulty <= 0.75) return 0.15;
    return 0.1;
  }

  static String _getRandomNegativeEvent(RaceStrategy strategy, int position, double difficulty) {
    List<String> negativeEvents = [
      "💥 عطل تقني بسيط - فقدت 0.5 ثانية",
      "🔄 خطأ في المنعطف - خسرت مركز",
      "⛽ مشكلة في نظام الوقود - زيادة الاستهلاك",
      "🛞 تآكل سريع للإطارات",
      "🎯 تجاوز فاشل - خسرت وقتاً",
    ];
    
    if (strategy.aggression == AggressionLevel.aggressive) {
      negativeEvents.addAll([
        "💥 حادث بسيط - خسرت مركزين",
        "🚩 عقوبة من الحكام - فقدت 2 ثانية",
        "🔥 مشكلة في المكابح - تأثر الأداء",
      ]);
    }

    // أحداث إضافية في المستويات الصعبة
    if (difficulty > 0.5) {
      negativeEvents.addAll([
        "⚡ مشكلة في النظام الكهربائي - فقدت 3 ثواني",
        "🛠️ عطل في علبة التروس - تأثر التسارع",
      ]);
    }
    
    return negativeEvents[_random.nextInt(negativeEvents.length)];
  }

  static String _getRandomPositiveEvent(double difficulty) {
    List<String> positiveEvents = [
      "🎯 تجاوز رائع - تقدم مركز",
      "⚡ بداية ممتازة - تقدم مركزين",
      "🛞 تآكل أقل من المتوقع - أداء أفضل",
      "⛽ استهلاك وقود ممتاز",
      "🔧 إعدادات مثالية - تحسن الأداء",
    ];

    // أحداث إضافية في المستويات السهلة
    if (difficulty <= 0.25) {
      positiveEvents.addAll([
        "🌟 حظ سعيد - تقدم غير متوقع",
        "🚀 أداء استثنائي - تقدم 3 مراكز",
      ]);
    }
    
    return positiveEvents[_random.nextInt(positiveEvents.length)];
  }

  static String _getPositionEvent(int position, int racesWon, double difficulty) {
    String difficultyText = _getDifficultyText(difficulty);
    
    if (position == 1) {
      _updateWinStreak("player", true);
      return "🏆 فوز مذهل! $difficultyText";
    } else if (position <= 3) {
      _updateWinStreak("player", false);
      return "🥈 منصة التتويج! أداء رائع في $difficultyText";
    } else if (position <= 10) {
      _updateWinStreak("player", false);
      return "✅ إنهاء جيد بالنقاط ($difficultyText)";
    } else if (position <= 15) {
      return "⚠️ سباق صعب - بدون نقاط ($difficultyText)";
    } else {
      return "❌ سباق كارثي - يحتاج تحسين ($difficultyText)";
    }
  }

  static String _getDifficultyText(double difficulty) {
    if (difficulty <= 0.25) return "وضع سهل";
    if (difficulty <= 0.5) return "وضع متوسط";
    if (difficulty <= 0.75) return "وضع صعب";
    return "وضع خبير";
  }

  static void _updateWinStreak(String playerId, bool won) {
    if (won) {
      _playerWinStreak[playerId] = (_playerWinStreak[playerId] ?? 0) + 1;
    } else {
      _playerWinStreak[playerId] = 0;
    }
  }

  static int _calculatePoints(int position) {
    List<int> pointsSystem = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1];
    return position <= pointsSystem.length ? pointsSystem[position - 1] : 0;
  }

  static int _calculatePrizeMoney(int position, double difficulty) {
    List<int> basePrizeSystem = [
      1000000, 750000, 500000, 400000, 300000,
      250000, 200000, 150000, 100000, 50000,
    ];
    
    int basePrize = position <= basePrizeSystem.length ? basePrizeSystem[position - 1] : 25000;
    
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

  static int _calculateOvertakes(int finalPosition) {
    int startPosition = 10;
    return (startPosition - finalPosition).clamp(0, 20);
  }

  static double _getFastestLapChance(int position, double difficulty) {
    double baseChance = position <= 5 ? 0.2 : 0.05;
    
    if (difficulty <= 0.25) {
      return baseChance * 1.5;
    } else if (difficulty <= 0.5) {
      return baseChance;
    } else if (difficulty <= 0.75) {
      return baseChance * 0.7;
    } else {
      return baseChance * 0.5;
    }
  }

  static int _calculateStrategyRating(
    RaceStrategy strategy,
    int position,
    WeatherType weather,
    Team playerTeam,
    List<Team> aiTeams,
    double difficulty,
  ) {
    int rating = 50;
    rating += (11 - position) * 5;

    if (strategy.pitStopLap >= 15 && strategy.pitStopLap <= 25) {
      rating += 15;
    }

    if ((weather == WeatherType.wet && strategy.tireChoice == TireType.wet) ||
        (weather == WeatherType.dry && strategy.tireChoice != TireType.wet)) {
      rating += 10;
    }

    // تقييم واقعي بناء على مستوى المنافسة والصعوبة
    double aiStrength = aiTeams.map((team) => team.overallPerformance).reduce((a, b) => a + b) / aiTeams.length;
    double playerStrength = playerTeam.overallPerformance;
    
    if (position <= 5 && playerStrength < aiStrength) {
      rating += 20;
    }

    // تعديل التقييم حسب الصعوبة
    rating = (rating * _getRatingMultiplier(difficulty)).toInt();

    return rating.clamp(0, 100);
  }

  static double _getRatingMultiplier(double difficulty) {
    if (difficulty <= 0.25) return 0.9;
    if (difficulty <= 0.5) return 1.0;
    if (difficulty <= 0.75) return 1.1;
    return 1.2;
  }

  static void _updatePlayerStrategyHistory(String playerId, RaceStrategy strategy) {
    if (!_playerStrategyHistory.containsKey(playerId)) {
      _playerStrategyHistory[playerId] = [];
    }
    
    _playerStrategyHistory[playerId]!.add(strategy);
    
    if (_playerStrategyHistory[playerId]!.length > 5) {
      _playerStrategyHistory[playerId]!.removeAt(0);
    }
  }

  static bool shouldWeatherChange(int raceNumber) {
    return raceNumber > 5 ? _random.nextDouble() < 0.6 : _random.nextDouble() < 0.3;
  }

  static RaceStrategy _generateSmartAIStrategy(
    WeatherType weather, 
    String playerId, 
    int aiIndex, 
    Team playerTeam,
    double difficulty,
  ) {
    // تحسين إستراتيجية الـ AI حسب مستوى الصعوبة
    int minPitStopLap, maxPitStopLap;
    
    if (difficulty <= 0.25) {
      minPitStopLap = 10;
      maxPitStopLap = 20;
    } else if (difficulty <= 0.5) {
      minPitStopLap = 15;
      maxPitStopLap = 25;
    } else if (difficulty <= 0.75) {
      minPitStopLap = 20;
      maxPitStopLap = 30;
    } else {
      minPitStopLap = 25;
      maxPitStopLap = 35;
    }

    return RaceStrategy(
      tireChoice: _getAppropriateTire(weather),
      pitStopLap: minPitStopLap + _random.nextInt(maxPitStopLap - minPitStopLap + 1),
      aggression: _getAIAggression(difficulty),
      fuelLoad: 95 + _random.nextInt(11),
      weatherAdjustment: _random.nextDouble() > 0.3,
    );
  }
  
  static AggressionLevel _getAIAggression(double difficulty) {
    if (difficulty <= 0.25) {
      return AggressionLevel.conservative;
    } else if (difficulty <= 0.5) {
      return AggressionLevel.balanced;
    } else if (difficulty <= 0.75) {
      return _random.nextDouble() > 0.7 ? AggressionLevel.aggressive : AggressionLevel.balanced;
    } else {
      return AggressionLevel.aggressive;
    }
  }

  static WeatherType _simulateWeatherChange(WeatherType currentWeather, List<String> events) {
    if (_random.nextDouble() < 0.3) {
      if (currentWeather == WeatherType.dry) {
        events.add("🌧️ بدأ المطر! تحتاج إلى إطارات مطرية");
        return WeatherType.wet;
      } else {
        events.add("☀️ توقف المطر! تحتاج إلى إطارات جافة");
        return WeatherType.dry;
      }
    }
    return currentWeather;
  }

  static TireType _getAppropriateTire(WeatherType weather) {
    if (weather == WeatherType.wet) {
      return TireType.wet;
    } else {
      return TireType.soft; // الـ AI يختار إطارات ناعمة بشكل افتراضي
    }
  }

  // دالة لإنشاء ترتيب المتسابقين
  static List<Map<String, dynamic>> _generateRaceStandings(
    List<RacePosition> positions,
    Team playerTeam,
    List<Team> aiTeams,
  ) {
    List<Map<String, dynamic>> standings = [];
    
    for (int i = 0; i < positions.length; i++) {
      final position = positions[i];
      final isPlayer = position.isPlayer;
      final team = isPlayer ? playerTeam : aiTeams.firstWhere((team) => team.id == position.teamId);
      final driver = position.isDriver1 ? team.driver1 : team.driver2;
      
      standings.add({
        'position': i + 1,
        'name': isPlayer ? (position.isDriver1 ? '${driver.name} (سائق 1)' : '${driver.name} (سائق 2)') : driver.name,
        'team': team.name,
        'time': _calculateRaceTime(i + 1),
        'points': _calculatePoints(i + 1),
        'isPlayer': isPlayer,
        'driverNumber': position.isDriver1 ? 1 : 2,
      });
    }
    
    return standings;
  }

  static String _calculateRaceTime(int position) {
    if (position == 1) return '+0.000';
    double gap = (position - 1) * 3.5 + (position * 0.8);
    return '+${gap.toStringAsFixed(3)}';
  }
}

class RacePosition {
  final String teamId;
  final double performance;
  final bool isPlayer;
  final bool isDriver1;

  RacePosition({
    required this.teamId,
    required this.performance,
    required this.isPlayer,
    required this.isDriver1,
  });
}