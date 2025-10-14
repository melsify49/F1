import 'package:flutter/material.dart';
import '../models/race_strategy.dart';
import '../utils/constants.dart';

class StrategyPanel extends StatefulWidget {
  final Function(RaceStrategy) onStrategyChanged;
  final RaceStrategy? initialStrategy;
  final WeatherType currentWeather;
  final int currentRace;

  const StrategyPanel({
    super.key,
    required this.onStrategyChanged,
    this.initialStrategy,
    this.currentWeather = WeatherType.dry,
    this.currentRace = 1,
  });

  @override
  State<StrategyPanel> createState() => _StrategyPanelState();
}

class _StrategyPanelState extends State<StrategyPanel> with SingleTickerProviderStateMixin {
  late RaceStrategy _currentStrategy;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _containerColorAnimation;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _currentStrategy = widget.initialStrategy ?? RaceStrategy();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _containerColorAnimation = ColorTween(
      begin: const Color(0xFF1D1E33).withOpacity(0.8),
      end: const Color(0xFF1D1E33),
    ).animate(_animationController);
    
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStrategyChanged(_currentStrategy);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _containerColorAnimation.value!,
                  const Color(0xFF0A0E21),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFFDC0000).withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEnhancedHeader(),
                const SizedBox(height: 24),
                _buildTabContent(),
                const SizedBox(height: 20),
                _buildEnhancedStrategyPreview(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC0000), Color(0xFF850000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC0000).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.track_changes, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إستراتيجية السباق',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'خطط لسباق مثالي',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildWeatherBadge(),
          ],
        ),
        const SizedBox(height: 20),
        
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              _buildEnhancedTab('الأساسيات', Icons.tune, 0),
              _buildEnhancedTab('المتقدمة', Icons.rocket_launch, 1),
              _buildEnhancedTab('الطقس', Icons.cloud, 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getWeatherColor(widget.currentWeather),
            _getWeatherColor(widget.currentWeather).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getWeatherColor(widget.currentWeather).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(_getWeatherIcon(widget.currentWeather), size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            _getWeatherName(widget.currentWeather),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTab(String title, IconData icon, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(
            colors: [Color(0xFFDC0000), Color(0xFF850000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFFDC0000).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ] : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedTab = index;
                _animationController.forward(from: 0.0);
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: _getCurrentTabContent(),
    );
  }

  Widget _getCurrentTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildEnhancedBasicTab();
      case 1:
        return _buildEnhancedAdvancedTab();
      case 2:
        return _buildEnhancedWeatherTab();
      default:
        return _buildEnhancedBasicTab();
    }
  }

  Widget _buildEnhancedBasicTab() {
    return Column(
      children: [
        _buildEnhancedTireSelection(),
        const SizedBox(height: 24),
        _buildEnhancedAggressionSelection(),
        const SizedBox(height: 24),
        _buildEnhancedPitStopSlider(),
      ],
    );
  }

  // ========== علامة التبويب الأساسية ==========
  Widget _buildEnhancedTireSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildContentDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('اختيار الإطارات', Icons.circle),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: TireType.values.length,
            itemBuilder: (context, index) {
              final tire = TireType.values[index];
              final isSelected = _currentStrategy.tireChoice == tire;
              return _buildEnhancedTireCard(tire, isSelected);
            },
          ),
          const SizedBox(height: 16),
          _buildEnhancedTireStats(),
        ],
      ),
    );
  }

  Widget _buildEnhancedTireCard(TireType tire, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: isSelected ? LinearGradient(
          colors: [
            _getTireColor(tire),
            _getTireColor(tire).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: _getTireColor(tire).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentStrategy.tireChoice = tire;
              widget.onStrategyChanged(_currentStrategy);
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getTireEmoji(tire),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  _getTireShortName(tire),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTireLaps(tire),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTireStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEnhancedStatItem('المتانة', _getTireDurability(_currentStrategy.tireChoice), Icons.auto_awesome, 0.8),
          _buildEnhancedStatItem('القبض', _getTireGrip(_currentStrategy.tireChoice), Icons.offline_bolt, 0.9),
          _buildEnhancedStatItem('الطقس', _getTireWeather(_currentStrategy.tireChoice), Icons.cloud, 0.7),
        ],
      ),
    );
  }

  Widget _buildEnhancedAggressionSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildContentDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('مستوى العدوانية', Icons.bolt),
          const SizedBox(height: 16),
          Row(
            children: AggressionLevel.values.map((aggression) {
              final isSelected = _currentStrategy.aggression == aggression;
              return Expanded(
                child: _buildEnhancedAggressionCard(aggression, isSelected),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _buildAggressionIndicators(),
        ],
      ),
    );
  }

  Widget _buildEnhancedAggressionCard(AggressionLevel aggression, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        gradient: isSelected ? LinearGradient(
          colors: [
            _getAggressionColor(aggression),
            _getAggressionColor(aggression).withOpacity(0.7),
          ],
        ) : LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: _getAggressionColor(aggression).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentStrategy.aggression = aggression;
              widget.onStrategyChanged(_currentStrategy);
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  _getAggressionEmoji(aggression),
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  _getAggressionName(aggression),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getAggressionDesc(aggression),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedPitStopSlider() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildContentDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('توقيت Pit Stop', Icons.schedule),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'اللفة المستهدفة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getPitStopColor(_currentStrategy.pitStopLap).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getPitStopColor(_currentStrategy.pitStopLap)),
                      ),
                      child: Text(
                        'لفة ${_currentStrategy.pitStopLap}',
                        style: TextStyle(
                          color: _getPitStopColor(_currentStrategy.pitStopLap),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _currentStrategy.pitStopLap.toDouble(),
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: 'لفة ${_currentStrategy.pitStopLap}',
                  activeColor: _getPitStopColor(_currentStrategy.pitStopLap),
                  inactiveColor: Colors.grey[700],
                  onChanged: (value) {
                    setState(() {
                      _currentStrategy.pitStopLap = value.round();
                      widget.onStrategyChanged(_currentStrategy);
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLapIndicator('مبكر', 10, Colors.red),
                    _buildLapIndicator('مثالي', 25, Colors.green),
                    _buildLapIndicator('متأخر', 40, Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPitStopAnalysis(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== علامة التبويب المتقدمة ==========
  Widget _buildEnhancedAdvancedTab() {
    return Column(
      children: [
        _buildEnhancedFuelLoad(),
        const SizedBox(height: 20),
        _buildEnhancedStartStrategy(),
        const SizedBox(height: 20),
        _buildEnhancedRiskManagement(),
      ],
    );
  }

  Widget _buildEnhancedFuelLoad() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildContentDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('تحميل الوقود', Icons.local_gas_station),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'كمية الوقود',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getFuelLoadColor(_currentStrategy.fuelLoad).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getFuelLoadColor(_currentStrategy.fuelLoad)),
                      ),
                      child: Text(
                        '${_currentStrategy.fuelLoad}%',
                        style: TextStyle(
                          color: _getFuelLoadColor(_currentStrategy.fuelLoad),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _currentStrategy.fuelLoad.toDouble(),
                  min: 80,
                  max: 120,
                  divisions: 40,
                  label: '${_currentStrategy.fuelLoad}%',
                  activeColor: _getFuelLoadColor(_currentStrategy.fuelLoad),
                  inactiveColor: Colors.grey[700],
                  onChanged: (value) {
                    setState(() {
                      _currentStrategy.fuelLoad = value.round();
                      widget.onStrategyChanged(_currentStrategy);
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFuelIndicator('خفيف', 90, Colors.red),
                    _buildFuelIndicator('مثالي', 100, Colors.green),
                    _buildFuelIndicator('ثقيل', 110, Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFuelImpactInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStartStrategy() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildContentDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('إستراتيجية البداية', Icons.flag),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStartStrategyOption('هجومي', Icons.rocket_launch, true),
              _buildStartStrategyOption('متوازن', Icons.balance, false),
              _buildStartStrategyOption('دفاعي', Icons.shield, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRiskManagement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildContentDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('إدارة المخاطرة', Icons.warning),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildRiskOption('منخفض', 0.2, Colors.green),
              _buildRiskOption('متوسط', 0.5, Colors.orange),
              _buildRiskOption('مرتفع', 0.8, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  // ========== علامة التبويب الطقس ==========
  Widget _buildEnhancedWeatherTab() {
    return Column(
      children: [
        _buildEnhancedWeatherAdjustment(),
        const SizedBox(height: 20),
        _buildEnhancedWeatherStrategy(),
        const SizedBox(height: 20),
        _buildEnhancedEmergencyPlans(),
      ],
    );
  }

  Widget _buildEnhancedWeatherAdjustment() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildContentDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('التكيف مع الطقس', Icons.wb_sunny),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التكيف التلقائي مع الطقس',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'تعديل الإستراتيجية تلقائياً حسب تغيرات الطقس',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _currentStrategy.weatherAdjustment,
                onChanged: (value) {
                  setState(() {
                    _currentStrategy.weatherAdjustment = value;
                    widget.onStrategyChanged(_currentStrategy);
                  });
                },
                activeColor: const Color(0xFFDC0000),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeatherForecast(),
        ],
      ),
    );
  }

  Widget _buildEnhancedWeatherStrategy() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildContentDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('إستراتيجية الطقس', Icons.cloud_queue),
          const SizedBox(height: 16),
          _buildWeatherPlan(),
        ],
      ),
    );
  }

  Widget _buildEnhancedEmergencyPlans() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildContentDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('خطط الطوارئ', Icons.emergency),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildEmergencyChip('مطر مفاجئ', Icons.cloudy_snowing),
              _buildEmergencyChip('سيارة أمان', Icons.security),
              _buildEmergencyChip('حادث', Icons.warning),
              _buildEmergencyChip('مشكلة تقنية', Icons.build),
            ],
          ),
        ],
      ),
    );
  }

  // ========== Widgets مساعدة إضافية ==========
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFDC0000).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDC0000).withOpacity(0.3)),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFDC0000)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedStatItem(String label, String value, IconData icon, double level) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: level,
                strokeWidth: 4,
                backgroundColor: Colors.white.withOpacity(0.1),
                color: _getLevelColor(level),
              ),
            ),
            Icon(icon, size: 20, color: Colors.white70),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAggressionIndicators() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _buildEnhancedIndicatorItem('التجاوزات', _getOvertakeChance(), Icons.rocket_launch),
          _buildEnhancedIndicatorItem('المخاطرة', _getRiskLevel(), Icons.warning),
          _buildEnhancedIndicatorItem('الوقود', _getFuelImpact(), Icons.local_gas_station),
        ],
      ),
    );
  }

  Widget _buildEnhancedIndicatorItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLapIndicator(String label, int lap, Color color) {
    final isActive = (lap - _currentStrategy.pitStopLap).abs() <= 5;
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? color : color.withOpacity(0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildFuelIndicator(String label, int fuel, Color color) {
    final isActive = (fuel - _currentStrategy.fuelLoad).abs() <= 5;
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? color : color.withOpacity(0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPitStopAnalysis() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getPitStopColor(_currentStrategy.pitStopLap).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getPitStopColor(_currentStrategy.pitStopLap)),
      ),
      child: Row(
        children: [
          Icon(
            _getPitStopIcon(_currentStrategy.pitStopLap),
            color: _getPitStopColor(_currentStrategy.pitStopLap),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getPitStopAnalysis(_currentStrategy.pitStopLap),
              style: TextStyle(
                color: _getPitStopColor(_currentStrategy.pitStopLap),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelImpactInfo() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getFuelLoadColor(_currentStrategy.fuelLoad).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getFuelLoadColor(_currentStrategy.fuelLoad)),
      ),
      child: Row(
        children: [
          Icon(
            _getFuelLoadIcon(_currentStrategy.fuelLoad),
            color: _getFuelLoadColor(_currentStrategy.fuelLoad),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getFuelLoadAnalysis(_currentStrategy.fuelLoad),
              style: TextStyle(
                color: _getFuelLoadColor(_currentStrategy.fuelLoad),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartStrategyOption(String label, IconData icon, bool isSelected) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          // يمكنك إضافة منطق تغيير الإستراتيجية هنا
        });
      },
      backgroundColor: Colors.white10,
      selectedColor: const Color(0xFFDC0000),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
    );
  }

  Widget _buildRiskOption(String label, double value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherForecast() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getWeatherColor(widget.currentWeather).withOpacity(0.2),
            _getWeatherColor(widget.currentWeather).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(_getWeatherIcon(widget.currentWeather), size: 32, color: _getWeatherColor(widget.currentWeather)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'توقعات الطقس الحالي',
                  style: TextStyle(
                    color: _getWeatherColor(widget.currentWeather),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getWeatherDescription(widget.currentWeather),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherPlan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildPlanItem('الإطارات المناسبة', _getRecommendedTire(), Icons.circle),
          _buildPlanItem('مستوى العدوانية', _getRecommendedAggression(), Icons.bolt),
          _buildPlanItem('توقيت Pit Stop', _getRecommendedPitStop(), Icons.schedule),
        ],
      ),
    );
  }

  Widget _buildPlanItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14))),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmergencyChip(String label, IconData icon) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
      backgroundColor: Colors.orange.withOpacity(0.2),
      labelStyle: const TextStyle(color: Colors.orange),
    );
  }

  // ========== معاينة الإستراتيجية ==========
  Widget _buildEnhancedStrategyPreview() {
    final score = _currentStrategy.calculateStrategyScore(widget.currentWeather);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getScoreColor(score).withOpacity(0.15),
            _getScoreColor(score).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getScoreColor(score).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(score).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'ملخص الإستراتيجية',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getScoreColor(score),
                      _getScoreColor(score).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getScoreColor(score).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      score.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3.2,
            children: [
              _buildEnhancedPreviewItem('الإطارات', _getTireName(_currentStrategy.tireChoice), _getTireEmoji(_currentStrategy.tireChoice), _getTireColor(_currentStrategy.tireChoice)),
              _buildEnhancedPreviewItem('العدوانية', _getAggressionName(_currentStrategy.aggression), _getAggressionEmoji(_currentStrategy.aggression), _getAggressionColor(_currentStrategy.aggression)),
              _buildEnhancedPreviewItem('Pit Stop', 'لفة ${_currentStrategy.pitStopLap}', '⏱️', _getPitStopColor(_currentStrategy.pitStopLap)),
              _buildEnhancedPreviewItem('الوقود', '${_currentStrategy.fuelLoad}%', '⛽', _getFuelLoadColor(_currentStrategy.fuelLoad)),
            ],
          ),
          const SizedBox(height: 16),
          _buildEnhancedStrategyAnalysis(score),
        ],
      ),
    );
  }

  Widget _buildEnhancedPreviewItem(String label, String value, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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

  Widget _buildEnhancedStrategyAnalysis(double score) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getScoreColor(score).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: _getScoreColor(score)),
            ),
            child: Icon(
              _getStrategyIcon(score),
              color: _getScoreColor(score),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStrategyTitle(score),
                  style: TextStyle(
                    color: _getScoreColor(score),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getStrategyFeedback(score),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildContentDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.03),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // ========== دوال المساعدة ==========
  Color _getLevelColor(double level) {
    if (level >= 0.8) return Colors.green;
    if (level >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getStrategyTitle(double score) {
    if (score >= 80) return 'إستراتيجية ممتازة!';
    if (score >= 60) return 'إستراتيجية جيدة';
    return 'تحتاج لتحسين';
  }

  IconData _getPitStopIcon(int lap) {
    if (lap >= 20 && lap <= 30) return Icons.check_circle;
    if (lap >= 15 && lap <= 35) return Icons.info;
    return Icons.warning;
  }

  String _getPitStopAnalysis(int lap) {
    if (lap >= 20 && lap <= 30) return 'توقيت مثالي - أفضل فرصة للفوز';
    if (lap >= 15 && lap <= 35) return 'توقيت جيد - قد تخسر بعض المراكز';
    if (lap < 15) return 'مبكر جداً - خطر فقدان المراكز';
    return 'متأخر جداً - خطر تآكل الإطارات';
  }

  IconData _getFuelLoadIcon(int load) {
    if (load >= 95 && load <= 105) return Icons.check_circle;
    if (load >= 90 && load <= 110) return Icons.info;
    return Icons.warning;
  }

  String _getFuelLoadAnalysis(int load) {
    if (load >= 95 && load <= 105) return 'كمية مثالية - توازن بين السرعة والمسافة';
    if (load >= 90 && load <= 110) return 'كمية جيدة - قد تحتاج لتعديل طفيف';
    if (load < 90) return 'قليلة جداً - خطر نفاد الوقود';
    return 'كثيرة جداً - تأثير سلبي على السرعة';
  }

  String _getWeatherDescription(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry: return 'ظروف مثالية للإطارات الناعمة والمتوسطة';
      case WeatherType.changeable: return 'احتمال هطول أمطار - كن مستعداً للتغيير';
      case WeatherType.wet: return 'إطارات المطر مطلوبة للأمان والأداء';
    }
  }

  String _getRecommendedTire() {
    switch (widget.currentWeather) {
      case WeatherType.dry: return 'ناعم/متوسط';
      case WeatherType.changeable: return 'متوسط';
      case WeatherType.wet: return 'مطري';
    }
  }

  String _getRecommendedAggression() {
    switch (widget.currentWeather) {
      case WeatherType.dry: return 'عدواني';
      case WeatherType.changeable: return 'متوازن';
      case WeatherType.wet: return 'محافظ';
    }
  }

  String _getRecommendedPitStop() {
    switch (widget.currentWeather) {
      case WeatherType.dry: return '20-30';
      case WeatherType.changeable: return '15-35';
      case WeatherType.wet: return 'مرن';
    }
  }

  // دوال المساعدة الأساسية
  Color _getTireColor(TireType tire) {
    switch (tire) {
      case TireType.soft: return Colors.red;
      case TireType.medium: return Colors.yellow;
      case TireType.hard: return Colors.white;
      case TireType.wet: return Colors.blue;
    }
  }

  String _getTireShortName(TireType tire) {
    switch (tire) {
      case TireType.soft: return 'ناعم';
      case TireType.medium: return 'متوسط';
      case TireType.hard: return 'صلب';
      case TireType.wet: return 'مطري';
    }
  }

  String _getTireLaps(TireType tire) {
    switch (tire) {
      case TireType.soft: return '20-30 لفة';
      case TireType.medium: return '30-40 لفة';
      case TireType.hard: return '40-50 لفة';
      case TireType.wet: return 'حسب المطر';
    }
  }

  String _getTireDurability(TireType tire) {
    switch (tire) {
      case TireType.soft: return 'منخفضة';
      case TireType.medium: return 'متوسطة';
      case TireType.hard: return 'عالية';
      case TireType.wet: return 'محدودة';
    }
  }

  String _getTireGrip(TireType tire) {
    switch (tire) {
      case TireType.soft: return 'ممتاز';
      case TireType.medium: return 'جيد';
      case TireType.hard: return 'متوسط';
      case TireType.wet: return 'في المطر';
    }
  }

  String _getTireWeather(TireType tire) {
    switch (tire) {
      case TireType.soft: return 'جاف';
      case TireType.medium: return 'جاف';
      case TireType.hard: return 'جاف';
      case TireType.wet: return 'رطب';
    }
  }

  Color _getAggressionColor(AggressionLevel aggression) {
    switch (aggression) {
      case AggressionLevel.conservative: return Colors.green;
      case AggressionLevel.balanced: return Colors.orange;
      case AggressionLevel.aggressive: return Colors.red;
    }
  }

  String _getAggressionDesc(AggressionLevel aggression) {
    switch (aggression) {
      case AggressionLevel.conservative: return 'حافظ على\nالمركز';
      case AggressionLevel.balanced: return 'تقدم عندما\nتتاح الفرصة';
      case AggressionLevel.aggressive: return 'هاجم من\nالبداية';
    }
  }

  String _getOvertakeChance() {
    switch (_currentStrategy.aggression) {
      case AggressionLevel.conservative: return 'منخفض';
      case AggressionLevel.balanced: return 'متوسط';
      case AggressionLevel.aggressive: return 'مرتفع';
    }
  }

  String _getRiskLevel() {
    switch (_currentStrategy.aggression) {
      case AggressionLevel.conservative: return 'منخفض';
      case AggressionLevel.balanced: return 'متوسط';
      case AggressionLevel.aggressive: return 'مرتفع';
    }
  }

  String _getFuelImpact() {
    switch (_currentStrategy.aggression) {
      case AggressionLevel.conservative: return '-10%';
      case AggressionLevel.balanced: return '0%';
      case AggressionLevel.aggressive: return '+20%';
    }
  }

  Color _getPitStopColor(int lap) {
    if (lap >= 20 && lap <= 30) return Colors.green;
    if (lap >= 15 && lap <= 35) return Colors.orange;
    return Colors.red;
  }

  Color _getFuelLoadColor(int load) {
    if (load >= 95 && load <= 105) return Colors.green;
    if (load >= 90 && load <= 110) return Colors.orange;
    return Colors.red;
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getWeatherColor(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry: return Colors.orange;
      case WeatherType.changeable: return Colors.blueGrey;
      case WeatherType.wet: return Colors.blue;
    }
  }

  IconData _getWeatherIcon(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry: return Icons.wb_sunny;
      case WeatherType.changeable: return Icons.cloud;
      case WeatherType.wet: return Icons.cloudy_snowing;
    }
  }

  String _getWeatherName(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry: return 'جاف';
      case WeatherType.changeable: return 'غائم';
      case WeatherType.wet: return 'ممطر';
    }
  }

  String _getTireName(TireType tire) {
    return AppConstants.getTireName(tire);
  }

  String _getTireEmoji(TireType tire) {
    switch (tire) {
      case TireType.soft: return '🔴';
      case TireType.medium: return '🟡';
      case TireType.hard: return '⚪';
      case TireType.wet: return '🔵';
    }
  }

  String _getAggressionName(AggressionLevel aggression) {
    switch (aggression) {
      case AggressionLevel.conservative: return "محافظ";
      case AggressionLevel.balanced: return "متوازن";
      case AggressionLevel.aggressive: return "عدواني";
    }
  }

  String _getAggressionEmoji(AggressionLevel aggression) {
    switch (aggression) {
      case AggressionLevel.conservative: return '🐢';
      case AggressionLevel.balanced: return '⚖️';
      case AggressionLevel.aggressive: return '💥';
    }
  }

  IconData _getStrategyIcon(double score) {
    if (score >= 80) return Icons.emoji_events;
    if (score >= 60) return Icons.thumb_up;
    return Icons.warning;
  }

  String _getStrategyFeedback(double score) {
    if (score >= 80) return 'إستراتيجية ممتازة! لديك فرصة كبيرة للفوز';
    if (score >= 60) return 'إستراتيجية جيدة، قد تحتاج لبعض التحسينات';
    return 'إستراتيجية محفوفة بالمخاطر، فكر في التعديل';
  }
}