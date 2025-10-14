import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../services/save_manager.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class TeamManagementPage extends StatelessWidget {
  const TeamManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final saveManager = Provider.of<SaveManager>(context);
    final team = saveManager.playerTeam!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفريق'),
        backgroundColor: const Color(0xFF1D1E33),
      ),
      backgroundColor: const Color(0xFF0A0E21),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // معلومات الفريق
            _buildTeamInfo(team),
            const SizedBox(height: 20),

            // التطوير
            Expanded(child: _buildUpgradeSection(team, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfo(Team team) {
    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الميزانية: ${Helpers.formatCurrency(team.budget)}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'الأداء الكلي',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '${team.overallPerformance.toInt()}%',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: team.overallPerformance / 100,
              backgroundColor: Colors.grey[800],
              color: const Color(0xFFDC0000),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeSection(Team team, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تطوير السيارة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildUpgradeCard(
                'engine',
                Icons.engineering,
                team.upgrades['engine']!,
                AppConstants.upgradeCosts['engine']!,
                AppConstants.upgradeBoosts['engine']!,
                team,
                context,
              ),
              _buildUpgradeCard(
                'chassis',
                Icons.directions_car,
                team.upgrades['chassis']!,
                AppConstants.upgradeCosts['chassis']!,
                AppConstants.upgradeBoosts['chassis']!,
                team,
                context,
              ),
              _buildUpgradeCard(
                'aero',
                Icons.air,
                team.upgrades['aero']!,
                AppConstants.upgradeCosts['aero']!,
                AppConstants.upgradeBoosts['aero']!,
                team,
                context,
              ),
              _buildUpgradeCard(
                'reliability',
                Icons.security,
                team.upgrades['reliability']!,
                AppConstants.upgradeCosts['reliability']!,
                AppConstants.upgradeBoosts['reliability']!,
                team,
                context,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeCard(
    String title,
    IconData icon,
    int currentLevel,
    int cost,
    double boost,
    Team team,
    BuildContext context,
  ) {
    final canUpgrade =
        currentLevel < AppConstants.maxUpgradeLevel && team.budget >= cost;

    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFDC0000)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'المستوى: $currentLevel/${AppConstants.maxUpgradeLevel}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'التحسين: +${boost.toInt()}%',
              style: const TextStyle(color: Colors.green),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: currentLevel / AppConstants.maxUpgradeLevel,
              backgroundColor: Colors.grey[800],
              color: const Color(0xFFDC0000),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: canUpgrade
                  ? () => _upgradePart(
                      title.toLowerCase(),
                      cost,
                      boost,
                      team,
                      context,
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canUpgrade
                    ? const Color(0xFFDC0000)
                    : Colors.grey,
                minimumSize: const Size(double.infinity, 36),
              ),
              child: Text(
                canUpgrade
                    ? 'تطوير (${Helpers.formatCurrency(cost.toDouble())})'
                    : 'لا يمكن التطوير',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _upgradePart(
  String part,
  int cost,
  double boost,
  Team team,
  BuildContext context,
) {
  final saveManager = Provider.of<SaveManager>(context, listen: false);

  // تحقق أولاً أن الجزء موجود في خريطة الترقيات
  if (!team.upgrades.containsKey(part)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ الجزء "$part" غير موجود في السيارة!'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // تحقق أن الترقية ممكنة
  if (team.upgrades[part]! >= 5) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ لقد وصلت الحد الأقصى لتطوير $part!'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  // تحقق من الميزانية
  if (team.budget < cost) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('💰 الميزانية غير كافية لتطوير $part!'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // نفذ الترقية
  if (team.upgradeCar(part, cost, boost)) {
    saveManager.saveGame(team: team);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ تم تطوير $part بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ لم يتم الترقية بسبب خطأ غير متوقع.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

}
