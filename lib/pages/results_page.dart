import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/race_result.dart';
import '../utils/helpers.dart';
import 'career_page.dart';

class ResultsPage extends StatelessWidget {
  final RaceResult raceResult;

  const ResultsPage({
    super.key, 
    required this.raceResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان
              _buildHeader(context),
              const SizedBox(height: 20),

              // النتيجة الرئيسية
              _buildMainResult(),
              const SizedBox(height: 20),

              // أداء السائقين
              _buildDriversPerformance(),
              const SizedBox(height: 20),

              // ترتيب المتسابقين
              _buildRaceStandings(),
              const SizedBox(height: 20),

              // إحصائيات التفاصيل
              _buildDriverDetails(),
              const SizedBox(height: 20),

              // الأحداث
              _buildRaceEvents(),
              const SizedBox(height: 30),

              // زر المتابعة
              _buildContinueButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(width: 8),
        const Text(
          'نتيجة السباق',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMainResult() {
    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // المركز والطقس والصعوبة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMainResultItem('المركز', raceResult.positionText, _getPositionColor(raceResult.finalPosition)),
                _buildMainResultItem('الطقس', raceResult.weatherText, Colors.blue),
                _buildMainResultItem('الصعوبة', raceResult.difficultyText, _getDifficultyColor(raceResult.difficulty)),
              ],
            ),
            const SizedBox(height: 16),
            
            // النقاط والجوائز
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultItem('النقاط', '${raceResult.pointsEarned}', Colors.green),
                _buildResultItem('الجائزة', Helpers.formatCurrency(raceResult.prizeMoney.toDouble()), Colors.amber),
                _buildResultItem('التقييم', '${raceResult.strategyRating}%', Colors.blue),
              ],
            ),
            const SizedBox(height: 12),
            
            // إحصائيات إضافية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultItem('التجاوزات', '${raceResult.overtakes}', Colors.orange),
                _buildResultItem('اللفات', '${raceResult.completedLaps}', Colors.purple),
                _buildResultItem('التوقفات', '${raceResult.pitStopLap}', Colors.cyan),
              ],
            ),
            
            if (raceResult.fastestLap) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purple),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.offline_bolt, color: Colors.purple[300]),
                    const SizedBox(width: 8),
                    const Text(
                      'أسرع لفة في السباق!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMainResultItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDriversPerformance() {
    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أداء السائقين',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDriverCard('السائق 1', raceResult.driver1Position, true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDriverCard('السائق 2', raceResult.driver2Position, false),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Text(
                raceResult.driversPerformance,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDriverCard(String driverName, int position, bool isDriver1) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2C3E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getPositionColor(position).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            driverName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'المركز $position',
            style: TextStyle(
              color: _getPositionColor(position),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_calculatePoints(position)} نقطة',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaceStandings() {
    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.leaderboard, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'ترتيب المتسابقين',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStandingsHeader(),
            const SizedBox(height: 8),
            LimitedBox(
              maxHeight: 200,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: raceResult.raceStandings.length,
                itemBuilder: (context, index) {
                  final driver = raceResult.raceStandings[index];
                  return _buildDriverRow(driver, index);
                },
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStandingsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        children: [
          SizedBox(width: 40, child: Text('المركز', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('السائق', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(child: Text('الفريق', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
          SizedBox(width: 60, child: Text('الزمن', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
          SizedBox(width: 40, child: Text('النقاط', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildDriverRow(Map<String, dynamic> driver, int index) {
    bool isPlayer = driver['isPlayer'] ?? false;
    return Container(
      decoration: BoxDecoration(
        color: isPlayer 
            ? const Color(0xFFDC0000).withOpacity(0.2)
            : index.isEven 
                ? Colors.transparent 
                : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Row(
              children: [
                Text(
                  driver['position'].toString(),
                  style: TextStyle(
                    color: _getPositionColor(driver['position']),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (isPlayer) 
                  const Icon(Icons.person, color: Colors.red, size: 14),
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
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              driver['team'].toString(),
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              driver['time'].toString(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              driver['points'].toString(),
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverDetails() {
    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
                  'تحليل الأداء',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailItem('الإطارات المستخدمة', _getTireStrategy(), Icons.directions_car),
            _buildDetailItem('لفة التوقف', 'اللفة ${raceResult.pitStopLap}', Icons.published_with_changes),
            _buildDetailItem('أسرع لفة', _getFastestLapTime(), Icons.offline_bolt),
            _buildDetailItem('متوسط السرعة', '${_getAverageSpeed()} كم/ساعة', Icons.speed),
            _buildDetailItem('كفاءة الإستراتيجية', '${_getStrategyEfficiency()}%', Icons.trending_up),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDetailItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaceEvents() {
    if (raceResult.raceEvents.isEmpty) {
      return const SizedBox();
    }

    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.event_note, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text(
                  'أحداث السباق',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...raceResult.raceEvents.map((event) => _buildEventItem(event)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildEventItem(String event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
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
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        icon: const Icon(Icons.arrow_forward, size: 20),
        label: const Text(
          'المتابعة إلى المسيرة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ).animate().fadeIn(delay: 1600.ms).slideY(begin: 0.8, end: 0);
  }

  // دوال مساعدة محسنة
  int _calculatePoints(int position) {
    List<int> pointsSystem = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1];
    return position <= pointsSystem.length ? pointsSystem[position - 1] : 0;
  }

  Color _getPositionColor(int position) {
    if (position == 1) return Colors.amber;
    if (position <= 3) return Colors.green;
    if (position <= 10) return Colors.blue;
    return Colors.grey;
  }

  Color _getDifficultyColor(double difficulty) {
    if (difficulty <= 0.25) return Colors.green;
    if (difficulty <= 0.5) return Colors.blue;
    if (difficulty <= 0.75) return Colors.orange;
    return Colors.red;
  }

  String _getTireStrategy() {
    List<String> strategies = ['سوفت-متوسط', 'متوسط-هارد', 'سوفت-سوفت-هارد', 'هارد-متوسط'];
    return strategies[raceResult.finalPosition % strategies.length];
  }

  String _getFastestLapTime() {
    double baseTime = 78.5 + (raceResult.difficulty * 2);
    double variation = (raceResult.finalPosition - 1) * 0.3;
    return '${(baseTime + variation).toStringAsFixed(3)} ثانية';
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