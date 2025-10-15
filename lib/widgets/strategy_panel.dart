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

class _StrategyPanelState extends State<StrategyPanel>
    with SingleTickerProviderStateMixin {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _containerColorAnimation.value!,
                  const Color(0xFF0A0E21),
                ],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
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
                _buildHeader(isSmallScreen),
                SizedBox(height: isSmallScreen ? 16 : 24),
                _buildTabContent(isSmallScreen),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildStrategyPreview(isSmallScreen),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: isSmallScreen ? 44 : 52,
              height: isSmallScreen ? 44 : 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC0000), Color(0xFF850000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC0000).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.track_changes,
                color: Colors.white,
                size: isSmallScreen ? 22 : 26,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إستراتيجية السباق',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    'خطط لسباق مثالي',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ],
              ),
            ),
            _buildWeatherBadge(isSmallScreen),
          ],
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        _buildTabs(isSmallScreen),
      ],
    );
  }

  Widget _buildWeatherBadge(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 8 : 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getWeatherColor(widget.currentWeather),
            _getWeatherColor(widget.currentWeather).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
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
          Icon(
            _getWeatherIcon(widget.currentWeather),
            size: isSmallScreen ? 18 : 20,
            color: Colors.white,
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Text(
            _getWeatherName(widget.currentWeather),
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 48 : 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _buildTab('الأساسيات', Icons.tune, 0, isSmallScreen),
          _buildTab('المتقدمة', Icons.rocket_launch, 1, isSmallScreen),
          _buildTab('الطقس', Icons.cloud, 2, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildTab(String title, IconData icon, int index, bool isSmallScreen) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFDC0000), Color(0xFF850000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFDC0000).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
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
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: isSmallScreen ? 18 : 20,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 14 : 16,
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

  Widget _buildTabContent(bool isSmallScreen) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: _getCurrentTabContent(isSmallScreen),
    );
  }

  Widget _getCurrentTabContent(bool isSmallScreen) {
    switch (_selectedTab) {
      case 0:
        return _buildBasicTab(isSmallScreen);
      case 1:
        return _buildAdvancedTab(isSmallScreen);
      case 2:
        return _buildWeatherTab(isSmallScreen);
      default:
        return _buildBasicTab(isSmallScreen);
    }
  }

  Widget _buildBasicTab(bool isSmallScreen) {
    return Column(
      children: [
        _buildTireSelection(isSmallScreen),
        SizedBox(height: isSmallScreen ? 16 : 20),
        _buildAggressionSelection(isSmallScreen),
        SizedBox(height: isSmallScreen ? 16 : 20),
        _buildPitStopSlider(isSmallScreen),
      ],
    );
  }

  Widget _buildTireSelection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('اختيار الإطارات', Icons.circle, isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isSmallScreen ? 2 : 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isSmallScreen ? 1.2 : 1.1,
            ),
            itemCount: TireType.values.length,
            itemBuilder: (context, index) {
              final tire = TireType.values[index];
              final isSelected = _currentStrategy.tireChoice == tire;
              return _buildTireCard(tire, isSelected, isSmallScreen);
            },
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildTireStats(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildTireCard(TireType tire, bool isSelected, bool isSmallScreen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  _getTireColor(tire),
                  _getTireColor(tire).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
              ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(
          color: isSelected
              ? Colors.white.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: _getTireColor(tire).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
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
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getTireEmoji(tire),
                  style: TextStyle(fontSize: isSmallScreen ? 24 : 28),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  _getTireShortName(tire),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  _getTireLaps(tire),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTireStats(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'المتانة',
            _getTireDurability(_currentStrategy.tireChoice),
            Icons.auto_awesome,
            0.8,
            isSmallScreen,
          ),
          _buildStatItem(
            'القبض',
            _getTireGrip(_currentStrategy.tireChoice),
            Icons.offline_bolt,
            0.9,
            isSmallScreen,
          ),
          _buildStatItem(
            'الطقس',
            _getTireWeather(_currentStrategy.tireChoice),
            Icons.cloud,
            0.7,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    double level,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: isSmallScreen ? 50 : 60,
              height: isSmallScreen ? 50 : 60,
              child: CircularProgressIndicator(
                value: level,
                strokeWidth: 4,
                backgroundColor: Colors.white.withOpacity(0.1),
                color: _getLevelColor(level),
              ),
            ),
            Icon(icon, size: isSmallScreen ? 20 : 24, color: Colors.white70),
          ],
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
        SizedBox(height: isSmallScreen ? 4 : 6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAggressionSelection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('مستوى العدوانية', Icons.bolt, isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Row(
            children: AggressionLevel.values.map((aggression) {
              final isSelected = _currentStrategy.aggression == aggression;
              return Expanded(
                child: _buildAggressionCard(
                  aggression,
                  isSelected,
                  isSmallScreen,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildAggressionIndicators(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildAggressionCard(
    AggressionLevel aggression,
    bool isSelected,
    bool isSmallScreen,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  _getAggressionColor(aggression),
                  _getAggressionColor(aggression).withOpacity(0.7),
                ],
              )
            : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
              ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(
          color: isSelected
              ? Colors.white.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: _getAggressionColor(aggression).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
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
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              children: [
                Text(
                  _getAggressionEmoji(aggression),
                  style: TextStyle(fontSize: isSmallScreen ? 28 : 32),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  _getAggressionName(aggression),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  _getAggressionDesc(aggression),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isSmallScreen ? 12 : 14,
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

  Widget _buildAggressionIndicators(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _buildIndicatorItem(
            'التجاوزات',
            _getOvertakeChance(),
            Icons.rocket_launch,
            isSmallScreen,
          ),
          _buildIndicatorItem(
            'المخاطرة',
            _getRiskLevel(),
            Icons.warning,
            isSmallScreen,
          ),
          _buildIndicatorItem(
            'الوقود',
            _getFuelImpact(),
            Icons.local_gas_station,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorItem(
    String label,
    String value,
    IconData icon,
    bool isSmallScreen,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? 44 : 52,
            height: isSmallScreen ? 44 : 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            ),
            child: Icon(
              icon,
              size: isSmallScreen ? 22 : 26,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPitStopSlider(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('توقيت Pit Stop', Icons.schedule, isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'اللفة المستهدفة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getPitStopColor(
                          _currentStrategy.pitStopLap,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 12 : 16,
                        ),
                        border: Border.all(
                          color: _getPitStopColor(_currentStrategy.pitStopLap),
                        ),
                      ),
                      child: Text(
                        'لفة ${_currentStrategy.pitStopLap}',
                        style: TextStyle(
                          color: _getPitStopColor(_currentStrategy.pitStopLap),
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
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
                SizedBox(height: isSmallScreen ? 12 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLapIndicator('مبكر', 10, Colors.red, isSmallScreen),
                    _buildLapIndicator(
                      'مثالي',
                      25,
                      Colors.green,
                      isSmallScreen,
                    ),
                    _buildLapIndicator(
                      'متأخر',
                      40,
                      Colors.orange,
                      isSmallScreen,
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildPitStopAnalysis(isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLapIndicator(
    String label,
    int lap,
    Color color,
    bool isSmallScreen,
  ) {
    final isActive = (lap - _currentStrategy.pitStopLap).abs() <= 5;
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: isSmallScreen ? 4 : 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? color : color.withOpacity(0.5),
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPitStopAnalysis(bool isSmallScreen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: _getPitStopColor(_currentStrategy.pitStopLap).withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(
          color: _getPitStopColor(_currentStrategy.pitStopLap),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getPitStopIcon(_currentStrategy.pitStopLap),
            color: _getPitStopColor(_currentStrategy.pitStopLap),
            size: isSmallScreen ? 18 : 22,
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Text(
              _getPitStopAnalysis(_currentStrategy.pitStopLap),
              style: TextStyle(
                color: _getPitStopColor(_currentStrategy.pitStopLap),
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 40 : 48,
          height: isSmallScreen ? 40 : 48,
          decoration: BoxDecoration(
            color: const Color(0xFFDC0000).withOpacity(0.2),
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            border: Border.all(color: const Color(0xFFDC0000).withOpacity(0.3)),
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 20 : 24,
            color: const Color(0xFFDC0000),
          ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 18 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStrategyPreview(bool isSmallScreen) {
    final score = _currentStrategy.calculateStrategyScore(
      widget.currentWeather,
    );

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getScoreColor(score).withOpacity(0.15),
            _getScoreColor(score).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
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
              Text(
                'ملخص الإستراتيجية',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 20,
                  vertical: isSmallScreen ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getScoreColor(score),
                      _getScoreColor(score).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
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
                    const Icon(
                      Icons.emoji_events,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Text(
                      score.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: isSmallScreen ? 12 : 16,
            mainAxisSpacing: isSmallScreen ? 12 : 16,
            childAspectRatio: isSmallScreen ? 3.0 : 2.8,
            children: [
              _buildPreviewItem(
                'الإطارات',
                _getTireName(_currentStrategy.tireChoice),
                _getTireEmoji(_currentStrategy.tireChoice),
                _getTireColor(_currentStrategy.tireChoice),
                isSmallScreen,
              ),
              _buildPreviewItem(
                'العدوانية',
                _getAggressionName(_currentStrategy.aggression),
                _getAggressionEmoji(_currentStrategy.aggression),
                _getAggressionColor(_currentStrategy.aggression),
                isSmallScreen,
              ),
              _buildPreviewItem(
                'Pit Stop',
                'لفة ${_currentStrategy.pitStopLap}',
                '⏱️',
                _getPitStopColor(_currentStrategy.pitStopLap),
                isSmallScreen,
              ),
              _buildPreviewItem(
                'الوقود',
                '${_currentStrategy.fuelLoad}%',
                '⛽',
                _getFuelLoadColor(_currentStrategy.fuelLoad),
                isSmallScreen,
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildStrategyAnalysis(score, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(
    String label,
    String value,
    String emoji,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 40 : 48,
            height: isSmallScreen ? 40 : 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 18,
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

  Widget _buildStrategyAnalysis(double score, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 44 : 52,
            height: isSmallScreen ? 44 : 52,
            decoration: BoxDecoration(
              color: _getScoreColor(score).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: _getScoreColor(score)),
            ),
            child: Icon(
              _getStrategyIcon(score),
              color: _getScoreColor(score),
              size: isSmallScreen ? 22 : 26,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStrategyTitle(score),
                  style: TextStyle(
                    color: _getScoreColor(score),
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  _getStrategyFeedback(score),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Advanced and Weather Tabs (simplified for brevity)
  Widget _buildAdvancedTab(bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildFuelLoad(isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildStartStrategy(isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildRiskManagement(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildWeatherTab(bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildWeatherAdjustment(isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildWeatherStrategy(isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildEmergencyPlans(isSmallScreen),
        ],
      ),
    );
  }

  // Simplified versions of advanced tab widgets
  Widget _buildFuelLoad(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'تحميل الوقود',
            Icons.local_gas_station,
            isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          // Add fuel load content here
        ],
      ),
    );
  }

  Widget _buildStartStrategy(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('إستراتيجية البداية', Icons.flag, isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),
          // Add start strategy content here
        ],
      ),
    );
  }

  Widget _buildRiskManagement(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('إدارة المخاطرة', Icons.warning, isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),
          // Add risk management content here
        ],
      ),
    );
  }

  Widget _buildWeatherAdjustment(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('التكيف مع الطقس', Icons.wb_sunny, isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),
          // Add weather adjustment content here
        ],
      ),
    );
  }

  Widget _buildWeatherStrategy(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'إستراتيجية الطقس',
            Icons.cloud_queue,
            isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          // Add weather strategy content here
        ],
      ),
    );
  }

  Widget _buildEmergencyPlans(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('خطط الطوارئ', Icons.emergency, isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),
          // Add emergency plans content here
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
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

  // Helper methods (keep the same as before)
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
    if (load >= 95 && load <= 105)
      return 'كمية مثالية - توازن بين السرعة والمسافة';
    if (load >= 90 && load <= 110) return 'كمية جيدة - قد تحتاج لتعديل طفيف';
    if (load < 90) return 'قليلة جداً - خطر نفاد الوقود';
    return 'كثيرة جداً - تأثير سلبي على السرعة';
  }

  String _getWeatherDescription(WeatherType weather) {
    switch (weather) {
      case WeatherType.dry:
        return 'ظروف مثالية للإطارات الناعمة والمتوسطة';
      case WeatherType.changeable:
        return 'احتمال هطول أمطار - كن مستعداً للتغيير';
      case WeatherType.wet:
        return 'إطارات المطر مطلوبة للأمان والأداء';
    }
  }

  String _getRecommendedTire() {
    switch (widget.currentWeather) {
      case WeatherType.dry:
        return 'ناعم/متوسط';
      case WeatherType.changeable:
        return 'متوسط';
      case WeatherType.wet:
        return 'مطري';
    }
  }

  String _getRecommendedAggression() {
    switch (widget.currentWeather) {
      case WeatherType.dry:
        return 'عدواني';
      case WeatherType.changeable:
        return 'متوازن';
      case WeatherType.wet:
        return 'محافظ';
    }
  }

  String _getRecommendedPitStop() {
    switch (widget.currentWeather) {
      case WeatherType.dry:
        return '20-30';
      case WeatherType.changeable:
        return '15-35';
      case WeatherType.wet:
        return 'مرن';
    }
  }

  // باقي دوال المساعدة الأساسية...
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

  String _getTireShortName(TireType tire) {
    switch (tire) {
      case TireType.soft:
        return 'ناعم';
      case TireType.medium:
        return 'متوسط';
      case TireType.hard:
        return 'صلب';
      case TireType.wet:
        return 'مطري';
    }
  }

  String _getTireLaps(TireType tire) {
    switch (tire) {
      case TireType.soft:
        return '20-30 لفة';
      case TireType.medium:
        return '30-40 لفة';
      case TireType.hard:
        return '40-50 لفة';
      case TireType.wet:
        return 'حسب المطر';
    }
  }

  String _getTireDurability(TireType tire) {
    switch (tire) {
      case TireType.soft:
        return 'منخفضة';
      case TireType.medium:
        return 'متوسطة';
      case TireType.hard:
        return 'عالية';
      case TireType.wet:
        return 'محدودة';
    }
  }

  String _getTireGrip(TireType tire) {
    switch (tire) {
      case TireType.soft:
        return 'ممتاز';
      case TireType.medium:
        return 'جيد';
      case TireType.hard:
        return 'متوسط';
      case TireType.wet:
        return 'في المطر';
    }
  }

  String _getTireWeather(TireType tire) {
    switch (tire) {
      case TireType.soft:
        return 'جاف';
      case TireType.medium:
        return 'جاف';
      case TireType.hard:
        return 'جاف';
      case TireType.wet:
        return 'رطب';
    }
  }

  Color _getAggressionColor(AggressionLevel aggression) {
    switch (aggression) {
      case AggressionLevel.conservative:
        return Colors.green;
      case AggressionLevel.balanced:
        return Colors.orange;
      case AggressionLevel.aggressive:
        return Colors.red;
    }
  }

  String _getAggressionDesc(AggressionLevel aggression) {
    switch (aggression) {
      case AggressionLevel.conservative:
        return 'حافظ على\nالمركز';
      case AggressionLevel.balanced:
        return 'تقدم عندما\nتتاح الفرصة';
      case AggressionLevel.aggressive:
        return 'هاجم من\nالبداية';
    }
  }

  String _getOvertakeChance() {
    switch (_currentStrategy.aggression) {
      case AggressionLevel.conservative:
        return 'منخفض';
      case AggressionLevel.balanced:
        return 'متوسط';
      case AggressionLevel.aggressive:
        return 'مرتفع';
    }
  }

  String _getRiskLevel() {
    switch (_currentStrategy.aggression) {
      case AggressionLevel.conservative:
        return 'منخفض';
      case AggressionLevel.balanced:
        return 'متوسط';
      case AggressionLevel.aggressive:
        return 'مرتفع';
    }
  }

  String _getFuelImpact() {
    switch (_currentStrategy.aggression) {
      case AggressionLevel.conservative:
        return '-10%';
      case AggressionLevel.balanced:
        return '0%';
      case AggressionLevel.aggressive:
        return '+20%';
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
        return 'غائم';
      case WeatherType.wet:
        return 'ممطر';
    }
  }

  String _getTireName(TireType tire) {
    return AppConstants.getTireName(tire);
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

  String _getAggressionName(AggressionLevel aggression) {
    switch (aggression) {
      case AggressionLevel.conservative:
        return "محافظ";
      case AggressionLevel.balanced:
        return "متوازن";
      case AggressionLevel.aggressive:
        return "عدواني";
    }
  }

  String _getAggressionEmoji(AggressionLevel aggression) {
    switch (aggression) {
      case AggressionLevel.conservative:
        return '🐢';
      case AggressionLevel.balanced:
        return '⚖️';
      case AggressionLevel.aggressive:
        return '💥';
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

  // ... باقي دوال المساعدة الأساسية (نفس الدوال السابقة)
  // [يجب إضافة جميع دوال المساعدة الأساسية من الكود السابق هنا]
}
