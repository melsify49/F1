import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class UpgradeCard extends StatelessWidget {
  final String title;
  final String description;
  final int currentLevel;
  final int maxLevel;
  final int cost;
  final double performanceBoost;
  final bool canUpgrade;
  final VoidCallback onUpgrade;

  const UpgradeCard({
    super.key,
    required this.title,
    required this.description,
    required this.currentLevel,
    required this.maxLevel,
    required this.cost,
    required this.performanceBoost,
    required this.canUpgrade,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1D1E33),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان والوصف
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),

            // مستوى التطوير
            Row(
              children: [
                _buildLevelIndicator(),
                const Spacer(),
                Text(
                  'المستوى $currentLevel/$maxLevel',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // معلومات التطوير
            Row(
              children: [
                _buildInfoItem(
                  'التكلفة',
                  Helpers.formatCurrency(cost.toDouble()),
                ),
                _buildInfoItem('التحسين', '+${performanceBoost.toInt()}%'),
              ],
            ),
            const SizedBox(height: 12),

            // زر التطوير
            ElevatedButton(
              onPressed: canUpgrade ? onUpgrade : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canUpgrade
                    ? const Color(0xFFDC0000)
                    : Colors.grey,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Text(
                canUpgrade ? 'تطوير الآن' : 'لا يمكن التطوير',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelIndicator() {
    return Row(
      children: List.generate(maxLevel, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: index < currentLevel
                ? const Color(0xFFDC0000)
                : Colors.grey[700],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
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
    );
  }
}
