import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/race_strategy.dart';
import '../services/simulation_service.dart';
import '../utils/constants.dart';

class ModernLiveRaceView extends StatefulWidget {
  final RaceStrategy strategy;
  final Function(RaceStrategy) onStrategyChange;
  final WeatherType currentWeather;
  final int totalLaps;
  final EnhancedSimulationService simulationService;

  const ModernLiveRaceView({
    super.key,
    required this.strategy,
    required this.onStrategyChange,
    required this.currentWeather,
    required this.totalLaps,
    required this.simulationService,
  });

  @override
  State<ModernLiveRaceView> createState() => _ModernLiveRaceViewState();
}

class _ModernLiveRaceViewState extends State<ModernLiveRaceView> {
  // حالة السباق
  int _currentLap = 1;
  int _currentPosition = 10;
  double _tireWear = 100.0;
  double _fuelLevel = 100.0;
  WeatherType _currentWeather = WeatherType.dry;
  List<String> _raceEvents = [];
  int _simulationSpeed = 1;
  bool _isRaceFinished = false;
  bool _isPaused = false;
  Timer? _simulationTimer;
  bool _isInPitStop = false;
  int _pitStopTimeRemaining = 0;
  double _performanceMultiplier = 1.0;
  bool _hasDRS = false;
  int _totalOvertakes = 0;
  int _consecutiveOvertakes = 0;

  StreamSubscription? _raceSubscription;

  @override
  void initState() {
    super.initState();
    _initializeRace();
    _listenToSimulation();
    _startLocalSimulation();
  }

  void _initializeRace() {
    _currentLap = 1;
    _currentPosition = 10;
    _tireWear = 100.0;
    _fuelLevel = widget.strategy.fuelLoad.toDouble();
    _currentWeather = widget.currentWeather;
    _raceEvents.clear();
    _isRaceFinished = false;
    _isInPitStop = false;
    _pitStopTimeRemaining = 0;
    _performanceMultiplier = 1.0;
    _hasDRS = false;
    _totalOvertakes = 0;
    _consecutiveOvertakes = 0;
  }

  void _listenToSimulation() {
    _raceSubscription = widget.simulationService.raceStream.listen((update) {
      if (mounted) {
        setState(() {
          _handleRaceUpdate(update);
        });
      }
    });
  }

  void _handleRaceUpdate(Map<String, dynamic> update) {
    switch (update['type']) {
      case 'lap_update':
        _currentLap = update['currentLap'];
        _currentPosition = update['position'];
        _currentWeather = update['weather'];
        _fuelLevel = update['fuelLevel'] ?? _fuelLevel;
        _tireWear = update['tireWear'] ?? _tireWear;
        _performanceMultiplier = update['performanceMultiplier'] ?? _performanceMultiplier;
        _hasDRS = update['hasDRS'] ?? _hasDRS;
        _totalOvertakes = update['overtakes'] ?? _totalOvertakes;
        _consecutiveOvertakes = update['consecutiveOvertakes'] ?? _consecutiveOvertakes;
        if (update['events'] != null) {
          _raceEvents.addAll(List<String>.from(update['events']));
        }
        break;

      case 'pit_stop':
        _tireWear = update['tireWear'];
        _fuelLevel = update['fuelLevel'];
        _isInPitStop = false;
        _pitStopTimeRemaining = 0;
        
        String pitStopMessage = "🛞 Pit Stop - ⏱️ ${update['timeLost'] ~/ 1000} ثانية";
        if (update['hadIssues'] == true) {
          pitStopMessage += " ⚠️ مشكلة في Pit Stop";
        }
        _raceEvents.add(pitStopMessage);
        break;

      case 'race_finished':
        _isRaceFinished = true;
        _simulationTimer?.cancel();
        _showRaceResultDialog(update['finalResult']);
        break;
    }
  }

  // محاكاة محلية مستقلة
  void _startLocalSimulation() {
    _simulationTimer?.cancel();

    _simulationTimer = Timer.periodic(_getSimulationInterval(), (timer) {
      if (_isPaused || _isRaceFinished || _isInPitStop) {
        return;
      }

      if (_currentLap >= widget.totalLaps) {
        _finishRace();
        timer.cancel();
        return;
      }

      setState(() {
        _currentLap++;
        _updateRaceStatus();
        _addRandomEvents();
      });
    });
  }

  void _updateRaceStatus() {
    final fuelConsumption = _calculateFuelConsumption();
    final tireWear = _calculateTireWear();

    _fuelLevel = (_fuelLevel - fuelConsumption).clamp(0, 100);
    _tireWear = (_tireWear - tireWear).clamp(0, 100);

    _updatePosition();
    _updateDRS();
    _updatePerformanceMultiplier();

    if (!_isRaceFinished && !_isInPitStop && _currentLap == widget.strategy.pitStopLap) {
      _executeAutomaticPitStop();
    }
  }

  double _calculateFuelConsumption() {
    double baseConsumption = 2.2;
    
    switch (widget.strategy.aggression) {
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
    
    switch (_currentWeather) {
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
    
    double lapFactor = 1.0 - (_currentLap * 0.002);
    baseConsumption *= lapFactor.clamp(0.8, 1.0);
    
    return baseConsumption;
  }

  double _calculateTireWear() {
    double wear = 0.0;
    
    switch (widget.strategy.tireChoice) {
      case TireType.soft:
        wear = 2.0 + (_currentLap * 0.025);
        break;
      case TireType.medium:
        wear = 1.4 + (_currentLap * 0.018);
        break;
      case TireType.hard:
        wear = 0.9 + (_currentLap * 0.012);
        break;
      case TireType.wet:
        wear = 1.6 + (_currentLap * 0.020);
        break;
    }
    
    if (_currentWeather == WeatherType.wet && widget.strategy.tireChoice != TireType.wet) {
      wear *= 2.2;
    } else if (_currentWeather == WeatherType.dry && widget.strategy.tireChoice == TireType.wet) {
      wear *= 1.9;
    }
    
    if (_currentWeather == WeatherType.dry) {
      wear *= 1.1;
    }
    
    return wear.clamp(0.5, 3.0);
  }

  void _updatePosition() {
    final random = Random();
    final oldPosition = _currentPosition;
    
    _currentPosition = _calculateAdvancedPosition();

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
    final random = Random();
    double performanceScore = _calculatePerformanceScore();
    
    double positionFactor = (21 - _currentPosition) / 20.0;
    
    double advanceChance = (performanceScore * 0.6) + (positionFactor * 0.4);
    double dropChance = ((1.0 - performanceScore) * 0.5);
    
    int newPosition = _currentPosition;
    
    if (_currentPosition > 1 && random.nextDouble() < advanceChance) {
      newPosition--;
      if (performanceScore > 0.8 && random.nextDouble() < 0.3) {
        newPosition--;
      }
    }
    
    if (_currentPosition < 20 && random.nextDouble() < dropChance) {
      newPosition++;
    }
    
    return newPosition.clamp(1, 20);
  }

  double _calculatePerformanceScore() {
    double score = 1.0;
    
    if (_tireWear < 30) score *= 0.7;
    else if (_tireWear < 50) score *= 0.85;
    else if (_tireWear > 80) score *= 1.05;
    
    if (_fuelLevel < 20) score *= 0.8;
    else if (_fuelLevel < 40) score *= 0.9;
    else if (_fuelLevel > 80) score *= 1.02;
    
    switch (widget.strategy.aggression) {
      case AggressionLevel.aggressive:
        score *= Random().nextDouble() < 0.6 ? 1.2 : 0.8;
        break;
      case AggressionLevel.conservative:
        score *= 0.95;
        break;
      case AggressionLevel.balanced:
        score *= 1.0;
        break;
    }
    
    if (_currentWeather == WeatherType.wet && widget.strategy.tireChoice != TireType.wet) {
      score *= 0.7;
    }
    
    if (_consecutiveOvertakes > 0) {
      score *= (1.0 + (_consecutiveOvertakes * 0.05));
    }
    
    if (_hasDRS) {
      score *= 1.03;
    }
    
    return score.clamp(0.3, 1.5);
  }

  void _updateDRS() {
    _hasDRS = _currentPosition > 1 && _currentLap > 2 && Random().nextDouble() < 0.7;
  }

  void _updatePerformanceMultiplier() {
    _performanceMultiplier = _calculatePerformanceScore();
  }

  void _addRandomEvents() {
    final random = Random();

    if (_currentLap == 1) {
      _raceEvents.add("🏁 بداية السباق! ${_getWeatherName(_currentWeather)}");
    }

    if (_tireWear < 30 && random.nextDouble() < 0.25) {
      _raceEvents.add("🔄 الإطارات متآكلة بشدة - تأثر الأداء");
    }

    if (_fuelLevel < 25 && random.nextDouble() < 0.3) {
      _raceEvents.add("⛽ وقود منخفض - تقليل الأداء");
    }

    if (random.nextDouble() < 0.12) {
      final events = [
        "⚡ سرعة عالية في القطاع المستقيم",
        "🌟 أداء ممتاز في المنعطفات",
        "🛠️ ضبط دقيق للإعدادات",
        "🎯 تخطيط استراتيجي ناجح",
      ];
      _raceEvents.add(events[random.nextInt(events.length)]);
    }

    if (_currentPosition <= 3 && random.nextDouble() < 0.2) {
      _raceEvents.add("🔥 منافسة شرسة على المركز $_currentPosition");
    }

    if (random.nextDouble() < 0.08) {
      final oldWeather = _currentWeather;
      _currentWeather = _simulateWeatherChange(_currentWeather);
      if (oldWeather != _currentWeather) {
        _raceEvents.add("🌦️ تغير الطقس: ${_getWeatherName(oldWeather)} → ${_getWeatherName(_currentWeather)}");
      }
    }
  }

  WeatherType _simulateWeatherChange(WeatherType current) {
    switch (current) {
      case WeatherType.dry:
        return Random().nextDouble() < 0.3 ? WeatherType.changeable : WeatherType.dry;
      case WeatherType.changeable:
        return Random().nextDouble() < 0.4 ? WeatherType.wet : WeatherType.changeable;
      case WeatherType.wet:
        return Random().nextDouble() < 0.2 ? WeatherType.changeable : WeatherType.wet;
    }
  }

  void _executeAutomaticPitStop() {
    if (!_isInPitStop) {
      _raceEvents.add("🛞 Pit Stop تلقائي في اللفة $_currentLap");
      _startPitStop(widget.strategy.tireChoice, 100);
    }
  }

  void _startPitStop(TireType newTire, int fuelToAdd) {
    setState(() {
      _isInPitStop = true;
      _pitStopTimeRemaining = 22;
    });

    _simulationTimer?.cancel();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _pitStopTimeRemaining--;
      });

      if (_pitStopTimeRemaining <= 0) {
        timer.cancel();
        _completePitStop(newTire, fuelToAdd);
      }
    });
  }

  void _completePitStop(TireType newTire, int fuelToAdd) {
    setState(() {
      _tireWear = 100.0;
      _fuelLevel = (_fuelLevel + fuelToAdd).clamp(0, widget.strategy.fuelLoad.toDouble());
      _isInPitStop = false;
      _pitStopTimeRemaining = 0;
    });

    widget.onStrategyChange(widget.strategy.copyWith(tireChoice: newTire));

    _raceEvents.add("🔄 Pit Stop: ${_getTireName(newTire)} +$fuelToAdd% وقود");

    _startLocalSimulation();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم Pit Stop بنجاح! الإطارات: ${_getTireName(newTire)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _finishRace() {
    setState(() {
      _isRaceFinished = true;
      _raceEvents.add("🏁 نهاية السباق! المركز النهائي: $_currentPosition");
    });

    _showRaceResultDialog({
      'finalPosition': _currentPosition,
      'pointsEarned': _calculatePoints(_currentPosition),
      'prizeMoney': _calculatePrizeMoney(_currentPosition),
      'fastestLap': _currentPosition <= 3 && Random().nextDouble() < 0.3,
      'overtakes': _totalOvertakes,
      'strategyRating': _calculateStrategyRating(),
    });
  }

  int _calculateStrategyRating() {
    int rating = (100 - (_currentPosition - 1) * 5);
    
    rating += (_totalOvertakes * 2);
    
    if (!_isInPitStop && _currentLap > widget.totalLaps * 0.8) {
      rating -= 10;
    }
    
    if (_currentPosition <= 5) {
      rating += 15;
    }
    
    return rating.clamp(0, 100);
  }

  void _changeSimulationSpeed(int speed) {
    setState(() {
      _simulationSpeed = speed;
    });
    _startLocalSimulation();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Duration _getSimulationInterval() {
    switch (_simulationSpeed) {
      case 1: return const Duration(seconds: 3);
      case 2: return const Duration(seconds: 2);
      case 3: return const Duration(seconds: 1);
      default: return const Duration(seconds: 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            if (_isInPitStop) _buildPitStopOverlay(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  children: [
                    _buildQuickInfo(isSmallScreen),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    _buildCarStatus(isSmallScreen),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    _buildProgressSection(isSmallScreen),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    Expanded(child: _buildEventsAndActions(isSmallScreen)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E2328), const Color(0xFF2D3439)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () {
              _simulationTimer?.cancel();
              Navigator.pop(context);
            },
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اللفة $_currentLap/${widget.totalLaps}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'المركز $_currentPosition',
                  style: TextStyle(
                    color: _getPositionColor(_currentPosition),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isPaused ? Colors.orange : Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPaused ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _isPaused ? 'متوقف' : 'جاري',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPitStopOverlay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.9)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.build, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pit Stop جاري',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '⏱️ $_pitStopTimeRemaining ثانية متبقية',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A1F24), const Color(0xFF252A30)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            'الطقس',
            _getWeatherEmoji(_currentWeather),
            _getWeatherColor(_currentWeather),
            isSmallScreen,
          ),
          _buildInfoItem(
            'الأداء',
            '${(_performanceMultiplier * 100).toInt()}%',
            _getPerformanceColor(_performanceMultiplier * 100),
            isSmallScreen,
          ),
          _buildInfoItem(
            'السرعة',
            '${_simulationSpeed}x',
            Colors.blue,
            isSmallScreen,
          ),
          _buildInfoItem(
            'Pit',
            '${widget.strategy.pitStopLap}',
            Colors.orange,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 32 : 40,
          height: isSmallScreen ? 32 : 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isSmallScreen ? 9 : 10,
          ),
        ),
      ],
    );
  }

  Widget _buildCarStatus(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A1F24), const Color(0xFF252A30)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.directions_car, color: Color(0xFFDC0000), size: 18),
              SizedBox(width: 8),
              Text(
                'حالة السيارة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusIndicator(
                  'الوقود',
                  _fuelLevel,
                  _getFuelColor(_fuelLevel),
                  Icons.local_gas_station,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 20),
              Expanded(
                child: _buildStatusIndicator(
                  'الإطارات',
                  _tireWear,
                  _getTireColor(_tireWear),
                  Icons.circle,
                  isSmallScreen,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniInfoItem('التجاوزات', '$_totalOvertakes', Icons.flag),
              _buildMiniInfoItem('DRS', _hasDRS ? 'نشط' : 'غير نشط', Icons.rocket_launch),
              _buildMiniInfoItem('الزخم', '$_consecutiveOvertakes', Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String label, double value, Color color, IconData icon, bool isSmallScreen) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: isSmallScreen ? 60 : 70,
              height: isSmallScreen ? 60 : 70,
              child: CircularProgressIndicator(
                value: value / 100,
                backgroundColor: Colors.white.withOpacity(0.1),
                color: color,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              children: [
                Icon(icon, color: color, size: isSmallScreen ? 16 : 18),
                const SizedBox(height: 2),
                Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    color: color,
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isSmallScreen ? 10 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(bool isSmallScreen) {
    return Column(
      children: [
        Container(
          height: isSmallScreen ? 10 : 12,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: 500.ms,
                width: (MediaQuery.of(context).size.width - (isSmallScreen ? 24 : 32)) * (_currentLap / widget.totalLaps),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC0000), Color(0xFFFF4D4D)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLapMarker('البداية', 1, isSmallScreen),
            _buildLapMarker('Pit Stop', widget.strategy.pitStopLap, isSmallScreen),
            _buildLapMarker('النهاية', widget.totalLaps, isSmallScreen),
          ],
        ),

        SizedBox(height: isSmallScreen ? 12 : 16),
        _buildSpeedControls(isSmallScreen),
      ],
    );
  }

  Widget _buildLapMarker(String label, int lap, bool isSmallScreen) {
    final isPassed = _currentLap >= lap;

    return Column(
      children: [
        Container(
          width: isSmallScreen ? 14 : 16,
          height: isSmallScreen ? 14 : 16,
          decoration: BoxDecoration(
            color: isPassed ? const Color(0xFFDC0000) : Colors.grey[700],
            shape: BoxShape.circle,
            boxShadow: isPassed ? [BoxShadow(color: const Color(0xFFDC0000).withOpacity(0.6), blurRadius: 8)] : null,
          ),
          child: isPassed ? Icon(Icons.check, size: isSmallScreen ? 8 : 10, color: Colors.white) : null,
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          label,
          style: TextStyle(
            color: isPassed ? Colors.white : Colors.white54,
            fontSize: isSmallScreen ? 9 : 10,
          ),
        ),
        Text(
          'لفة $lap',
          style: TextStyle(
            color: isPassed ? Colors.white70 : Colors.white30,
            fontSize: isSmallScreen ? 7 : 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedControls(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, color: Colors.white, size: isSmallScreen ? 20 : 24),
            onPressed: _togglePause,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          SizedBox(width: isSmallScreen ? 12 : 16),

          ...['1x', '2x', '3x'].asMap().entries.map((entry) {
            final index = entry.key + 1;
            final label = entry.value;
            return GestureDetector(
              onTap: () => _changeSimulationSpeed(index),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 6 : 8),
                margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
                decoration: BoxDecoration(
                  color: _simulationSpeed == index ? const Color(0xFFDC0000) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _simulationSpeed == index ? const Color(0xFFDC0000) : Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: _simulationSpeed == index ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEventsAndActions(bool isSmallScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildEventsPanel(isSmallScreen)),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(flex: 2, child: _buildQuickActions(isSmallScreen)),
      ],
    );
  }

  Widget _buildEventsPanel(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: isSmallScreen ? 16 : 18, color: Colors.white70),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                'الأحداث',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Expanded(
            child: _raceEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available, size: isSmallScreen ? 32 : 40, color: Colors.white30),
                        SizedBox(height: isSmallScreen ? 4 : 8),
                        Text(
                          'لا توجد أحداث حالية',
                          style: TextStyle(color: Colors.white54, fontSize: isSmallScreen ? 10 : 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: _raceEvents.length,
                    itemBuilder: (context, index) {
                      final event = _raceEvents.reversed.toList()[index];
                      return _buildEventItem(event, isSmallScreen);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(String event, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(left: isSmallScreen ? 4 : 8),
            decoration: BoxDecoration(
              color: _getEventColor(event),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Text(
              event,
              style: TextStyle(color: Colors.white70, fontSize: isSmallScreen ? 10 : 12),
              maxLines: 2,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildQuickActions(bool isSmallScreen) {
    final buttonSize = isSmallScreen ? 70.0 : 80.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final fontSize = isSmallScreen ? 10.0 : 11.0;
    final subtitleSize = isSmallScreen ? 7.0 : 8.0;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, size: isSmallScreen ? 16 : 18, color: Color(0xFFDC0000)),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                'إجراءات سريعة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
              children: [
                _buildActionButton(
                  'هجوم', Icons.bolt, Colors.red, 'زيادة السرعة',
                  buttonSize, iconSize, fontSize, subtitleSize,
                  () => _changeStrategy(AggressionLevel.aggressive),
                ),
                _buildActionButton(
                  'دفاع', Icons.shield, Colors.blue, 'توفير الوقود',
                  buttonSize, iconSize, fontSize, subtitleSize,
                  () => _changeStrategy(AggressionLevel.conservative),
                ),
                _buildActionButton(
                  'متوازن', Icons.balance, Colors.green, 'أداء متوازن',
                  buttonSize, iconSize, fontSize, subtitleSize,
                  () => _changeStrategy(AggressionLevel.balanced),
                ),
                _buildActionButton(
                  'Pit Stop', Icons.build, Colors.orange, 'تغيير الإطارات',
                  buttonSize, iconSize, fontSize, subtitleSize,
                  _showAdvancedPitStopDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label, IconData icon, Color color, String subtitle,
    double size, double iconSize, double fontSize, double subtitleSize,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: iconSize),
            SizedBox(height: size * 0.05),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold)),
            SizedBox(height: size * 0.02),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: color.withOpacity(0.8), fontSize: subtitleSize), maxLines: 2),
          ],
        ),
      ),
    );
  }

  void _changeStrategy(AggressionLevel aggression) {
    widget.onStrategyChange(widget.strategy.copyWith(aggression: aggression));
    _raceEvents.add("🔄 تغيير الإستراتيجية: ${_getAggressionName(aggression)}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تغيير الإستراتيجية إلى: ${_getAggressionName(aggression)}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAdvancedPitStopDialog() {
    TireType selectedTire = widget.strategy.tireChoice;
    int fuelToAdd = (widget.strategy.fuelLoad - _fuelLevel).clamp(0, 50).toInt();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: const Color(0xFF1E2328),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.build, color: Colors.orange, size: 24),
                      SizedBox(width: 8),
                      Text('Pit Stop متقدم', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('اختر نوع الإطارات الجديدة:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
                    children: TireType.values.map((tire) {
                      return ChoiceChip(
                        label: Text('${_getTireEmoji(tire)} ${_getTireName(tire)}', style: TextStyle(color: selectedTire == tire ? Colors.white : Colors.white70, fontSize: 12)),
                        selected: selectedTire == tire,
                        onSelected: (selected) => setState(() => selectedTire = tire),
                        backgroundColor: _getTireTypeColor(tire).withOpacity(0.3),
                        selectedColor: _getTireTypeColor(tire),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('كمية الوقود الإضافية:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Slider(value: fuelToAdd.toDouble(), min: 0, max: 50, divisions: 10, onChanged: (value) => setState(() => fuelToAdd = value.toInt())),
                  Text('$fuelToAdd%', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange)),
                    child: Column(
                      children: [
                        const Text('معلومات Pit Stop', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('⏱️ الوقت المتوقع: 22 ثانية', style: const TextStyle(color: Colors.white70)),
                        Text('🔄 الإطارات: ${_getTireName(selectedTire)}', style: const TextStyle(color: Colors.white70)),
                        Text('⛽ الوقود: +$fuelToAdd%', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(backgroundColor: Colors.grey[800], padding: const EdgeInsets.symmetric(vertical: 12)),
                          child: const Text('إلغاء', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _startPitStop(selectedTire, fuelToAdd);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 12)),
                          child: const Text('تنفيذ Pit Stop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRaceResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2328),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.flag, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('انتهاء السباق', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('المركز النهائي: ${result['finalPosition']}', style: TextStyle(color: _getPositionColor(result['finalPosition']), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildResultItem('النقاط', '${result['pointsEarned']}', Icons.emoji_events),
            _buildResultItem('الجائزة', '\$${result['prizeMoney']}', Icons.attach_money),
            _buildResultItem('التجاوزات', '${result['overtakes']}', Icons.flag),
            if (result['fastestLap'] == true) _buildResultItem('أسرع لفة', 'نعم', Icons.speed),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC0000), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            child: const Text('إنهاء', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // دوال المساعدة
  Color _getPositionColor(int position) {
    if (position == 1) return const Color(0xFFFFD700);
    if (position <= 3) return const Color(0xFFC0C0C0);
    if (position <= 10) return Colors.green;
    return Colors.grey;
  }

  Color _getWeatherColor(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry: return Colors.orange;
      case WeatherType.changeable: return Colors.blueGrey;
      case WeatherType.wet: return Colors.blue;
    }
  }

  Color _getFuelColor(double level) {
    if (level > 60) return Colors.green;
    if (level > 30) return Colors.orange;
    return Colors.red;
  }

  Color _getTireColor(double wear) {
    if (wear > 70) return Colors.green;
    if (wear > 40) return Colors.orange;
    return Colors.red;
  }

  Color _getTireTypeColor(TireType tire) {
    switch (tire) {
      case TireType.soft: return Colors.red;
      case TireType.medium: return Colors.yellow;
      case TireType.hard: return Colors.white;
      case TireType.wet: return Colors.blue;
    }
  }

  Color _getPerformanceColor(double performance) {
    if (performance > 80) return Colors.green;
    if (performance > 60) return Colors.orange;
    return Colors.red;
  }

  Color _getEventColor(String event) {
    if (event.contains('🛞')) return Colors.orange;
    if (event.contains('⛽')) return Colors.red;
    if (event.contains('🌧️')) return Colors.blue;
    if (event.contains('🔄')) return Colors.purple;
    if (event.contains('⚠️')) return Colors.orange;
    return Colors.green;
  }

  String _getWeatherEmoji(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry: return '☀️';
      case WeatherType.changeable: return '🌤️';
      case WeatherType.wet: return '🌧️';
    }
  }

  String _getTireEmoji(TireType tire) {
    switch (tire) {
      case TireType.soft: return '🔴';
      case TireType.medium: return '🟡';
      case TireType.hard: return '⚪';
      case TireType.wet: return '🔵';
    }
  }

  String _getWeatherName(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry: return 'جاف';
      case WeatherType.changeable: return 'متغير';
      case WeatherType.wet: return 'ممطر';
    }
  }

  String _getAggressionName(AggressionLevel aggression) {
    return AppConstants.getAggressionName(aggression);
  }

  String _getTireName(TireType tire) {
    return AppConstants.getTireName(tire);
  }

  int _calculatePoints(int position) {
    List<int> points = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1];
    return position <= points.length ? points[position - 1] : 0;
  }

  int _calculatePrizeMoney(int position) {
    List<int> prize = [1000000, 750000, 500000, 400000, 300000, 250000, 200000, 150000, 100000, 50000];
    return position <= prize.length ? prize[position - 1] : 25000;
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _raceSubscription?.cancel();
    super.dispose();
  }
}