import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/race_result.dart';
import '../models/race_strategy.dart';
import '../utils/helpers.dart';
import 'career_page.dart';
// results_page.dart - تصميم محسن كامل
class ResultsPage extends StatelessWidget {
  final RaceResult raceResult;

  const ResultsPage({
    super.key, 
    required this.raceResult,
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
            horizontal: isSmallScreen ? 12 : 20,
            vertical: 16,
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(context, isSmallScreen),
              const SizedBox(height: 20),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildMainResultCard(isSmallScreen),
                      const SizedBox(height: 16),
                      _buildDriversPerformance(isSmallScreen),
                      const SizedBox(height: 16),
                      _buildRaceStandings(isSmallScreen),
                      const SizedBox(height: 16),
                      _buildStatisticsCard(isSmallScreen),
                      const SizedBox(height: 16),
                      if (raceResult.raceEvents.isNotEmpty)
                        _buildRaceEvents(isSmallScreen),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Continue Button
              _buildContinueButton(context, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'نتيجة السباق',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 22 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDC0000), Color(0xFF850000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.flag,
              color: Colors.white,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainResultCard(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getPositionColor(raceResult.finalPosition).withOpacity(0.15),
            _getPositionColor(raceResult.finalPosition).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getPositionColor(raceResult.finalPosition).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getPositionColor(raceResult.finalPosition).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Position
          Text(
            _getPositionIcon(raceResult.finalPosition),
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 8),
          Text(
            _getPositionText(raceResult.finalPosition),
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 24 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Points and Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultStat('النقاط', '+${raceResult.pointsEarned}', 
                    Icons.emoji_events, Colors.amber, isSmallScreen),
                _buildResultStat('الجائزة', Helpers.formatCurrency(raceResult.prizeMoney.toDouble()), 
                    Icons.attach_money, Colors.green, isSmallScreen),
                _buildResultStat('التقييم', '${raceResult.strategyRating}%', 
                    Icons.assessment, Colors.blue, isSmallScreen),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Additional Stats
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMiniStat('التجاوزات', '${raceResult.overtakes}', '🎯'),
              _buildMiniStat('اللفات', '${raceResult.completedLaps}', '⏱️'),
              _buildMiniStat('التوقفات', '${raceResult.pitStopLap}', '🛑'),
              if (raceResult.fastestLap)
                _buildMiniStat('أسرع لفة', 'نعم', '⚡'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultStat(String title, String value, IconData icon, Color color, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 50 : 60,
          height: isSmallScreen ? 50 : 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
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
        ],
      ),
    );
  }

  Widget _buildDriversPerformance(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D1E33), Color(0xFF0A0E21)],
        ),
        borderRadius: BorderRadius.circular(24),
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
              Icon(Icons.groups, color: Colors.blue[300], size: isSmallScreen ? 20 : 24),
              const SizedBox(width: 8),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDriverPerformanceCard(
                  raceResult.driver1Name,
                  raceResult.driver1Position,
                  true,
                  isSmallScreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDriverPerformanceCard(
                  raceResult.driver2Name,
                  raceResult.driver2Position,
                  false,
                  isSmallScreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverPerformanceCard(String name, int position, bool isDriver1, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDriver1 ? Colors.blue : Colors.green).withOpacity(0.2),
            (isDriver1 ? Colors.blue : Colors.green).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDriver1 ? Colors.blue : Colors.green).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              color: isDriver1 ? Colors.blue : Colors.green,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getPositionColor(position).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getPositionColor(position)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getPositionText(position),
                  style: TextStyle(
                    color: _getPositionColor(position),
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.star,
                  // _getPositionIcon(position),
                  color: _getPositionColor(position),
                  size: isSmallScreen ? 16 : 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getPositionAnalysis(position),
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 11 : 12,
            ),
            textAlign: TextAlign.center,
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
        borderRadius: BorderRadius.circular(24),
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
              Icon(Icons.leaderboard, color: Colors.orange[300], size: isSmallScreen ? 20 : 24),
              const SizedBox(width: 8),
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
          const SizedBox(height: 16),
          LimitedBox(
            maxHeight: 250,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: raceResult.raceStandings.length,
              itemBuilder: (context, index) {
                final driver = raceResult.raceStandings[index];
                return _buildDriverStandingRow(driver, index, isSmallScreen);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStandingRow(Map<String, dynamic> driver, int index, bool isSmallScreen) {
    bool isPlayer = driver['isPlayer'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isPlayer 
            ? const Color(0xFFDC0000).withOpacity(0.2)
            : index.isEven 
                ? Colors.white.withOpacity(0.02)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isPlayer 
            ? Border.all(color: const Color(0xFFDC0000).withOpacity(0.5))
            : null,
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _getPositionColor(driver['position']).withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: _getPositionColor(driver['position'])),
          ),
          child: Center(
            child: Text(
              driver['position'].toString(),
              style: TextStyle(
                color: _getPositionColor(driver['position']),
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
        ),
        title: Text(
          driver['name'].toString(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
            fontSize: isSmallScreen ? 13 : 15,
          ),
        ),
        subtitle: Text(
          driver['team'].toString(),
          style: TextStyle(
            color: Colors.white70,
            fontSize: isSmallScreen ? 11 : 12,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              driver['time'].toString(),
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmallScreen ? 10 : 11,
              ),
            ),
            Text(
              driver['points'].toString(),
              style: TextStyle(
                color: Colors.green,
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: 4,
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CareerPage()),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC0000),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }

  // دوال مساعدة محسنة
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

  IconData _getPositionIconData(int position) {
    if (position == 1) return Icons.emoji_events;
    if (position <= 3) return Icons.workspace_premium;
    if (position <= 10) return Icons.check_circle;
    return Icons.trending_down;
  }

  String _getPositionAnalysis(int position) {
    if (position == 1) return 'فوز مذهل! 🏆';
    if (position <= 3) return 'منصة تتويج 🥈';
    if (position <= 5) return 'أداء ممتاز ✅';
    if (position <= 10) return 'نقاط جيدة 📊';
    if (position <= 15) return 'بدون نقاط ⚠️';
    return 'أداء ضعيف ❌';
  }

  Color _getPositionColor(int position) {
    if (position == 1) return Colors.amber;
    if (position <= 3) return Colors.green;
    if (position <= 10) return Colors.blue;
    return Colors.grey;
  }

  // باقي الدوال المساعدة...
  Widget _buildStatisticsCard(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D1E33), Color(0xFF0A0E21)],
        ),
        borderRadius: BorderRadius.circular(24),
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
              Icon(Icons.analytics, color: Colors.purple[300], size: isSmallScreen ? 20 : 24),
              const SizedBox(width: 8),
              Text(
                'إحصائيات متقدمة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildAdvancedStat('الإطارات', _getTireStrategy(), Icons.directions_car, Colors.blue),
              _buildAdvancedStat('متوسط السرعة', '${_getAverageSpeed()} كم/س', Icons.speed, Colors.green),
              _buildAdvancedStat('كفاءة الإستراتيجية', '${_getStrategyEfficiency()}%', Icons.trending_up, Colors.orange),
              _buildAdvancedStat('أسرع لفة', _getFastestLapTime(), Icons.offline_bolt, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedStat(String title, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
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
        borderRadius: BorderRadius.circular(24),
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
              Icon(Icons.event_note, color: Colors.cyan[300], size: isSmallScreen ? 20 : 24),
              const SizedBox(width: 8),
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
          const SizedBox(height: 16),
          ...raceResult.raceEvents.map((event) => _buildEventItem(event)),
        ],
      ),
    );
  }

  Widget _buildEventItem(String event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getEventColor(event).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              event,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
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

  // دوال مساعدة للإحصائيات
  String _getTireStrategy() {
    List<String> strategies = ['سوفت-متوسط', 'متوسط-هارد', 'سوفت-سوفت-هارد', 'هارد-متوسط'];
    return strategies[raceResult.finalPosition % strategies.length];
  }

  String _getFastestLapTime() {
    double baseTime = 78.5 + (raceResult.difficulty * 2);
    double variation = (raceResult.finalPosition - 1) * 0.3;
    return '${(baseTime + variation).toStringAsFixed(3)} ث';
  }

  String _getAverageSpeed() {
    int baseSpeed = 220 - (raceResult.difficulty * 10).toInt();
    int variation = (raceResult.finalPosition - 1) * 2;
    return (baseSpeed - variation).toString();
  }

  String _getStrategyEfficiency() {
    int efficiency = raceResult.strategyRating - (raceResult.finalPosition * 2);
    return efficiency.clamp(60, 95).toString();
  }
}