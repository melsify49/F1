import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/driver.dart';
import '../models/team.dart';
import '../services/save_manager.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'driver_card.dart';

// team_management.dart - تصميم محسن كامل
class TeamManagement extends StatelessWidget {
  TeamManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final saveManager = Provider.of<SaveManager>(context);
    final team = saveManager.playerTeam!;
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
              // App Bar
              _buildAppBar(context, isSmallScreen),
              const SizedBox(height: 20),

              // Team Header
              _buildTeamHeader(team, isSmallScreen),
              const SizedBox(height: 20),

              // Tabs Content
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      // Tabs
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TabBar(
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          indicator: BoxDecoration(
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
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.build, size: isSmallScreen ? 16 : 18),
                                  const SizedBox(width: 6),
                                  Text('التطوير', style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.groups, size: isSmallScreen ? 16 : 18),
                                  const SizedBox(width: 6),
                                  Text('السائقون', style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.attach_money, size: isSmallScreen ? 16 : 18),
                                  const SizedBox(width: 6),
                                  Text('المالية', style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildUpgradeTab(team, context, isSmallScreen),
                            _buildDriversTab(team, context, isSmallScreen),
                            _buildFinanceTab(team, isSmallScreen),
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
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isSmallScreen) {
    return Row(
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
        Text(
          'إدارة الفريق',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 22 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
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
            Icons.groups,
            color: Colors.white,
            size: isSmallScreen ? 20 : 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamHeader(Team team, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
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
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Team Logo
          Container(
            width: isSmallScreen ? 70 : 90,
            height: isSmallScreen ? 70 : 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDC0000), Color(0xFF850000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDC0000).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                team.name[0],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 28 : 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Team Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'البلد: ${team.country}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet, 
                         color: Colors.green[400], 
                         size: isSmallScreen ? 16 : 18),
                    const SizedBox(width: 6),
                    Text(
                      Helpers.formatCurrency(team.budget),
                      style: TextStyle(
                        color: Colors.green[400],
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Overall Performance
          Column(
            children: [
              Text(
                'الأداء الكلي',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '${team.overallPerformance.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                team.teamTier,
                style: TextStyle(
                  color: _getTierColor(team.teamTier),
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeTab(Team team, BuildContext context, bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Text(
              'تطوير أجزاء السيارة',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Upgrade Cards
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isSmallScreen ? 2 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isSmallScreen ? 0.9 : 1.0,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _upgradeParts.length,
            itemBuilder: (context, index) {
              final part = _upgradeParts[index];
              return _buildUpgradeCard(part, team, context, isSmallScreen);
            },
          ),
          const SizedBox(height: 20),

          // Performance Chart
          _buildPerformanceChart(team, isSmallScreen),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _upgradeParts = [
    {
      'key': 'engine',
      'title': 'المحرك',
      'icon': Icons.engineering,
      'desc': 'القوة والتسارع',
      'color': Colors.blue,
    },
    {
      'key': 'chassis',
      'title': 'الهيكل',
      'icon': Icons.directions_car,
      'desc': 'الوزن والتوازن',
      'color': Colors.green,
    },
    {
      'key': 'aero',
      'title': 'الديناميكا',
      'icon': Icons.air,
      'desc': 'التحكم في المنعطفات',
      'color': Colors.orange,
    },
    {
      'key': 'reliability',
      'title': 'الموثوقية',
      'icon': Icons.security,
      'desc': 'تقليل الأعطال',
      'color': Colors.red,
    },
    {
      'key': 'electronics',
      'title': 'الإلكترونيات',
      'icon': Icons.memory,
      'desc': 'أنظمة التحكم',
      'color': Colors.purple,
    },
  ];

  Widget _buildUpgradeCard(
    Map<String, dynamic> part,
    Team team,
    BuildContext context,
    bool isSmallScreen,
  ) {
    final partKey = part['key'] as String;
    final currentLevel = team.getUpgradeLevel(partKey);
    final cost = team.getUpgradeCost(partKey);
    final boost = team.getUpgradeBoost(partKey);
    final canUpgrade = team.canUpgrade(partKey);
    final nextLevel = currentLevel + 1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            part['color'].withOpacity(0.15),
            part['color'].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: part['color'].withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: isSmallScreen ? 36 : 44,
                  height: isSmallScreen ? 36 : 44,
                  decoration: BoxDecoration(
                    color: part['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: part['color'].withOpacity(0.5)),
                  ),
                  child: Icon(part['icon'], color: part['color'], size: isSmallScreen ? 18 : 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        part['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        part['desc'],
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Level Indicator
            Row(
              children: [
                _buildLevelIndicator(currentLevel, isSmallScreen),
                const SizedBox(width: 8),
                Text(
                  'المستوى $currentLevel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Boost Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Text(
                'التحسين: +${boost.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Upgrade Button
            ElevatedButton(
              onPressed: canUpgrade
                  ? () => _upgradePart(partKey, team, context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canUpgrade
                    ? part['color']
                    : Colors.grey[600],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: canUpgrade ? 4 : 0,
              ),
              child: Text(
                canUpgrade
                    ? 'تطوير للمستوى $nextLevel\n${Helpers.formatCurrency(cost.toDouble())}'
                    : 'لا يمكن التطوير',
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelIndicator(int level, bool isSmallScreen) {
    return Row(
      children: List.generate(5, (index) {
        return Container(
          width: isSmallScreen ? 6 : 8,
          height: isSmallScreen ? 6 : 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: index < level ? Colors.green : Colors.grey[700],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildPerformanceChart(Team team, bool isSmallScreen) {
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
          Text(
            'إحصائيات الفريق',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatBar('أداء السيارة', team.carPerformance / 100, Colors.blue),
          _buildStatBar('قوة المحرك', team.enginePower / 100, Colors.green),
          _buildStatBar('الديناميكا الهوائية', team.aerodynamics / 100, Colors.orange),
          _buildStatBar('الموثوقية', team.reliability / 100, Colors.red),
          const SizedBox(height: 20),
          _buildDriverStats(team, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStats(Team team, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مهارات السائقين',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDriverStatCard(team.driver1, 'السائق 1', Colors.blue, isSmallScreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDriverStatCard(team.driver2, 'السائق 2', Colors.green, isSmallScreen),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDriverStatCard(Driver driver, String title, Color color, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            driver.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Text(
              '${driver.overallRating.toInt()}%',
              style: TextStyle(
                color: color,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriversTab(Team team, BuildContext context, bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Text(
              'طاقم السائقين',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'السائقون الحاليون',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDriverCard(team.driver1, Colors.blue, isSmallScreen),
          const SizedBox(height: 12),
          _buildDriverCard(team.driver2, Colors.green, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Driver driver, Color color, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 60 : 80,
            height: isSmallScreen ? 60 : 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(
              Icons.person,
              color: color,
              size: isSmallScreen ? 30 : 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'البلد: ${driver.nationality}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'العمر: ${driver.age} سنة',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    'المستوى: ${driver.overallRating.toInt()}%',
                    style: TextStyle(
                      color: color,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceTab(Team team, bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Text(
              'الإدارة المالية',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Budget Card
          _buildFinanceCard(
            'الميزانية الحالية',
            Helpers.formatCurrency(team.budget),
            Icons.account_balance_wallet,
            Colors.green,
            isSmallScreen,
          ),
          const SizedBox(height: 16),

          // Team Goals
          _buildFinanceSection(
            'أهداف الفريق',
            [
              _buildFinanceItem('هدف البطولة', 'المركز ${team.championshipTarget}', Icons.emoji_events, Colors.amber),
              _buildFinanceItem('هدف الميزانية', Helpers.formatCurrency(team.budgetTarget.toDouble()), Icons.attach_money, Colors.green),
              _buildFinanceItem('محور التطوير', _getDevelopmentFocus(team.developmentFocus), Icons.trending_up, Colors.blue),
            ],
            isSmallScreen,
          ),
          const SizedBox(height: 16),

          // Statistics
          _buildFinanceSection(
            'الإحصائيات',
            [
              _buildFinanceItem('النقاط', '${team.points}', Icons.score, Colors.blue),
              _buildFinanceItem('السباقات المربوحة', '${team.racesWon}', Icons.flag, Colors.green),
              _buildFinanceItem('بطولات الصانعين', '${team.constructorsChampionships}', Icons.star, Colors.amber),
            ],
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(String title, String amount, IconData icon, Color color, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 50 : 60,
            height: isSmallScreen ? 50 : 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(icon, color: color, size: isSmallScreen ? 24 : 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontSize: isSmallScreen ? 20 : 24,
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

  Widget _buildFinanceSection(String title, List<Widget> items, bool isSmallScreen) {
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
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildFinanceItem(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // دوال مساعدة
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

  void _upgradePart(String part, Team team, BuildContext context) {
    final saveManager = Provider.of<SaveManager>(context, listen: false);

    if (team.upgrade(part)) {
      saveManager.saveGame(team: team);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تطوير $part بنجاح! +${team.getUpgradeBoost(part).toStringAsFixed(1)}% أداء'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('لا يمكن التطوير - تحقق من الميزانية أو المستوى الأقصى'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}