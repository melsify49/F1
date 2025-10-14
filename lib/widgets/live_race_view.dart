import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/race_strategy.dart';
import '../utils/constants.dart';

class LiveRaceView extends StatefulWidget {
  final RaceStrategy strategy;
  final Function(RaceStrategy) onStrategyChange;
  final WeatherType currentWeather;
  final int currentLap;
  final int totalLaps;
  final int currentPosition;
  final List<String> raceEvents;
  final Function(bool)? onSimulationStateChange;

  const LiveRaceView({
    super.key,
    required this.strategy,
    required this.onStrategyChange,
    this.currentWeather = WeatherType.dry,
    this.currentLap = 1,
    this.totalLaps = 58,
    this.currentPosition = 10,
    this.raceEvents = const [],
    this.onSimulationStateChange,
  });

  @override
  State<LiveRaceView> createState() => _LiveRaceViewState();
}

class _LiveRaceViewState extends State<LiveRaceView> {
  double _tireWear = 100.0;
  double _fuelLevel = 100.0;
  Timer? _raceTimer;
  List<String> _displayedEvents = [];
  int _simulationSpeed = 2; // سرعة ثابتة
  int _currentLap = 1;
  int _currentPosition = 10;
  bool _isRaceFinished = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _currentLap = widget.currentLap;
    _currentPosition = widget.currentPosition;
    _fuelLevel = widget.strategy.fuelLoad.toDouble();
    _displayedEvents = [...widget.raceEvents];
    _startRaceSimulation();
  }

  @override
  void didUpdateWidget(LiveRaceView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ مزامنة البيانات من الـ widget الخارجي
    if (widget.currentLap != oldWidget.currentLap) {
      _currentLap = widget.currentLap;
    }

    if (widget.currentPosition != oldWidget.currentPosition) {
      _currentPosition = widget.currentPosition;
    }
  }

  void _startRaceSimulation() {
    if (_isRaceFinished) return;

    _updateFromExternalData();

    // إلغاء أي timer سابق
    _raceTimer?.cancel();

    _raceTimer = Timer.periodic(_getSimulationInterval(), (timer) {
      if (_currentLap < widget.totalLaps && !_isRaceFinished) {
        setState(() {
          _updateRaceProgress();
        });
      } else if (_currentLap >= widget.totalLaps && !_isRaceFinished) {
        _isRaceFinished = true;
        timer.cancel();
        _showRaceFinishedDialog();
      }
    });
  }

  void _updateRaceProgress() {
    print('اللفة الحالية: $_currentLap من ${widget.totalLaps}');
  
    // ✅ التأكد من عدم تجاوز عدد اللفات الكلي
    if (_currentLap >= widget.totalLaps) {
      print('السباق انتهى!');
      _isRaceFinished = true;
      _raceTimer?.cancel();
      _showRaceFinishedDialog();
      return;
    }

    // ✅ زيادة اللفة واحدة فقط في كل مرة
    _currentLap++;

    // ✅ تحديث البيانات الأخرى
    print('تم زيادة اللفة إلى: $_currentLap');
    _updatePosition();
    _updateFromExternalData();
    widget.onSimulationStateChange?.call(!_isRaceFinished);
  }

  // ✅ تأكد أن الدالة تعيد الفاصل الزمني الصحيح
  Duration _getSimulationInterval() {
    // 3 ثواني لكل لفة (يمكن تعديلها حسب الحاجة)
    return const Duration(seconds: 3);
  }

  void _updatePosition() {
    if (_isRaceFinished) return;

    final performance = _calculatePerformance();
    final randomValue = _random.nextDouble();

    if (performance > 80 && _currentPosition > 1) {
      if (randomValue > 0.3) _currentPosition--;
    } else if (performance < 40 && _currentPosition < 20) {
      if (randomValue > 0.4) _currentPosition++;
    }
  }

  // Duration _getSimulationInterval() {
  //   // سرعة ثابتة (3 ثواني لكل لفة)
  //   return const Duration(seconds: 3);
  // }

  void _resetSimulation() {
    _raceTimer?.cancel();

    setState(() {
      _currentLap = 1;
      _currentPosition = widget.currentPosition;
      _tireWear = 100.0;
      _fuelLevel = widget.strategy.fuelLoad.toDouble();
      _displayedEvents = [];
      _isRaceFinished = false;
    });

    _startRaceSimulation();
  }

  void _updateFromExternalData() {
    if (_isRaceFinished) return;

    _tireWear = _calculateTireWearBasedOnLap();
    _fuelLevel = _calculateFuelBasedOnLap();
    _addAutomaticEvents();

    if (widget.raceEvents.length > _displayedEvents.length) {
      _displayedEvents = [...widget.raceEvents];
    }

    _suggestStrategyChanges();
  }

  void _addAutomaticEvents() {
    if (_isRaceFinished) return;

    if (_currentLap == 1 && !_displayedEvents.contains("🚥 بداية السباق!")) {
      _displayedEvents.add("🚥 بداية السباق!");
    }

    if (_currentLap == widget.strategy.pitStopLap &&
        !_displayedEvents.contains("🛞 Pit Stop مخطط")) {
      _displayedEvents.add("🛞 Pit Stop مخطط");
    }

    if (_tireWear < 30 && !_displayedEvents.contains("⚠️ الإطارات متآكلة")) {
      _displayedEvents.add("⚠️ الإطارات متآكلة");
    }

    if (_fuelLevel < 25 && !_displayedEvents.contains("⛽ وقود منخفض")) {
      _displayedEvents.add("⛽ وقود منخفض");
    }

    // إضافة أحداث عشوائية
    if (_currentLap > 1 && _currentLap < widget.totalLaps) {
      final randomValue = _random.nextDouble();
      if (randomValue > 0.95 && !_displayedEvents.contains("🚗 تجاوز ناجح!")) {
        _displayedEvents.add("🚗 تجاوز ناجح!");
      } else if (randomValue > 0.98 &&
          !_displayedEvents.contains("🔄 فقدان مركز")) {
        _displayedEvents.add("🔄 فقدان مركز");
      }
    }

    if (_currentLap >= widget.totalLaps &&
        !_displayedEvents.contains("🏁 نهاية السباق!")) {
      _displayedEvents.add("🏁 نهاية السباق!");
    }
  }

  double _calculateTireWearBasedOnLap() {
    double baseWear = 100.0;
    double wearPerLap = 0.0;

    switch (widget.strategy.tireChoice) {
      case TireType.soft:
        wearPerLap = 1.8;
        break;
      case TireType.medium:
        wearPerLap = 1.2;
        break;
      case TireType.hard:
        wearPerLap = 0.8;
        break;
      case TireType.wet:
        wearPerLap = 1.5;
        break;
    }

    switch (widget.currentWeather) {
      case WeatherType.dry:
        if (widget.strategy.tireChoice == TireType.wet) {
          wearPerLap *= 2.0;
        }
        break;
      case WeatherType.changeable:
        wearPerLap *= 1.3;
        break;
      case WeatherType.wet:
        if (widget.strategy.tireChoice != TireType.wet) {
          wearPerLap *= 1.8;
        } else {
          wearPerLap *= 0.9;
        }
        break;
    }

    return (baseWear - (_currentLap * wearPerLap)).clamp(0, 100);
  }

  double _calculateFuelBasedOnLap() {
    double baseFuel = widget.strategy.fuelLoad.toDouble();
    double consumptionPerLap = 0.0;

    switch (widget.strategy.aggression) {
      case AggressionLevel.conservative:
        consumptionPerLap = 1.6;
        break;
      case AggressionLevel.balanced:
        consumptionPerLap = 2.0;
        break;
      case AggressionLevel.aggressive:
        consumptionPerLap = 2.5;
        break;
    }

    switch (widget.currentWeather) {
      case WeatherType.dry:
        consumptionPerLap *= 1.0;
        break;
      case WeatherType.changeable:
        consumptionPerLap *= 1.2;
        break;
      case WeatherType.wet:
        consumptionPerLap *= 1.4;
        break;
    }

    return (baseFuel - (_currentLap * consumptionPerLap)).clamp(
      0,
      widget.strategy.fuelLoad.toDouble(),
    );
  }

  void _suggestStrategyChanges() {
    if (_isRaceFinished) return;

    if (_tireWear < 30 && _currentLap < widget.strategy.pitStopLap) {
      _showSuggestion("🛞 الإطارات منتهية - فكر في Pit Stop مبكر");
    }

    if (_fuelLevel < 25) {
      _showSuggestion("⛽ الوقود منخفض - استخدم وضع الحفاظ");
    }

    if (widget.currentWeather == WeatherType.wet &&
        widget.strategy.tireChoice != TireType.wet) {
      _showSuggestion("🌧️ الطقس ممطر - فكر في تغيير الإطارات");
    }
  }

  void _showSuggestion(String message) {
    if (!_displayedEvents.contains(message) && !_isRaceFinished) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.yellow[700]),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showRaceFinishedDialog() {
    _raceTimer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.flag, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text(
                'السباق انتهى!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🏁 أكملت ${widget.totalLaps} لفة',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'المركز النهائي: $_currentPosition',
                style: TextStyle(
                  color: _getPositionColor(_currentPosition),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildPerformanceSummary(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetSimulation();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFDC0000),
                foregroundColor: Colors.white,
              ),
              child: const Text('بدء سباق جديد'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إغلاق',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPerformanceSummary() {
    final performance = _calculatePerformance();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getPerformanceIcon(performance),
            color: _getPerformanceColor(performance),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الأداء النهائي',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '${performance.toInt()}%',
                  style: TextStyle(
                    color: _getPerformanceColor(performance),
                    fontSize: 16,
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

  void _changeStrategyMidRace(RaceStrategy newStrategy) {
    if (_isRaceFinished) return;

    setState(() {
      widget.onStrategyChange(newStrategy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1B2F), Color(0xFF0D0F1A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFDC0000).withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          _buildEnhancedRaceHeader(),
          const SizedBox(height: 20),
          _buildEnhancedCarStatus(),
          const SizedBox(height: 20),
          _buildEnhancedProgressHeader(),
          const SizedBox(height: 20),
          if (!_isRaceFinished) _buildEnhancedQuickActions(),
          if (_isRaceFinished) _buildRaceFinishedBanner(),
          const SizedBox(height: 20),
          _buildRaceInfoAndEvents(),
        ],
      ),
    );
  }

  Widget _buildRaceFinishedBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.lightGreen],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            'السباق انتهى - 🏁',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRaceHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اللفة $_currentLap/${widget.totalLaps}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isRaceFinished
                      ? 'السباق انتهى'
                      : '${widget.totalLaps - _currentLap} لفات متبقية',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            if (!_isRaceFinished) _buildSimulationControls(),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getPositionColor(_currentPosition),
                        _getPositionColor(_currentPosition).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getPositionColor(
                          _currentPosition,
                        ).withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'P$_currentPosition',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getWeatherColor(
                      widget.currentWeather,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getWeatherColor(widget.currentWeather),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getWeatherIcon(widget.currentWeather), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _getWeatherName(widget.currentWeather),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimulationControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _resetSimulation,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.5),
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_circle, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(
                  'جاري',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
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

  Widget _buildEnhancedProgressHeader() {
    return Column(
      children: [
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width:
                    (MediaQuery.of(context).size.width - 80) *
                    (_currentLap / widget.totalLaps),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC0000), Color(0xFFFF4D4D)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDC0000).withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildEnhancedLapMarker('البداية', 0, Colors.green),
            _buildEnhancedLapMarker(
              'Pit Stop',
              widget.strategy.pitStopLap,
              Colors.orange,
            ),
            _buildEnhancedLapMarker('النهاية', widget.totalLaps, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedLapMarker(String label, int lap, Color color) {
    final isActive = _currentLap >= lap;
    final isNext = _currentLap < lap && (lap - _currentLap) <= 5;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? color
                : (isNext ? color.withOpacity(0.6) : color.withOpacity(0.3)),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? color
                : (isNext ? color.withOpacity(0.8) : color.withOpacity(0.5)),
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (lap > 0) ...[
          const SizedBox(height: 2),
          Text(
            'لفة $lap',
            style: TextStyle(
              color: isActive
                  ? color
                  : (isNext ? color.withOpacity(0.8) : color.withOpacity(0.5)),
              fontSize: 8,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEnhancedCarStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.directions_car, color: Color(0xFFDC0000), size: 20),
              SizedBox(width: 8),
              Text(
                'حالة السيارة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatusItem(
                  'الإطارات',
                  '${_tireWear.toInt()}%',
                  _getTireWearColor(_tireWear),
                  Icons.circle,
                  _tireWear / 100,
                  '${_getTireCondition(_tireWear)}',
                ),
              ),
              Expanded(
                child: _buildEnhancedStatusItem(
                  'الوقود',
                  '${_fuelLevel.toInt()}%',
                  _getFuelLevelColor(_fuelLevel),
                  Icons.local_gas_station,
                  _fuelLevel / widget.strategy.fuelLoad,
                  '${(_fuelLevel / widget.strategy.fuelLoad * 100).toInt()}%',
                ),
              ),
              Expanded(child: _buildEnhancedPerformanceIndicator()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatusItem(
    String label,
    String value,
    Color color,
    IconData icon,
    double progress,
    String subtitle,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.1),
                color: color,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildEnhancedPerformanceIndicator() {
    final performance = _calculatePerformance();
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getPerformanceColor(performance),
                _getPerformanceColor(performance).withOpacity(0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _getPerformanceColor(performance).withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.speed, color: Colors.white, size: 28),
              Text(
                '${performance.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'الأداء',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          _getPerformanceText(performance),
          style: TextStyle(
            color: _getPerformanceColor(performance),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flash_on, size: 18, color: Color(0xFFDC0000)),
              SizedBox(width: 8),
              Text(
                'تغييرات سريعة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildEnhancedActionButton(
                'وضع الدفاع',
                Icons.shield,
                Colors.blue,
                'تقليل المخاطرة',
                () => _changeStrategyMidRace(
                  widget.strategy.copyWith(
                    aggression: AggressionLevel.conservative,
                  ),
                ),
              ),
              _buildEnhancedActionButton(
                'وضع الهجوم',
                Icons.bolt,
                Colors.red,
                'زيادة العدوانية',
                () => _changeStrategyMidRace(
                  widget.strategy.copyWith(
                    aggression: AggressionLevel.aggressive,
                  ),
                ),
              ),
              _buildEnhancedActionButton(
                'حفظ الوقود',
                Icons.eco,
                Colors.green,
                'تقليل الاستهلاك',
                () => _changeStrategyMidRace(
                  widget.strategy.copyWith(
                    aggression: AggressionLevel.conservative,
                    fuelLoad: (_fuelLevel + 10).clamp(80, 120).round(),
                  ),
                ),
              ),
              _buildEnhancedActionButton(
                'Pit Stop',
                Icons.build_circle,
                Colors.orange,
                'تغيير الإطارات',
                _showEnhancedPitStopDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButton(
    String label,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 120,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildRaceInfoAndEvents() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildEnhancedRaceInfo()),
        const SizedBox(width: 16),
        Expanded(flex: 3, child: _buildEnhancedRecentEvents()),
      ],
    );
  }

  Widget _buildEnhancedRaceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueGrey[800]!.withOpacity(0.8),
            Colors.blueGrey[900]!.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, size: 18, color: Colors.white70),
              SizedBox(width: 8),
              Text(
                'معلومات السباق',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEnhancedRaceInfoItem(
            'الإستراتيجية',
            _getCurrentStrategySummary(),
            Icons.track_changes,
          ),
          _buildEnhancedRaceInfoItem(
            'Pit Stop القادم',
            'لفة ${widget.strategy.pitStopLap}',
            Icons.schedule,
          ),
          _buildEnhancedRaceInfoItem(
            'الوقود المتبقي',
            '${_fuelLevel.toInt()}%',
            Icons.local_gas_station,
          ),
          _buildEnhancedRaceInfoItem(
            'حالة الإطارات',
            _getTireCondition(_tireWear),
            Icons.circle,
          ),
          _buildEnhancedRaceInfoItem(
            'مستوى الأداء',
            '${_calculatePerformance().toInt()}%',
            Icons.speed,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRaceInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRecentEvents() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, size: 18, color: Colors.white70),
              SizedBox(width: 8),
              Text(
                'الأحداث الحديثة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_displayedEvents.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: const Column(
                children: [
                  Icon(Icons.event_available, size: 40, color: Colors.white30),
                  SizedBox(height: 8),
                  Text(
                    'لا توجد أحداث حديثة',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ..._displayedEvents.reversed
                .take(4)
                .map((event) => _buildEnhancedEventItem(event)),
        ],
      ),
    );
  }

  Widget _buildEnhancedEventItem(String event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: _getEventColor(event),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              event,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 2,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0);
  }

  void _showEnhancedPitStopDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.build_circle, color: Colors.orange, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Pit Stop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'اختر نوع الإطارات الجديدة:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TireType.values.map((tire) {
                  return _buildTireChoiceButton(tire);
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTireChoiceButton(TireType tire) {
    return Container(
      width: 100,
      child: ElevatedButton(
        onPressed: () {
          _changeStrategyMidRace(
            widget.strategy.copyWith(tireChoice: tire, pitStopLap: _currentLap),
          );
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[300]),
                  const SizedBox(width: 8),
                  Text('تم تغيير الإطارات إلى ${_getTireName(tire)}'),
                ],
              ),
              backgroundColor: Colors.green[800],
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _getTireColor(tire).withOpacity(0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getTireEmoji(tire), style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              _getTireName(tire),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // دوال المساعدة
  Color _getEventColor(String event) {
    if (event.contains('🛞')) return Colors.orange;
    if (event.contains('⛽')) return Colors.red;
    if (event.contains('🌧️')) return Colors.blue;
    return Colors.green;
  }

  String _getPerformanceText(double performance) {
    if (performance > 85) return 'ممتاز';
    if (performance > 65) return 'جيد';
    return 'ضعيف';
  }

  IconData _getPerformanceIcon(double performance) {
    if (performance > 85) return Icons.emoji_events;
    if (performance > 65) return Icons.thumb_up;
    return Icons.warning;
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

  IconData _getWeatherIcon(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry:
        return Icons.wb_sunny;
      case WeatherType.changeable:
        return Icons.cloud;
      case WeatherType.wet:
        return Icons.cloudy_snowing;
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

  Color _getPositionColor(int position) {
    if (position == 1) return const Color(0xFFFFD700);
    if (position <= 3) return const Color(0xFFC0C0C0);
    if (position <= 10) return Colors.green;
    return Colors.grey;
  }

  Color _getTireWearColor(double wear) {
    if (wear > 70) return Colors.green;
    if (wear > 40) return Colors.orange;
    return Colors.red;
  }

  Color _getFuelLevelColor(double level) {
    if (level > 60) return Colors.green;
    if (level > 30) return Colors.orange;
    return Colors.red;
  }

  Color _getPerformanceColor(double performance) {
    if (performance > 85) return Colors.green;
    if (performance > 65) return Colors.orange;
    return Colors.red;
  }

  Color _getTireColor(TireType tire) {
    switch (tire) {
      case TireType.soft:
        return Colors.red;
      case TireType.medium:
        return Colors.yellow;
      case TireType.hard:
        return Colors.white;
      case TireType.wet:
        return Colors.blue;
    }
  }

  String _getTireEmoji(TireType tire) {
    switch (tire) {
      case TireType.soft:
        return '🔴';
      case TireType.medium:
        return '🟡';
      case TireType.hard:
        return '⚪';
      case TireType.wet:
        return '🔵';
    }
  }

  double _calculatePerformance() {
    double base = 100.0;

    if (_tireWear < 30)
      base *= 0.6;
    else if (_tireWear < 50)
      base *= 0.8;
    else if (_tireWear < 70)
      base *= 0.9;

    if (_fuelLevel < 20)
      base *= 0.7;
    else if (_fuelLevel < 40)
      base *= 0.85;

    switch (widget.strategy.aggression) {
      case AggressionLevel.aggressive:
        base *= 1.15;
        break;
      case AggressionLevel.conservative:
        base *= 0.9;
        break;
      case AggressionLevel.balanced:
        base *= 1.0;
        break;
    }

    switch (widget.currentWeather) {
      case WeatherType.dry:
        if (widget.strategy.tireChoice == TireType.wet) base *= 0.7;
        break;
      case WeatherType.changeable:
        base *= 0.9;
        break;
      case WeatherType.wet:
        if (widget.strategy.tireChoice != TireType.wet) base *= 0.6;
        break;
    }

    return base.clamp(0, 100);
  }

  String _getCurrentStrategySummary() {
    return '${_getAggressionName(widget.strategy.aggression)} - ${_getTireName(widget.strategy.tireChoice)}';
  }

  String _getTireCondition(double wear) {
    if (wear > 70) return 'جيدة';
    if (wear > 40) return 'متوسطة';
    return 'ضعيفة';
  }

  String _getTireName(TireType tire) {
    return AppConstants.getTireName(tire);
  }

  String _getAggressionName(AggressionLevel aggression) {
    return AppConstants.getAggressionName(aggression);
  }

  @override
  void dispose() {
    _raceTimer?.cancel();
    super.dispose();
  }
}
