import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/race_result.dart';
import '../utils/helpers.dart';

class ResultsScreen extends StatelessWidget {
  final RaceResult result;
  final VoidCallback onContinue;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 24,
            vertical: 16,
          ),
          child: Column(
            children: [
              // العنوان
              _buildHeader(isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),

              // النتيجة الرئيسية
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildMainResult(isSmallScreen),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      _buildDriversPerformance(isSmallScreen),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      _buildRaceStandings(isSmallScreen),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      _buildPrizes(isSmallScreen),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      _buildStatistics(isSmallScreen),
                      if (result.raceEvents.isNotEmpty) ...[
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        _buildRaceEvents(isSmallScreen),
                      ],
                      SizedBox(height: isSmallScreen ? 16 : 20),
                    ],
                  ),
                ),
              ),

              // زر المتابعة
              _buildContinueButton(isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.flag, color: Color(0xFFDC0000)),
            onPressed: () {},
            iconSize: isSmallScreen ? 20 : 24,
          ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Text(
          'نتيجة السباق',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 22 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMainResult(bool isSmallScreen) {
    // الحصول على بيانات السائقين الحقيقية من raceStandings
    final driver1Data = _getDriverData(result.driver1Name);
    final driver2Data = _getDriverData(result.driver2Name);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getPositionColor(result.finalPosition).withOpacity(0.15),
            _getPositionColor(result.finalPosition).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        border: Border.all(
          color: _getPositionColor(result.finalPosition).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getPositionColor(result.finalPosition).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // المركز الرئيسي للفريق
          Text(
            _getPositionIcon(result.finalPosition),
            style: TextStyle(fontSize: isSmallScreen ? 56 : 64),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            _getPositionText(result.finalPosition),
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),

          // أداء السائقين
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDriverResult(
                    result.driver1Name,
                    driver1Data?['position'] ?? result.driver1Position,
                    true,
                    isSmallScreen,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: _buildDriverResult(
                    result.driver2Name,
                    driver2Data?['position'] ?? result.driver2Position,
                    false,
                    isSmallScreen,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),

          // النقاط الإجمالية
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20 : 24,
              vertical: isSmallScreen ? 12 : 16,
            ),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(color: Colors.amber),
            ),
            child: Text(
              '${result.pointsEarned} نقطة إجمالية',
              style: TextStyle(
                color: Colors.amber,
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // الإنجازات الخاصة
          if (result.finalPosition == 1)
            _buildSpecialAchievement('الفائز 🏆', Colors.yellow, isSmallScreen),
          if (result.fastestLap)
            _buildSpecialAchievement('أسرع لفة ⚡', Colors.purple, isSmallScreen),
          if (result.overtakes >= 5)
            _buildSpecialAchievement(
              '${result.overtakes} تجاوز 🎯',
              Colors.green,
              isSmallScreen,
            ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDriverResult(String driverName, int position, bool isDriver1, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 40 : 48,
          height: isSmallScreen ? 40 : 48,
          decoration: BoxDecoration(
            color: (isDriver1 ? Colors.blue : Colors.green).withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: isDriver1 ? Colors.blue : Colors.green),
          ),
          child: Icon(
            isDriver1 ? Icons.person : Icons.person_outline,
            color: isDriver1 ? Colors.blue : Colors.green,
            size: isSmallScreen ? 20 : 24,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Text(
          _shortenName(driverName),
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isSmallScreen ? 4 : 6),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 8 : 12,
            vertical: isSmallScreen ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: _getPositionColor(position).withOpacity(0.2),
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            border: Border.all(color: _getPositionColor(position)),
          ),
          child: Text(
            _getPositionText(position),
            style: TextStyle(
              color: _getPositionColor(position),
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriversPerformance(bool isSmallScreen) {
    final driver1Data = _getDriverData(result.driver1Name);
    final driver2Data = _getDriverData(result.driver2Name);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D1E33), Color(0xFF0A0E21)],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups,
                color: Colors.blue[300],
                size: isSmallScreen ? 20 : 24,
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Text(
                'أداء السائقين',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildDriverDetail(
            result.driver1Name,
            driver1Data?['position'] ?? result.driver1Position,
            driver1Data?['points'] ?? _calculatePoints(result.driver1Position),
            driver1Data?['time'] ?? '--:--.---',
            Colors.blue,
            isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildDriverDetail(
            result.driver2Name,
            driver2Data?['position'] ?? result.driver2Position,
            driver2Data?['points'] ?? _calculatePoints(result.driver2Position),
            driver2Data?['time'] ?? '--:--.---',
            Colors.green,
            isSmallScreen,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDriverDetail(String name, int position, int points, String time, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 40 : 48,
            height: isSmallScreen ? 40 : 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Center(
              child: Text(
                _getPositionIcon(position),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  'النقاط: $points | الوقت: $time',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _getPositionText(position),
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaceStandings(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D1E33), Color(0xFF0A0E21)],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.leaderboard,
                color: Colors.orange[300],
                size: isSmallScreen ? 20 : 24,
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Text(
                'ترتيب المتسابقين',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildStandingsHeader(isSmallScreen),
          SizedBox(height: isSmallScreen ? 8 : 12),
          LimitedBox(
            maxHeight: 300,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: result.raceStandings.length,
              itemBuilder: (context, index) {
                final driver = result.raceStandings[index];
                return _buildDriverStandingRow(driver, index, isSmallScreen);
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStandingsHeader(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
      ),
      child: Row(
        children: [
          SizedBox(width: isSmallScreen ? 40 : 48, child: Text('المركز', style: _headerTextStyle(isSmallScreen))),
          Expanded(flex: 2, child: Text('السائق', style: _headerTextStyle(isSmallScreen))),
          Expanded(child: Text('الفريق', style: _headerTextStyle(isSmallScreen))),
          SizedBox(width: isSmallScreen ? 60 : 70, child: Text('الزمن', style: _headerTextStyle(isSmallScreen))),
          SizedBox(width: isSmallScreen ? 40 : 48, child: Text('النقاط', style: _headerTextStyle(isSmallScreen))),
        ],
      ),
    );
  }

  TextStyle _headerTextStyle(bool isSmallScreen) {
    return TextStyle(
      color: Colors.white70,
      fontSize: isSmallScreen ? 10 : 12,
      fontWeight: FontWeight.bold,
    );
  }

  Widget _buildDriverStandingRow(Map<String, dynamic> driver, int index, bool isSmallScreen) {
    bool isPlayer = driver['isPlayer'] ?? false;
    bool isDriver1 = driver['isDriver1'] ?? false;
    bool isDriver2 = driver['isDriver2'] ?? false;
    
    return Container(
      decoration: BoxDecoration(
        color: isPlayer 
            ? const Color(0xFFDC0000).withOpacity(0.2)
            : index.isEven 
                ? Colors.transparent 
                : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
      ),
      margin: const EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12, horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: isSmallScreen ? 40 : 48,
            child: Row(
              children: [
                Text(
                  driver['position'].toString(),
                  style: TextStyle(
                    color: _getPositionColor(driver['position']),
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
                if (isPlayer) 
                  Icon(
                    isDriver1 ? Icons.person : Icons.person_outline,
                    color: isDriver1 ? Colors.blue : Colors.green,
                    size: isSmallScreen ? 14 : 16,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              driver['name'].toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              driver['team'].toString(),
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: isSmallScreen ? 60 : 70,
            child: Text(
              driver['time'].toString(),
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmallScreen ? 10 : 12,
              ),
            ),
          ),
          SizedBox(
            width: isSmallScreen ? 40 : 48,
            child: Text(
              driver['points'].toString(),
              style: TextStyle(
                color: Colors.green,
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizes(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D1E33), Color(0xFF0A0E21)],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: Colors.green[400],
                size: isSmallScreen ? 20 : 24,
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Text(
                'الجوائز',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildPrizeItem(
            'الجائزة المالية',
            Helpers.formatCurrency(result.prizeMoney.toDouble()),
            Icons.money,
            Colors.green,
            isSmallScreen,
          ),
          _buildPrizeItem(
            'النقاط الإجمالية',
            '+${result.pointsEarned}',
            Icons.emoji_events,
            Colors.amber,
            isSmallScreen,
          ),
          _buildPrizeItem(
            'تقييم الإستراتيجية',
            '${result.strategyRating}%',
            Icons.assessment,
            Colors.blue,
            isSmallScreen,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPrizeItem(String title, String value, IconData icon, Color color, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D1E33), Color(0xFF0A0E21)],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: Colors.blue[300],
                size: isSmallScreen ? 20 : 24,
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Text(
                'الإحصائيات',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Wrap(
            spacing: isSmallScreen ? 12 : 16,
            runSpacing: isSmallScreen ? 12 : 16,
            children: [
              _buildStatCard('التجاوزات', '${result.overtakes}', '🎯', Colors.orange, isSmallScreen),
              _buildStatCard('اللفات', '${result.completedLaps}', '⏱️', Colors.blue, isSmallScreen),
              _buildStatCard('التقييم', '${result.strategyRating}%', '⭐', Colors.green, isSmallScreen),
              if (result.fastestLap) _buildStatCard('أسرع لفة', 'نعم', '⚡', Colors.purple, isSmallScreen),
              _buildStatCard('توقفات الصيانة', '${result.pitStopLap}', '🛞', Colors.red, isSmallScreen),
              _buildStatCard('الصعوبة', '${(result.difficulty * 100).toInt()}%', '🎯', Colors.amber, isSmallScreen),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(String label, String value, String emoji, Color color, bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? 110 : 130,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: isSmallScreen ? 20 : 24)),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaceEvents(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D1E33), Color(0xFF0A0E21)],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list,
                color: Colors.orange[300],
                size: isSmallScreen ? 20 : 24,
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Text(
                'أحداث السباق',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          ...result.raceEvents.map((event) => _buildEventItem(event, isSmallScreen)),
        ],
      ),
    ).animate().fadeIn(delay: 1300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildEventItem(String event, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: _getEventColor(event).withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: _getEventColor(event).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getEventColor(event),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Text(
              event,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmallScreen ? 13 : 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: ElevatedButton(
        onPressed: onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC0000),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          ),
          elevation: 8,
          shadowColor: const Color(0xFFDC0000).withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'المتابعة إلى المسيرة',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1500.ms).slideY(begin: 0.8, end: 0);
  }

  Widget _buildSpecialAchievement(String text, Color color, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getAchievementIcon(text), color: color, size: isSmallScreen ? 18 : 20),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // دوال مساعدة محسنة
  Map<String, dynamic>? _getDriverData(String driverName) {
    try {
      return result.raceStandings.firstWhere(
        (driver) => driver['name'] == driverName,
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }

  String _shortenName(String name) {
    if (name.length <= 12) return name;
    return '${name.substring(0, 10)}..';
  }

  int _calculatePoints(int position) {
    List<int> pointsSystem = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1];
    return position <= pointsSystem.length ? pointsSystem[position - 1] : 0;
  }

  String _getPositionIcon(int position) {
    switch (position) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      case 4: return '4️⃣';
      case 5: return '5️⃣';
      case 6: return '6️⃣';
      case 7: return '7️⃣';
      case 8: return '8️⃣';
      case 9: return '9️⃣';
      case 10: return '🔟';
      default: return '🏁';
    }
  }

  String _getPositionText(int position) {
    switch (position) {
      case 1: return 'الأول';
      case 2: return 'الثاني';
      case 3: return 'الثالث';
      case 4: return 'الرابع';
      case 5: return 'الخامس';
      case 6: return 'السادس';
      case 7: return 'السابع';
      case 8: return 'الثامن';
      case 9: return 'التاسع';
      case 10: return 'العاشر';
      default: return 'مركز $position';
    }
  }

  Color _getPositionColor(int position) {
    if (position == 1) return Colors.amber;
    if (position <= 3) return Colors.green;
    if (position <= 10) return Colors.blue;
    return Colors.grey;
  }

  IconData _getAchievementIcon(String achievement) {
    if (achievement.contains('🏆')) return Icons.emoji_events;
    if (achievement.contains('⚡')) return Icons.offline_bolt;
    if (achievement.contains('🎯')) return Icons.track_changes;
    return Icons.star;
  }

  Color _getEventColor(String event) {
    if (event.contains('تجاوز') || event.contains('أسرع') || event.contains('ممتاز')) 
      return Colors.green;
    if (event.contains('عطل') || event.contains('مشكلة') || event.contains('خسر')) 
      return Colors.red;
    if (event.contains('توقيف') || event.contains('عقوبة')) 
      return Colors.orange;
    return Colors.blue;
  }
}