import 'package:flutter/material.dart';
import 'package:myapp/models/race_event.dart';
import 'package:myapp/utils/team_manager.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../services/save_manager.dart';
import '../services/simulation_service.dart';
import '../models/race_strategy.dart';
import '../models/race_result.dart';
import '../utils/constants.dart';
import '../widgets/strategy_panel.dart';
import '../widgets/live_race_view.dart';
import 'results_page.dart';

class RacePage extends StatefulWidget {
  final RaceEvent raceEvent;
  final int round;

  const RacePage({
    super.key,
    required this.raceEvent,
    required this.round,
  });

  @override
  State<RacePage> createState() => _RacePageState();
}

class _RacePageState extends State<RacePage> {
   late RaceStrategy _currentStrategy;
  late SimulationService _simulationService;
  bool _isSimulating = false;
  Map<String, dynamic>? _lastRaceUpdate;
  late WeatherType _currentWeather;
  late int _currentRace;
  List<String> _raceEvents = [];
  int _currentLap = 1;
  int _currentPosition = 10;

  @override
  void initState() {
    super.initState();
    _currentStrategy = RaceStrategy();
    _simulationService = SimulationService();
    _currentWeather = widget.raceEvent.baseWeather;
    _currentRace = widget.round;
    _setupSimulationListener();
  }

  void _loadCurrentRaceData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final saveManager = Provider.of<SaveManager>(context, listen: false);
      setState(() {
        _currentRace = saveManager.currentRace;
        _currentWeather = _generateRandomWeather(_currentRace);
      });
    });
  }

  WeatherType _generateRandomWeather(int raceNumber) {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    if (raceNumber <= 3) {
      return WeatherType.dry;
    } else if (raceNumber <= 8) {
      if (random < 70) return WeatherType.dry;
      if (random < 90) return WeatherType.changeable;
      return WeatherType.wet;
    } else {
      if (random < 60) return WeatherType.dry;
      if (random < 85) return WeatherType.changeable;
      return WeatherType.wet;
    }
  }

   void _setupSimulationListener() {
  _simulationService.raceStream.listen((update) {
    if (!mounted) return;

    if (update['type'] == 'race_finished') {
      _onRaceFinished(update['finalResult']);
    } else {
      setState(() {
        _lastRaceUpdate = update;
        _currentWeather = update['weather'] ?? _currentWeather;
        _currentLap = update['currentLap'] ?? _currentLap;
        _currentPosition = update['position'] ?? _currentPosition;
        
        // ✅ التأكد من أن اللفة لا تتجاوز العدد الكلي
        if (_currentLap > widget.raceEvent.totalLaps) {
          _currentLap = widget.raceEvent.totalLaps;
        }
        
        if (update['event'] != null) {
          _raceEvents.add(update['event']);
        }
      });
    }
  });
}

  void _onRaceFinished(Map<String, dynamic> result) {
  if (!mounted) return;

  final saveManager = Provider.of<SaveManager>(context, listen: false);
  
  final raceResult = RaceResult(
    finalPosition: result['finalPosition'] ?? 0,
    driver1Position: result['driver1Position'] ?? result['finalPosition'] ?? 0,
    driver2Position: result['driver2Position'] ?? result['finalPosition'] ?? 0,
    pointsEarned: result['pointsEarned'] ?? 0,
    prizeMoney: result['prizeMoney'] ?? 0,
    raceEvents: List<String>.from(result['raceEvents'] ?? []),
    overtakes: result['overtakes'] ?? 0,
    fastestLap: result['fastestLap'] ?? false,
    strategyRating: result['strategyRating'] ?? 0,
    completedLaps: result['completedLaps'] ?? 0,
    pitStopLap: result['pitStopLap'] ?? 20,
    weather: _parseWeather(result['finalWeather']),
    difficulty: double.tryParse(result['difficulty']?.toString() ?? '0.5') ?? 0.5,
    raceStandings: List<Map<String, dynamic>>.from(result['raceStandings'] ?? []),
  );

  // تحديث الفريق
  final team = saveManager.playerTeam!;
  team.points += raceResult.pointsEarned;
  team.budget += raceResult.prizeMoney;
  if (raceResult.finalPosition == 1) {
    team.racesWon++;
  }

  saveManager.saveGame(team: team, newResult: raceResult);

  // الانتقال لصفحة النتائج
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ResultsPage(raceResult: raceResult),
    ),
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
  void _startRace() async {
    if (_isSimulating) return;

    setState(() {
      _isSimulating = true;
      _lastRaceUpdate = null;
      _raceEvents.clear();
      _currentLap = 1;
      _currentPosition = 10;
    });

    final saveManager = Provider.of<SaveManager>(context, listen: false);
    final team = saveManager.playerTeam!;

    // استخدام النظام الجديد مع دعم القديم
    final aiTeams = _createSmartAITeams(team, _currentRace);

    await _simulationService.simulateFullRace(
      playerTeam: team,
      strategy: _currentStrategy,
      aiTeams: aiTeams,
      currentRaceNumber: _currentRace,
      raceEvent: widget.raceEvent, // ✅ إضافة معلومات السباق
    );
  }

  List<Team> _createSmartAITeams(Team playerTeam, int currentRace) {
    final presetTeams = TeamManager.getPresetTeams().where((team) => team.id != playerTeam.id).toList();
    final aiDifficulty = _calculateAIDifficulty(currentRace);
    
    return presetTeams.map((teamData) {
      final performanceMultiplier = _getAIPerformanceMultiplier(presetTeams.indexOf(teamData), aiDifficulty);
      
      return Team(
        id: teamData.id,
        name: teamData.name,
        country: teamData.country,
        foundingYear: teamData.foundingYear,
        budget: teamData.budget,
        carPerformance: teamData.carPerformance * performanceMultiplier,
        enginePower: teamData.enginePower,
        aerodynamics: teamData.aerodynamics,
        reliability: teamData.reliability,
        championshipTarget: teamData.championshipTarget,
        budgetTarget: teamData.budgetTarget,
        developmentFocus: teamData.developmentFocus,
        driver1: teamData.driver1,
        driver2: teamData.driver2,
        reputation: teamData.reputation,
      );
    }).toList();
  }

  double _calculateAIDifficulty(int currentRace) {
    // زيادة صعوبة الـ AI مع تقدم السباقات
    if (currentRace <= 3) return 0.8; // سهلة في البداية
    if (currentRace <= 8) return 1.0; // متوسطة
    if (currentRace <= 15) return 1.2; // صعبة
    return 1.5; // شديدة الصعوبة
  }

  double _getAIPerformanceMultiplier(int teamIndex, double baseDifficulty) {
    // جعل بعض الفرق أقوى من الأخرى
    final teamStrength = [1.0, 1.1, 0.9, 1.2, 0.8, 1.1, 0.9, 1.0, 0.8, 1.3];
    final index = teamIndex % teamStrength.length;
    return baseDifficulty * teamStrength[index];
  }

  void _handleStrategyChangeDuringRace(RaceStrategy newStrategy) {
    setState(() {
      _currentStrategy = newStrategy;
    });
    
    // إضافة حدث لتغيير الإستراتيجية
    _raceEvents.add("🔄 تغيير في الإستراتيجية: ${_getStrategyChangeDescription(newStrategy)}");
  }

  String _getStrategyChangeDescription(RaceStrategy newStrategy) {
    final changes = <String>[];
    
    if (newStrategy.tireChoice != _currentStrategy.tireChoice) {
      changes.add("الإطارات إلى ${_getTireName(newStrategy.tireChoice)}");
    }
    
    if (newStrategy.aggression != _currentStrategy.aggression) {
      changes.add("العدوانية إلى ${_getAggressionName(newStrategy.aggression)}");
    }
    
    if (newStrategy.pitStopLap != _currentStrategy.pitStopLap) {
      changes.add("Pit Stop إلى لفة ${newStrategy.pitStopLap}");
    }
    
    return changes.join("، ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.raceEvent.name),
        backgroundColor: const Color(0xFF1D1E33),
      ),
      backgroundColor: const Color(0xFF0A0E21),
      body: _isSimulating ? _buildLiveRaceView() : _buildStrategySetup(),
    );
  }


  Widget _buildStrategySetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // معلومات السباق (محدثة)
          Card(
            color: const Color(0xFF1D1E33),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    widget.raceEvent.name,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.raceEvent.circuitName} - ${widget.raceEvent.city}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRaceInfoItem('اللفات', '${widget.raceEvent.totalLaps}'),
                      _buildRaceInfoItem('الطقس', widget.raceEvent.weatherEmoji),
                      _buildRaceInfoItem('الصعوبة', widget.raceEvent.difficultyLevel),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // StrategyPanel القديم (متوافق)
          StrategyPanel(
            onStrategyChanged: (strategy) {
              setState(() {
                _currentStrategy = strategy;
              });
            },
            initialStrategy: _currentStrategy,
            currentWeather: _currentWeather,
            currentRace: _currentRace,
          ),

          SizedBox(height: 20),

          // معاينة الإستراتيجية
          // _buildStrategyPreview(),

          SizedBox(height: 30),

          // زر بدء السباق
          ElevatedButton(
            onPressed: _startRace,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC0000),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: const Text('بدء السباق', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildRaceInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
  Widget _buildDifficultyIndicator() {
    final difficulty = _calculateAIDifficulty(_currentRace);
    String difficultyText;
    Color color;
    
    if (difficulty <= 0.9) {
      difficultyText = 'سهلة 🟢';
      color = Colors.green;
    } else if (difficulty <= 1.1) {
      difficultyText = 'متوسطة 🟡';
      color = Colors.orange;
    } else if (difficulty <= 1.3) {
      difficultyText = 'صعبة 🔴';
      color = Colors.red;
    } else {
      difficultyText = 'شديدة الصعوبة 💀';
      color = Colors.purple;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            'صعوبة المنافسين: $difficultyText',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildStrategyPreview() {
  //   final score = _currentStrategy.calculateStrategyScore(_currentWeather);

  //   return Card(
  //     color: const Color(0xFF1D1E33),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               const Text(
  //                 'ملخص الإستراتيجية:',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const Spacer(),
  //               Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //                 decoration: BoxDecoration(
  //                   color: _getScoreColor(score).withOpacity(0.2),
  //                   borderRadius: BorderRadius.circular(20),
  //                   border: Border.all(color: _getScoreColor(score)),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Icon(
  //                       _getStrategyIcon(score),
  //                       size: 16,
  //                       color: _getScoreColor(score),
  //                     ),
  //                     const SizedBox(width: 4),
  //                     Text(
  //                       score.toStringAsFixed(1),
  //                       style: TextStyle(
  //                         color: _getScoreColor(score),
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 12),
  //           _buildStrategyItem('نوع الإطارات', _currentStrategy.tireName, _getTireEmoji(_currentStrategy.tireChoice)),
  //           _buildStrategyItem('لفة Pit Stop', '${_currentStrategy.pitStopLap}', '⏱️'),
  //           _buildStrategyItem('مستوى العدوانية', _currentStrategy.aggressionName, _getAggressionEmoji(_currentStrategy.aggression)),
  //           _buildStrategyItem('تحميل الوقود', '${_currentStrategy.fuelLoad}%', '⛽'),
  //           _buildStrategyItem('حالة الطقس', _getWeatherName(_currentWeather), _getWeatherEmoji(_currentWeather)),
  //           const SizedBox(height: 12),
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: Colors.blueGrey[800],
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: Text(
  //               _getStrategyFeedback(score),
  //               style: TextStyle(
  //                 color: _getScoreColor(score),
  //                 fontWeight: FontWeight.bold,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStrategyItem(String label, String value, String emoji) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ استخدام LiveRaceView مع البيانات المطلوبة
  Widget _buildLiveRaceView() {
    return LiveRaceView(
      strategy: _currentStrategy,
      onStrategyChange: _handleStrategyChangeDuringRace,
      currentWeather: _currentWeather, // ✅ مطلوب للعرض
      currentLap: _currentLap, // ✅ مطلوب للتقدم
      totalLaps: widget.raceEvent.totalLaps, // ✅ مطلوب للتقدم
      currentPosition: _currentPosition, // ✅ مطلوب للمركز
      raceEvents: _raceEvents, // ✅ مطلوب للأحداث
    );
  }

  // دوال المساعدة
  Color _getPositionColor(int position) {
    if (position == 1) return Colors.yellow;
    if (position <= 3) return const Color(0xFFC0C0C0);
    if (position <= 10) return Colors.green;
    return Colors.blueGrey;
  }

  IconData _getStrategyIcon(double score) {
    if (score >= 80) return Icons.emoji_events;
    if (score >= 60) return Icons.thumb_up;
    return Icons.warning;
  }

  String _getStrategyFeedback(double score) {
    if (score >= 80) return 'إستراتيجية ممتازة! لديك فرصة كبيرة للفوز 🏆';
    if (score >= 60) return 'إستراتيجية جيدة، قد تحتاج لبعض التحسينات ✅';
    return 'إستراتيجية محفوفة بالمخاطر، فكر في التعديل ⚠️';
  }

  String _getTireEmoji(TireType tire) {
    switch (tire) {
      case TireType.soft: return '🔴';
      case TireType.medium: return '🟡';
      case TireType.hard: return '⚪';
      case TireType.wet: return '🔵';
    }
  }

  String _getAggressionEmoji(AggressionLevel aggression) {
    switch (aggression) {
      case AggressionLevel.conservative: return '🐢';
      case AggressionLevel.balanced: return '⚖️';
      case AggressionLevel.aggressive: return '💥';
    }
  }

  String _getWeatherEmoji(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry: return '☀️';
      case WeatherType.changeable: return '🌤️';
      case WeatherType.wet: return '🌧️';
    }
  }

  String _getWeatherName(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry: return 'جاف';
      case WeatherType.changeable: return 'متغير';
      case WeatherType.wet: return 'ممطر';
    }
  }

  Color _getWeatherColor(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry:
        return Colors.orange;
      case WeatherType.changeable:
        return Colors.blueGrey;
      case WeatherType.wet:
        return Colors.blue;
    }
  }

  String _getWeatherDisplay(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry:
        return 'طقس جاف';
      case WeatherType.changeable:
        return 'طقس متغير';
      case WeatherType.wet:
        return 'طقس ممطر';
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getTireName(TireType tire) {
    return AppConstants.getTireName(tire);
  }

  String _getAggressionName(AggressionLevel aggression) {
    return AppConstants.getAggressionName(aggression);
  }
  

  @override
  void dispose() {
    _simulationService.dispose();
    super.dispose();
  }
}