import 'dart:async';
import 'dart:math';
import 'package:myapp/models/race_event.dart';
import '../models/team.dart';
import '../models/race_strategy.dart';
import '../models/race_result.dart';
// import 'game_engine.dart';

class EnhancedSimulationService {
  final StreamController<Map<String, dynamic>> _raceStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final Random _random = Random();

  Stream<Map<String, dynamic>> get raceStream => _raceStreamController.stream;
  Timer? _simulationTimer;
  int _currentSimulationSpeed = 1;
  bool _isPaused = false;
  bool _isRaceFinished = false;

  // حالة السباق الحالية
  late Team _playerTeam;
  late RaceStrategy _strategy;
  late List<Team> _aiTeams;
  late int _totalLaps;
  late double _difficulty;
  late RaceEvent _raceEvent;

  // متغيرات حالة السيارة
  double _currentFuel = 100.0;
  double _currentTireWear = 100.0;
  int _currentPosition = 10;
  WeatherType _currentWeather = WeatherType.dry;
  int _completedLaps = 0;
  bool _hasPitted = false;
  int _actualPitStopLap = 0;
  List<String> _raceEvents = [];
  int _totalOvertakes = 0;
  double _performanceMultiplier = 1.0;
  int _consecutiveOvertakes = 0;
  bool _hasDRS = false;

  // دوال حساب الاستهلاك والتآكل (بديل عن AdvancedRaceEngine)
  double calculateRealisticFuelConsumption(
    RaceStrategy strategy,
    int currentLap,
    WeatherType weather,
  ) {
    double baseConsumption = 2.2; // كجم/لفة (زيادة واقعية)
    
    // تأثير العدوانية
    switch (strategy.aggression) {
      case AggressionLevel.aggressive:
        baseConsumption *= 1.4; // زيادة الاستهلاك
        break;
      case AggressionLevel.conservative:
        baseConsumption *= 0.7; // توفير وقود
        break;
      case AggressionLevel.balanced:
        baseConsumption *= 1.0;
        break;
    }
    
    // تأثير الطقس
    switch (weather) {
      case WeatherType.wet:
        baseConsumption *= 1.3; // زيادة في المطر
        break;
      case WeatherType.changeable:
        baseConsumption *= 1.15;
        break;
      case WeatherType.dry:
        baseConsumption *= 1.0;
        break;
    }
    
    // تأثير تقدم السباق (السيارة أخف مع انخفاض الوقود)
    double lapFactor = 1.0 - (currentLap * 0.002); // تحسن طفيف كل لفة
    baseConsumption *= lapFactor.clamp(0.8, 1.0);
    
    return baseConsumption;
  }

  double calculateRealisticTireWear(
    RaceStrategy strategy,
    int currentLap,
    WeatherType weather,
  ) {
    double wear = 0.0;
    
    // التآكل الأساسي حسب نوع الإطار
    switch (strategy.tireChoice) {
      case TireType.soft:
        wear = 2.0 + (currentLap * 0.025); // تآكل سريع
        break;
      case TireType.medium:
        wear = 1.4 + (currentLap * 0.018);
        break;
      case TireType.hard:
        wear = 0.9 + (currentLap * 0.012); // تآكل بطيء
        break;
      case TireType.wet:
        wear = 1.6 + (currentLap * 0.020);
        break;
    }
    
    // تأثير الطقس
    if (weather == WeatherType.wet && strategy.tireChoice != TireType.wet) {
      wear *= 2.2; // تآكل سريع جداً
    } else if (weather == WeatherType.dry && strategy.tireChoice == TireType.wet) {
      wear *= 1.9; // تآكل سريع على الأرض الجافة
    }
    
    // تأثير درجة حرارة الطريق
    if (weather == WeatherType.dry) {
      wear *= 1.1; // تآكل أعلى في الطقس الحار
    }
    
    return wear.clamp(0.5, 3.0); // حدود واقعية للتآكل
  }

  // دالة تنفيذ Pit Stop محسنة
  Map<String, dynamic> executePitStop({
    required RaceStrategy currentStrategy,
    required TireType newTireChoice,
    required int currentLap,
    required double currentFuel,
    required int refuelAmount,
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
    
    // أخطاء الطاقم (عشوائية)
    if (_random.nextDouble() < 0.05) {
      pitStopTime += 3000; // خطأ في التثبيت
    }
    
    return {
      'timeLost': pitStopTime,
      'newTireWear': 100.0, // إطارات جديدة
      'newFuelLevel': (currentFuel + refuelAmount).clamp(0, 100),
      'tireType': newTireChoice,
      'pitStopLap': currentLap,
      'hadIssues': pitStopTime > 25000,
    };
  }

  // في دالة simulateEnhancedRace - تحديث النقاط للسائقين بشكل منفصل
Future<RaceResult> simulateEnhancedRace({
  required Team playerTeam,
  required RaceStrategy strategy,
  required List<Team> aiTeams,
  required int currentRaceNumber,
  RaceEvent? raceEvent,
}) async {
  _playerTeam = playerTeam;
  _strategy = strategy;
  _aiTeams = aiTeams;
  _raceEvent = raceEvent!;
  _totalLaps = _raceEvent.totalLaps;
  _difficulty = _raceEvent.difficulty;
  _currentWeather = _raceEvent.baseWeather;

  // إعادة تعيين حالة السباق
  _resetRaceState();

  final result = await _runLiveSimulation();

  // حساب مراكز السائقين بشكل منفصل
  final driver1Position = _calculateDriver1Position(result['finalPosition'] ?? 0);
  final driver2Position = _calculateDriver2Position(result['finalPosition'] ?? 0);

  return RaceResult(
    raceId: 'race_${DateTime.now().millisecondsSinceEpoch}',
    raceName: _raceEvent.name,
    round: currentRaceNumber,
    teamId: _playerTeam.id,
    finalPosition: result['finalPosition'] ?? 0,
    driver1Position: driver1Position,
    driver2Position: driver2Position,
    pointsEarned: _calculatePoints(driver1Position) + _calculatePoints(driver2Position),
    prizeMoney: result['prizeMoney'] ?? 0,
    raceEvents: List<String>.from(result['raceEvents'] ?? []),
    overtakes: result['overtakes'] ?? 0,
    fastestLap: result['fastestLap'] ?? false,
    strategyRating: result['strategyRating'] ?? 0,
    completedLaps: result['completedLaps'] ?? _totalLaps,
    pitStopLap: result['pitStopLap'] ?? _strategy.pitStopLap,
    weather: _parseWeather(result['finalWeather'] ?? _currentWeather),
    difficulty: _difficulty,
    raceStandings: List<Map<String, dynamic>>.from(
      result['raceStandings'] ?? [],
    ),
    driver1Name: _playerTeam.driver1.name,
    driver2Name: _playerTeam.driver2.name,
    raceDate: DateTime.now(),
  );
}

// دالة لحساب مركز السائق الأول بناءً على المركز النهائي ومهارة السائق
int _calculateDriver1Position(int teamPosition) {
  double driverSkill = _playerTeam.driver1.overallRating / 100.0;
  int variation = _calculatePositionVariation(driverSkill);
  
  int driverPosition = teamPosition + variation;
  
  // التأكد من أن المركز ضمن الحدود المنطقية
  return driverPosition.clamp(1, 20);
}

// دالة لحساب مركز السائق الثاني
int _calculateDriver2Position(int teamPosition) {
  double driverSkill = _playerTeam.driver2.overallRating / 100.0;
  int variation = _calculatePositionVariation(driverSkill);
  
  int driverPosition = teamPosition + variation;
  
  // التأكد من أن المركز ضمن الحدود المنطقية
  return driverPosition.clamp(1, 20);
}

// دالة لحساب التباين في المركز بناءً على مهارة السائق
int _calculatePositionVariation(double driverSkill) {
  // سائق متميز يمكنه تحسين المركز
  if (driverSkill >= 0.8) {
    return -_random.nextInt(3); // يمكنه التقدم حتى 3 مراكز
  }
  // سائق متوسط
  else if (driverSkill >= 0.6) {
    return -_random.nextInt(2); // يمكنه التقدم حتى مركزين
  }
  // سائق مبتدئ قد يتراجع
  else if (driverSkill >= 0.4) {
    return _random.nextInt(2); // قد يتراجع مركز
  }
  // سائق ضعيف
  else {
    return _random.nextInt(3); // قد يتراجع حتى 3 مراكز
  }
}

// تحديث دالة إنشاء الترتيب لتشمل السائقين بشكل منفصل
List<Map<String, dynamic>> _generateRaceStandings() {
  List<Map<String, dynamic>> standings = [];
  
  // حساب مراكز السائقين
  final driver1Pos = _calculateDriver1Position(_currentPosition);
  final driver2Pos = _calculateDriver2Position(_currentPosition);
  
  // إنشاء ترتيب واقعي يشمل جميع السائقين
  for (int i = 1; i <= 20; i++) {
    bool isDriver1 = i == driver1Pos;
    bool isDriver2 = i == driver2Pos;
    bool isPlayerTeam = isDriver1 || isDriver2;
    
    String driverName;
    String teamName;
    
    if (isDriver1) {
      driverName = _playerTeam.driver1.name;
      teamName = _playerTeam.name;
    } else if (isDriver2) {
      driverName = _playerTeam.driver2.name;
      teamName = _playerTeam.name;
    } else {
      driverName = "سائق ${i}";
      teamName = "فريق ${((i - 1) % 10) + 1}"; // 10 فرق فقط
    }
    
    standings.add({
      'position': i,
      'name': driverName,
      'team': teamName,
      'time': _formatRaceTime(i),
      'points': _calculatePoints(i),
      'isPlayer': isPlayerTeam,
      'isDriver1': isDriver1,
      'isDriver2': isDriver2,
    });
  }
  
  return standings;
}

// تحديث دالة حساب النقاط لتكون أكثر واقعية
int _calculatePoints(int position) {
  List<int> pointsSystem = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1];
  return position <= pointsSystem.length ? pointsSystem[position - 1] : 0;
}

// إضافة دالة لتحديث مراكز السائقين أثناء السباق
void _updateDriverPositions() {
  final oldDriver1Pos = _driver1Position;
  final oldDriver2Pos = _driver2Position;
  
  _driver1Position = _calculateDriver1Position(_currentPosition);
  _driver2Position = _calculateDriver2Position(_currentPosition);
  
  // تسجيل أحداث التجاوز للسائقين
  if (_driver1Position < oldDriver1Pos) {
    _raceEvents.add("🚀 ${_playerTeam.driver1.name} يتقدم للمركز $_driver1Position");
  }
  
  if (_driver2Position < oldDriver2Pos) {
    _raceEvents.add("🚀 ${_playerTeam.driver2.name} يتقدم للمركز $_driver2Position");
  }
}

// إضافة متغيرات لتتبع مراكز السائقين
int _driver1Position = 10;
int _driver2Position = 10;

// تحديث دالة resetRaceState
void _resetRaceState() {
  _currentFuel = _strategy.fuelLoad.toDouble();
  _currentTireWear = 100.0;
  _currentPosition = 10;
  _driver1Position = 10;
  _driver2Position = 10;
  _completedLaps = 0;
  _hasPitted = false;
  _actualPitStopLap = _strategy.pitStopLap;
  _raceEvents.clear();
  _totalOvertakes = 0;
  _performanceMultiplier = 1.0;
  _isRaceFinished = false;
  _isPaused = false;
  _consecutiveOvertakes = 0;
  _hasDRS = false;
}

// تحديث دالة simulateLap لتشمل تحديث مراكز السائقين
void _simulateLap() {
  // تحديث حالة السيارة
  _updateCarStatus();

  // Pit Stop تلقائي
  _handlePitStop();

  // تغيير الطقس
  _updateWeather();

  // تحديث المركز
  _updatePosition();

  // تحديث مراكز السائقين
  _updateDriverPositions();

  // تحديث DRS
  _updateDRS();

  // إضافة أحداث عشوائية
  _addRandomEvents();

  // تحديث مضاعف الأداء
  _updatePerformanceMultiplier();
}

// تحديث دالة createLapUpdate لتشمل مراكز السائقين
Map<String, dynamic> _createLapUpdate() {
  return {
    'type': 'lap_update',
    'currentLap': _completedLaps,
    'totalLaps': _totalLaps,
    'position': _currentPosition,
    'driver1Position': _driver1Position,
    'driver2Position': _driver2Position,
    'weather': _currentWeather,
    'fuelLevel': _currentFuel,
    'tireWear': _currentTireWear,
    'events': List<String>.from(_raceEvents),
    'performanceMultiplier': _performanceMultiplier,
    'hasDRS': _hasDRS,
    'overtakes': _totalOvertakes,
    'consecutiveOvertakes': _consecutiveOvertakes,
  };
}
  

  Future<Map<String, dynamic>> _runLiveSimulation() async {
    final completer = Completer<Map<String, dynamic>>();

    _simulationTimer = Timer.periodic(_getSimulationInterval(), (timer) {
      if (_isPaused || _isRaceFinished) return;

      if (_completedLaps >= _totalLaps) {
        _finishRace(completer, timer);
        return;
      }

      _completedLaps++;
      _simulateLap();

      // إرسال تحديث اللفة
      _raceStreamController.add(_createLapUpdate());
    });

    return completer.future;
  }

  // void _simulateLap() {
  //   // تحديث حالة السيارة
  //   _updateCarStatus();

  //   // Pit Stop تلقائي
  //   _handlePitStop();

  //   // تغيير الطقس
  //   _updateWeather();

  //   // تحديث المركز
  //   _updatePosition();

  //   // تحديث DRS
  //   _updateDRS();

  //   // إضافة أحداث عشوائية
  //   _addRandomEvents();

  //   // تحديث مضاعف الأداء
  //   _updatePerformanceMultiplier();
  // }

  void _updateCarStatus() {
    final fuelConsumption = calculateRealisticFuelConsumption(
      _strategy,
      _completedLaps,
      _currentWeather,
    );

    final tireWear = calculateRealisticTireWear(
      _strategy,
      _completedLaps,
      _currentWeather,
    );

    _currentFuel = (_currentFuel - fuelConsumption).clamp(0, 100);
    _currentTireWear = (_currentTireWear - tireWear).clamp(0, 100);
  }

  void _handlePitStop() {
    if (!_hasPitted && _completedLaps >= _actualPitStopLap) {
      final pitStopResult = executePitStop(
        currentStrategy: _strategy,
        newTireChoice: _strategy.tireChoice,
        currentLap: _completedLaps,
        currentFuel: _currentFuel,
        refuelAmount: (_strategy.fuelLoad - _currentFuel).clamp(0, _strategy.fuelLoad).toInt(),
      );

      _raceEvents.add("🛞 Pit Stop! ⏱️ ${pitStopResult['timeLost'] ~/ 1000} ثانية");
      
      if (pitStopResult['hadIssues'] == true) {
        _raceEvents.add("⚠️ مشكلة في Pit Stop - وقت إضافي!");
      }

      _currentTireWear = pitStopResult['newTireWear'];
      _currentFuel = pitStopResult['newFuelLevel'];
      _hasPitted = true;

      _raceStreamController.add({
        'type': 'pit_stop',
        'lap': _completedLaps,
        'timeLost': pitStopResult['timeLost'],
        'tireWear': _currentTireWear,
        'fuelLevel': _currentFuel,
        'newTireType': pitStopResult['tireType'],
        'hadIssues': pitStopResult['hadIssues'],
      });
    }
  }

  void _updateWeather() {
    if (_random.nextDouble() < _getWeatherChangeProbability()) {
      final oldWeather = _currentWeather;
      _currentWeather = _simulateWeatherChange(_currentWeather);
      
      if (oldWeather != _currentWeather) {
        _raceEvents.add("🌦️ تغير الطقس: ${_getWeatherName(oldWeather)} → ${_getWeatherName(_currentWeather)}");
        
        // تحذير إذا كانت الإطارات غير مناسبة
        if (_currentWeather == WeatherType.wet && _strategy.tireChoice != TireType.wet) {
          _raceEvents.add("⚠️ تحذير: الإطارات غير مناسبة للطقس الممطر!");
        }
      }
    }
  }

  double _getWeatherChangeProbability() {
    switch (_currentWeather) {
      case WeatherType.dry:
        return 0.08;
      case WeatherType.changeable:
        return 0.15;
      case WeatherType.wet:
        return 0.12;
    }
  }

  void _updatePosition() {
    final oldPosition = _currentPosition;
    
    _currentPosition = _calculateAdvancedPosition();

    // حساب التجاوزات
    if (_currentPosition < oldPosition) {
      final overtakes = oldPosition - _currentPosition;
      _totalOvertakes += overtakes;
      _consecutiveOvertakes += overtakes;
      
      if (overtakes > 1) {
        _raceEvents.add("🚀 تقدم سريع! ${overtakes} مراكز");
      } else {
        _raceEvents.add("🎯 تجاوز ناجح! المركز $_currentPosition");
      }
    } else if (_currentPosition > oldPosition) {
      _consecutiveOvertakes = 0;
      _raceEvents.add("🔻 تراجع للمركز $_currentPosition");
    }
  }

  int _calculateAdvancedPosition() {
    double performanceScore = _calculatePerformanceScore();
    
    // تأثير المركز الحالي (كلما تقدمت يصعب التقدم أكثر)
    double positionFactor = (21 - _currentPosition) / 20.0;
    
    // حساب الفرص النهائية
    double advanceChance = (performanceScore * 0.6) + (positionFactor * 0.4);
    double dropChance = ((1.0 - performanceScore) * 0.5);
    
    // تطبيق الفرص
    int newPosition = _currentPosition;
    
    if (_currentPosition > 1 && _random.nextDouble() < advanceChance) {
      newPosition--;
      // فرص للتقدم مركز إضافي
      if (performanceScore > 0.8 && _random.nextDouble() < 0.3) {
        newPosition--;
      }
    }
    
    if (_currentPosition < 20 && _random.nextDouble() < dropChance) {
      newPosition++;
    }
    
    return newPosition.clamp(1, 20);
  }

  double _calculatePerformanceScore() {
    double score = 1.0;
    
    // تأثير الإطارات
    if (_currentTireWear < 30) score *= 0.7;
    else if (_currentTireWear < 50) score *= 0.85;
    else if (_currentTireWear > 80) score *= 1.05;
    
    // تأثير الوقود
    if (_currentFuel < 20) score *= 0.8;
    else if (_currentFuel < 40) score *= 0.9;
    else if (_currentFuel > 80) score *= 1.02;
    
    // تأثير الإستراتيجية
    switch (_strategy.aggression) {
      case AggressionLevel.aggressive:
        score *= _random.nextDouble() < 0.6 ? 1.2 : 0.8;
        break;
      case AggressionLevel.conservative:
        score *= 0.95;
        break;
      case AggressionLevel.balanced:
        score *= 1.0;
        break;
    }
    
    // تأثير الطقس
    if (_currentWeather == WeatherType.wet && _strategy.tireChoice != TireType.wet) {
      score *= 0.7;
    }
    
    // تأثير الزخم
    if (_consecutiveOvertakes > 0) {
      score *= (1.0 + (_consecutiveOvertakes * 0.05));
    }
    
    // تأثير DRS
    if (_hasDRS) {
      score *= 1.03;
    }
    
    return score.clamp(0.3, 1.5);
  }

  void _updateDRS() {
    _hasDRS = _currentPosition > 1 && _completedLaps > 2 && _random.nextDouble() < 0.7;
  }

  void _addRandomEvents() {
    if (_completedLaps == 1) {
      _raceEvents.add("🏁 بداية السباق! ${_getWeatherName(_currentWeather)}");
    }

    // أحداث متعلقة بحالة السيارة
    if (_currentTireWear < 30 && _random.nextDouble() < 0.25) {
      _raceEvents.add("🔄 الإطارات متآكلة بشدة - تأثر الأداء");
    }

    if (_currentFuel < 25 && _random.nextDouble() < 0.3) {
      _raceEvents.add("⛽ وقود منخفض - تقليل الأداء");
    }

    // أحداث عشوائية
    if (_random.nextDouble() < 0.12) {
      final events = [
        "⚡ سرعة عالية في القطاع المستقيم",
        "🌟 أداء ممتاز في المنعطفات",
        "🛠️ ضبط دقيق للإعدادات",
        "🎯 تخطيط استراتيجي ناجح",
      ];
      _raceEvents.add(events[_random.nextInt(events.length)]);
    }

    // أحداث المنافسة
    if (_currentPosition <= 3 && _random.nextDouble() < 0.2) {
      _raceEvents.add("🔥 منافسة شرسة على المركز $_currentPosition");
    }
  }

  void _updatePerformanceMultiplier() {
    _performanceMultiplier = _calculatePerformanceScore();
  }

  // Map<String, dynamic> _createLapUpdate() {
  //   return {
  //     'type': 'lap_update',
  //     'currentLap': _completedLaps,
  //     'totalLaps': _totalLaps,
  //     'position': _currentPosition,
  //     'weather': _currentWeather,
  //     'fuelLevel': _currentFuel,
  //     'tireWear': _currentTireWear,
  //     'events': List<String>.from(_raceEvents),
  //     'performanceMultiplier': _performanceMultiplier,
  //     'hasDRS': _hasDRS,
  //     'overtakes': _totalOvertakes,
  //     'consecutiveOvertakes': _consecutiveOvertakes,
  //   };
  // }

  void _finishRace(Completer<Map<String, dynamic>> completer, Timer timer) {
    timer.cancel();
    _isRaceFinished = true;

    // إنشاء نتائج واقعية بدون الاعتماد على AdvancedRaceEngine
    final finalResult = {
      'finalPosition': _currentPosition,
      'driver1Position': _currentPosition,
      'driver2Position': _currentPosition,
      'pointsEarned': _calculatePoints(_currentPosition),
      'prizeMoney': _calculatePrizeMoney(_currentPosition, _difficulty),
      'raceEvents': List<String>.from(_raceEvents),
      'overtakes': _totalOvertakes,
      'fastestLap': _currentPosition <= 3 && _random.nextDouble() < 0.3,
      'strategyRating': _calculateStrategyRating(_currentPosition),
      'completedLaps': _completedLaps,
      'pitStopLap': _actualPitStopLap,
      'finalWeather': _currentWeather,
      'raceStandings': _generateRaceStandings(),
    };

    _raceEvents.add("🏁 نهاية السباق! المركز النهائي: $_currentPosition");

    _raceStreamController.add({
      'type': 'race_finished',
      'finalResult': finalResult
    });

    completer.complete(finalResult);
  }

  String _formatRaceTime(int position) {
    if (position == 1) return '1:30.500';
    double gap = (position - 1) * 2.5 + (position * 0.3);
    return '+${gap.toStringAsFixed(3)}';
  }

  // تحكم في سرعة المحاكاة
  void setSimulationSpeed(int speed) {
    _currentSimulationSpeed = speed.clamp(1, 3);
    if (_simulationTimer != null && !_isRaceFinished) {
      _simulationTimer?.cancel();
      _runLiveSimulation();
    }
  }

  void pauseSimulation() {
    _isPaused = true;
  }

  void resumeSimulation() {
    _isPaused = false;
  }

  Duration _getSimulationInterval() {
    switch (_currentSimulationSpeed) {
      case 1:
        return Duration(seconds: 2);
      case 2:
        return Duration(seconds: 1);
      case 3:
        return Duration(milliseconds: 500);
      default:
        return Duration(seconds: 2);
    }
  }

  // الدوال المساعدة
  WeatherType _simulateWeatherChange(WeatherType current) {
    switch (current) {
      case WeatherType.dry:
        return _random.nextDouble() < 0.3 ? WeatherType.changeable : WeatherType.dry;
      case WeatherType.changeable:
        return _random.nextDouble() < 0.4 ? WeatherType.wet : WeatherType.changeable;
      case WeatherType.wet:
        return _random.nextDouble() < 0.2 ? WeatherType.changeable : WeatherType.wet;
    }
  }

  String _getWeatherName(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry:
        return 'جاف';
      case WeatherType.changeable:
        return 'متغير';
      case WeatherType.wet:
        return 'ممطر';
    }
  }

  // int _calculatePoints(int position) {
  //   List<int> points = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1];
  //   return position <= points.length ? points[position - 1] : 0;
  // }

  int _calculatePrizeMoney(int position, double difficulty) {
    List<int> base = [
      1000000, 750000, 500000, 400000, 300000,
      250000, 200000, 150000, 100000, 50000,
    ];
    int basePrize = position <= base.length ? base[position - 1] : 25000;
    return (basePrize * (1.0 + difficulty)).toInt();
  }

  int _calculateStrategyRating(int position) {
    int rating = (100 - (position - 1) * 5);
    
    // مكافأة على التجاوزات
    rating += (_totalOvertakes * 2);
    
    // عقوبة على Pit Stop المتأخر
    if (!_hasPitted && _completedLaps > _totalLaps * 0.8) {
      rating -= 10;
    }
    
    // مكافأة على الإستراتيجية الناجحة
    if (position <= 5) {
      rating += 15;
    }
    
    return rating.clamp(0, 100);
  }

  WeatherType _parseWeather(dynamic weatherData) {
    if (weatherData is WeatherType) return weatherData;
    if (weatherData is String) {
      switch (weatherData) {
        case 'dry':
          return WeatherType.dry;
        case 'wet':
          return WeatherType.wet;
        case 'changeable':
          return WeatherType.changeable;
        default:
          return WeatherType.dry;
      }
    }
    return WeatherType.dry;
  }

  void dispose() {
    _simulationTimer?.cancel();
    _raceStreamController.close();
  }
}