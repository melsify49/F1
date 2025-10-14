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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // العنوان
              _buildHeader(),
              const SizedBox(height: 20),

              // النتيجة الرئيسية
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildMainResult(),
                      const SizedBox(height: 20),

                      // الجوائز
                      _buildPrizes(),
                      const SizedBox(height: 20),

                      // الإحصائيات
                      _buildStatistics(),
                      const SizedBox(height: 20),

                      // الأحداث
                      _buildRaceEvents(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // زر المتابعة
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.flag, color: Color(0xFFDC0000), size: 32),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // المركز
            Text(
              Helpers.getPositionIcon(result.finalPosition),
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),

            Text(
              result.positionText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // النقاط
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber),
              ),
              child: Text(
                '+${result.pointsEarned} نقطة',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // الإنجازات الخاصة
            if (result.finalPosition == 1)
              _buildSpecialAchievement('الفائز 🏆', Colors.yellow),
            if (result.fastestLap)
              _buildSpecialAchievement('أسرع لفة ⚡', Colors.purple),
            if (result.overtakes >= 5)
              _buildSpecialAchievement(
                '${result.overtakes} تجاوز 🎯',
                Colors.green,
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSpecialAchievement(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPrizes() {
    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'الجوائز',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPrizeItem(
              'الجائزة المالية',
              Helpers.formatCurrency(result.prizeMoney.toDouble()),
              Icons.money,
            ),
            _buildPrizeItem(
              'النقاط',
              '+${result.pointsEarned}',
              Icons.emoji_events,
            ),
            _buildPrizeItem(
              'تقييم الإستراتيجية',
              '${result.strategyRating}%',
              Icons.assessment,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPrizeItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white70)),
          ),
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

  Widget _buildStatistics() {
    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'الإحصائيات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard('التجاوزات', '${result.overtakes}', '🎯'),
                _buildStatCard('اللفات', '${result.completedLaps}', '⏱️'),
                _buildStatCard('التقييم', '${result.strategyRating}%', '⭐'),
                if (result.fastestLap) _buildStatCard('أسرع لفة', 'نعم', '⚡'),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(String label, String value, String emoji) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaceEvents() {
    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.list, color: Colors.orange),
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
            ...result.raceEvents.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              return _buildEventItem(event, index);
            }).toList(),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildEventItem(String event, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFDC0000),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(event, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC0000),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'المتابعة إلى المسيرة',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 1200.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}
