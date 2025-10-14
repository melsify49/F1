import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/driver.dart';
import '../models/team.dart';
import '../services/save_manager.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'driver_card.dart';

class TeamManagement extends StatelessWidget {
  const TeamManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final saveManager = Provider.of<SaveManager>(context);
    final team = saveManager.playerTeam!;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // شريط العنوان
            _buildHeader(team),
            const SizedBox(height: 20),

            // علامات التبويب
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1E33),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        indicator: BoxDecoration(
                          color: AppConstants.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tabs: const [
                          Tab(text: 'التطوير'),
                          Tab(text: 'السائقون'),
                          Tab(text: 'المالية'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildUpgradeTab(team, context),
                          _buildDriversTab(team, context),
                          _buildFinanceTab(team),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Team team) {
    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppConstants.primaryColor,
              radius: 30,
              child: Text(
                team.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
                    'البلد: ${team.country}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'الميزانية: ${Helpers.formatCurrency(team.budget)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text(
                  'الأداء الكلي',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '${team.overallPerformance.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  team.teamTier,
                  style: TextStyle(
                    color: _getTierColor(team.teamTier),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'فريق مصنع 🏭':
        return Colors.orange;
      case 'فريق منتصف 📊':
        return Colors.blue;
      case 'فريق صغير 🔰':
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  Widget _buildUpgradeTab(Team team, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تطوير أجزاء السيارة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildUpgradeCard(
                'المحرك',
                Icons.engineering,
                'القوة والتسارع',
                team.getUpgradeLevel('engine'),
                team.getUpgradeCost('engine'),
                team.getUpgradeBoost('engine'),
                team,
                context,
                'engine',
              ),
              _buildUpgradeCard(
                'الهيكل',
                Icons.directions_car,
                'الوزن والتوازن',
                team.getUpgradeLevel('chassis'),
                team.getUpgradeCost('chassis'),
                team.getUpgradeBoost('chassis'),
                team,
                context,
                'chassis',
              ),
              _buildUpgradeCard(
                'الديناميكا',
                Icons.air,
                'التحكم في المنعطفات',
                team.getUpgradeLevel('aero'),
                team.getUpgradeCost('aero'),
                team.getUpgradeBoost('aero'),
                team,
                context,
                'aero',
              ),
              _buildUpgradeCard(
                'الموثوقية',
                Icons.security,
                'تقليل الأعطال',
                team.getUpgradeLevel('reliability'),
                team.getUpgradeCost('reliability'),
                team.getUpgradeBoost('reliability'),
                team,
                context,
                'reliability',
              ),
              _buildUpgradeCard(
                'الإلكترونيات',
                Icons.memory,
                'أنظمة التحكم',
                team.getUpgradeLevel('electronics'),
                team.getUpgradeCost('electronics'),
                team.getUpgradeBoost('electronics'),
                team,
                context,
                'electronics',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPerformanceChart(team),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(
    String title,
    IconData icon,
    String description,
    int currentLevel,
    int cost,
    double boost,
    Team team,
    BuildContext context,
    String partKey,
  ) {
    final canUpgrade = team.canUpgrade(partKey);
    final nextLevel = currentLevel + 1;

    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppConstants.primaryColor),
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
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLevelIndicator(currentLevel),
                const SizedBox(width: 8),
                Text(
                  'المستوى $currentLevel',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'التحسين: +${boost.toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.green, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: canUpgrade
                  ? () => _upgradePart(partKey, team, context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canUpgrade
                    ? AppConstants.primaryColor
                    : Colors.grey,
                minimumSize: const Size(double.infinity, 36),
              ),
              child: Text(
                canUpgrade
                    ? 'تطوير للمستوى $nextLevel\n${Helpers.formatCurrency(cost.toDouble())}'
                    : 'لا يمكن التطوير',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelIndicator(int level) {
    return Row(
      children: List.generate(5, (index) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: index < level ? AppConstants.primaryColor : Colors.grey[700],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildPerformanceChart(Team team) {
    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات الفريق',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatBar('أداء السيارة', team.carPerformance / 100),
            _buildStatBar('قوة المحرك', team.enginePower / 100),
            _buildStatBar('الديناميكا الهوائية', team.aerodynamics / 100),
            _buildStatBar('الموثوقية', team.reliability / 100),
            const SizedBox(height: 16),
            _buildDriverStats(team),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[800],
              color: AppConstants.primaryColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStats(Team team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مهارات السائقين:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildDriverStat('السائق 1', team.driver1.overallRating / 100),
        _buildDriverStat('السائق 2', team.driver2.overallRating / 100),
      ],
    );
  }

  Widget _buildDriverStat(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[800],
              color: Colors.blue,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDriversTab(Team team, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'طاقم السائقين',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // السائقون الحاليون
        Text(
          'السائقون الحاليون',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DriverCard(driver: team.driver1),
        const SizedBox(height: 8),
        DriverCard(driver: team.driver2),
      ],
    );
  }

  Widget _buildFinanceTab(Team team) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الإدارة المالية',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // الميزانية
          _buildFinanceCard(
            'الميزانية الحالية',
            Helpers.formatCurrency(team.budget),
            Icons.account_balance_wallet,
            Colors.green,
          ),

          const SizedBox(height: 16),

          // أهداف الفريق
          _buildFinanceSection('أهداف الفريق', [
            _buildFinanceItem(
              'هدف البطولة',
              'المركز ${team.championshipTarget}',
              Icons.emoji_events,
            ),
            _buildFinanceItem(
              'هدف الميزانية',
              Helpers.formatCurrency(team.budgetTarget.toDouble()),
              Icons.attach_money,
            ),
            _buildFinanceItem(
              'محور التطوير',
              _getDevelopmentFocus(team.developmentFocus),
              Icons.trending_up,
            ),
          ]),

          const SizedBox(height: 16),

          // الإحصائيات
          _buildFinanceSection('الإحصائيات', [
            _buildFinanceItem(
              'النقاط',
              '${team.points}',
              Icons.score,
            ),
            _buildFinanceItem(
              'السباقات المربوحة',
              '${team.racesWon}',
              Icons.flag,
            ),
            _buildFinanceItem(
              'بطولات الصانعين',
              '${team.constructorsChampionships}',
              Icons.star_border_outlined,
            ),
          ]),
        ],
      ),
    );
  }

  String _getDevelopmentFocus(int focus) {
    switch (focus) {
      case 1:
        return 'الأداء';
      case 2:
        return 'الموثوقية';
      case 3:
        return 'التوازن';
      default:
        return 'غير محدد';
    }
  }

  Widget _buildFinanceCard(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    amount,
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceSection(String title, List<Widget> items) {
    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70),
            ),
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

  void _upgradePart(String part, Team team, BuildContext context) {
    final saveManager = Provider.of<SaveManager>(context, listen: false);

    if (team.upgrade(part)) {
      saveManager.saveGame(team: team);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تطوير $part بنجاح! +${team.getUpgradeBoost(part).toStringAsFixed(1)}% أداء'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا يمكن التطوير - تحقق من الميزانية أو المستوى الأقصى',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}