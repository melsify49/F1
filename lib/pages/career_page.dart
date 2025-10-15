import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../models/race_result.dart';
import '../models/race_event.dart';
import '../models/race_strategy.dart';
import '../services/save_manager.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'championship_page.dart';
import 'race_page.dart';
import 'team_management_page.dart';
import '../utils/season_calendar.dart';

class CareerPage extends StatelessWidget {
  const CareerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final saveManager = Provider.of<SaveManager>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    if (saveManager.playerTeam == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E21),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: const Color(0xFFDC0000),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'جاري تحميل البيانات...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
              // App Bar
              _buildAppBar(context, isSmallScreen),
              const SizedBox(height: 20),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildTeamCard(saveManager, isSmallScreen),
                      const SizedBox(height: 20),
                      _buildStatsGrid(saveManager.playerTeam!, isSmallScreen),
                      const SizedBox(height: 20),
                      _buildNextRaceCard(context, saveManager, isSmallScreen),
                      const SizedBox(height: 20),
                      _buildActionList(context, saveManager, isSmallScreen),
                      const SizedBox(height: 20),
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
            iconSize: isSmallScreen ? 20 : 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'المسيرة المهنية',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 22 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(10),
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
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: isSmallScreen ? 20 : 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard(SaveManager saveManager, bool isSmallScreen) {
    final team = saveManager.playerTeam!;
    final seasonInfo = SeasonCalendar.getSeasonInfo(saveManager.currentSeason);

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
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
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
                  color: const Color(0xFFDC0000).withOpacity(0.4),
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
          SizedBox(width: isSmallScreen ? 16 : 20),

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
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  'الموسم ${saveManager.currentSeason} - الجولة ${saveManager.currentRace}/${seasonInfo['totalRaces']}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 13 : 15,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.green[400],
                      size: isSmallScreen ? 18 : 20,
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Text(
                      Helpers.formatCurrency(team.budget),
                      style: TextStyle(
                        color: Colors.green[400],
                        fontSize: isSmallScreen ? 15 : 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Points
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 14 : 18,
              vertical: isSmallScreen ? 10 : 14,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.orange.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'النقاط',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 13 : 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  '${team.points}',
                  style: TextStyle(
                    color: Colors.white,
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

  Widget _buildStatsGrid(Team team, bool isSmallScreen) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isSmallScreen ? 1.3 : 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'أداء السيارة',
          '${team.carPerformance.toInt()}%',
          Icons.directions_car,
          Colors.blue,
          isSmallScreen,
        ),
        _buildStatCard(
          'مهارة السائقين',
          '${team.driverSkill.toInt()}%',
          Icons.groups,
          Colors.green,
          isSmallScreen,
        ),
        _buildStatCard(
          'السباقات الفائزة',
          '${team.racesWon}',
          Icons.emoji_events,
          Colors.amber,
          isSmallScreen,
        ),
        _buildStatCard(
          'السمعة',
          '${team.reputation}%',
          Icons.star,
          Colors.purple,
          isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isSmallScreen ? 50 : 60,
              height: isSmallScreen ? 50 : 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Icon(
                icon,
                color: color,
                size: isSmallScreen ? 24 : 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: isSmallScreen ? 18 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextRaceCard(BuildContext context, SaveManager saveManager, bool isSmallScreen) {
    final raceEvent = SeasonCalendar.getRaceByRound(
      saveManager.currentRace,
      saveManager.currentSeason,
    );

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
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
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
          // Header
          Row(
            children: [
              Container(
                width: isSmallScreen ? 40 : 48,
                height: isSmallScreen ? 40 : 48,
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
                child: Icon(
                  Icons.flag,
                  color: Colors.white,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: Text(
                  'السباق القادم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC0000).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDC0000)),
                ),
                child: Text(
                  'الجولة ${saveManager.currentRace}',
                  style: TextStyle(
                    color: const Color(0xFFDC0000),
                    fontSize: isSmallScreen ? 13 : 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Race Details
          Text(
            raceEvent.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.blue[300],
                size: isSmallScreen ? 16 : 18,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                '${raceEvent.circuitName} - ${raceEvent.country}',
                style: TextStyle(
                  color: Colors.blue[300],
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),

          // Race Stats
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRaceInfoItem('اللفات', '${raceEvent.totalLaps}', Icons.repeat, isSmallScreen),
                _buildRaceInfoItem('الطقس', raceEvent.weatherEmoji, Icons.wb_sunny, isSmallScreen),
                _buildRaceInfoItem('الصعوبة', raceEvent.difficultyLevel, Icons.leaderboard, isSmallScreen),
                _buildRaceInfoItem('المسافة', '${(raceEvent.circuitLength / 1000).toStringAsFixed(1)} كم', Icons.linear_scale, isSmallScreen),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),

          // Start Race Button
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 56 : 60,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RacePage(
                      raceEvent: raceEvent,
                      round: saveManager.currentRace,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC0000),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: const Color(0xFFDC0000).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow,
                    size: isSmallScreen ? 22 : 24,
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Text(
                    'بدء السباق',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 17 : 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaceInfoItem(String title, String value, IconData icon, bool isSmallScreen) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: isSmallScreen ? 18 : 20,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isSmallScreen ? 11 : 12,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 4 : 6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionList(BuildContext context, SaveManager saveManager, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Text(
            'الإجراءات السريعة',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ..._buildActionItems(context, saveManager, isSmallScreen),
      ],
    );
  }

  List<Widget> _buildActionItems(BuildContext context, SaveManager saveManager, bool isSmallScreen) {
    return [
      _buildActionItem(
        'إدارة الفريق',
        'إدارة السائقين والموارد',
        Icons.groups,
        Colors.blue,
        Icons.arrow_forward_ios,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TeamManagementPage(),
            ),
          );
        },
        isSmallScreen,
      ),
      _buildActionItem(
        'تطوير السيارة',
        'ترقية أجزاء السيارة',
        Icons.build,
        Colors.green,
        Icons.arrow_forward_ios,
        () {
          _showUpgradeDialog(context);
        },
        isSmallScreen,
      ),
      _buildActionItem(
        'بطولة الموسم',
        'عرض ترتيب السائقين والفرق',
        Icons.emoji_events,
        Colors.amber,
        Icons.arrow_forward_ios,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChampionshipPage(),
            ),
          );
        },
        isSmallScreen,
      ),
      _buildActionItem(
        'إحصائيات الموسم',
        'عرض إحصائيات الموسم الحالي',
        Icons.bar_chart,
        Colors.orange,
        Icons.arrow_forward_ios,
        () {
          _showSeasonStats(context, saveManager);
        },
        isSmallScreen,
      ),
      _buildActionItem(
        'نتائج السباقات',
        'عرض نتائج السباقات السابقة',
        Icons.flag,
        Colors.purple,
        Icons.arrow_forward_ios,
        () {
          _showRaceResults(context, saveManager);
        },
        isSmallScreen,
      ),
    ];
  }

  Widget _buildActionItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    IconData trailingIcon,
    VoidCallback onTap,
    bool isSmallScreen,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Row(
              children: [
                Container(
                  width: isSmallScreen ? 48 : 56,
                  height: isSmallScreen ? 48 : 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isSmallScreen ? 22 : 24,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: isSmallScreen ? 36 : 40,
                  height: isSmallScreen ? 36 : 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    trailingIcon,
                    color: Colors.white70,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green),
                ),
                child: const Icon(Icons.build, color: Colors.green, size: 30),
              ),
              const SizedBox(height: 16),
              const Text(
                'تطوير السيارة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'هنا يمكنك تطوير أجزاء السيارة المختلفة لتحسين أداء الفريق',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSeasonStats(BuildContext context, SaveManager saveManager) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Icon(Icons.bar_chart, color: Colors.orange, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'إحصائيات الموسم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ..._buildSeasonStatsItems(saveManager),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSeasonStatsItems(SaveManager saveManager) {
    return [
      _buildStatItem('الموسم الحالي', '${saveManager.currentSeason}'),
      _buildStatItem('السباقات المكتملة', '${saveManager.currentRace - 1}/${AppConstants.racesPerSeason}'),
      _buildStatItem('إجمالي النقاط', '${saveManager.playerTeam?.points ?? 0}'),
      _buildStatItem('السباقات الفائزة', '${saveManager.playerTeam?.racesWon ?? 0}'),
      _buildStatItem('الميزانية', Helpers.formatCurrency(saveManager.playerTeam?.budget ?? 0)),
    ];
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
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

  void _showRaceResults(BuildContext context, SaveManager saveManager) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple),
                    ),
                    child: const Icon(Icons.flag, color: Colors.purple, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'نتائج السباقات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildRaceResultsContent(saveManager),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRaceResultsContent(SaveManager saveManager) {
    if (saveManager.raceResults.isEmpty) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_outlined, color: Colors.white70, size: 60),
          SizedBox(height: 16),
          Text(
            'لا توجد نتائج حتى الآن',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return SizedBox(
      height: 300,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: saveManager.raceResults.length,
        itemBuilder: (context, index) {
          final result = saveManager.raceResults[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPositionColor(result.finalPosition).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getPositionColor(result.finalPosition)),
                ),
                child: Center(
                  child: Text(
                    _getPositionIcon(result.finalPosition),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              title: Text(
                'السباق ${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'النقاط: ${result.pointsEarned}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              trailing: Text(
                _getPositionText(result.finalPosition),
                style: TextStyle(
                  color: _getPositionColor(result.finalPosition),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  // دوال مساعدة محسنة
  String _getPositionIcon(int position) {
    switch (position) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      case 4:
        return '4️⃣';
      case 5:
        return '5️⃣';
      case 6:
        return '6️⃣';
      case 7:
        return '7️⃣';
      case 8:
        return '8️⃣';
      case 9:
        return '9️⃣';
      case 10:
        return '🔟';
      default:
        return '🏁';
    }
  }

  String _getPositionText(int position) {
    switch (position) {
      case 1:
        return 'الأول';
      case 2:
        return 'الثاني';
      case 3:
        return 'الثالث';
      case 4:
        return 'الرابع';
      case 5:
        return 'الخامس';
      case 6:
        return 'السادس';
      case 7:
        return 'السابع';
      case 8:
        return 'الثامن';
      case 9:
        return 'التاسع';
      case 10:
        return 'العاشر';
      default:
        return 'مركز $position';
    }
  }

  Color _getPositionColor(int position) {
    if (position == 1) return Colors.amber;
    if (position <= 3) return Colors.green;
    if (position <= 10) return Colors.blue;
    return Colors.grey;
  }
}