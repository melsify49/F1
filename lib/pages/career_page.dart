import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../models/race_result.dart';
import '../models/race_event.dart';
import '../models/race_strategy.dart';
import '../services/save_manager.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'race_page.dart';
import 'team_management_page.dart';
import '../utils/season_calendar.dart'; // 🆕 استيراد SeasonCalendar

class CareerPage extends StatelessWidget {
  const CareerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final saveManager = Provider.of<SaveManager>(context);
    if (saveManager.playerTeam == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E21),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFDC0000)),
              SizedBox(height: 16),
              Text(
                'جاري تحميل البيانات...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }
    final team = saveManager.playerTeam!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المسيرة المهنية',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF1D1E33),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, size: 24),
            tooltip: 'الرئيسية',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0A0E21),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الفريق
            _buildTeamCard(team, saveManager),
            const SizedBox(height: 20),

            // الإحصائيات
            _buildStatsGrid(team),
            const SizedBox(height: 20),

            // السباق القادم
            _buildNextRaceCard(context, saveManager),
            const SizedBox(height: 20),

            // قائمة المهام
            Expanded(child: _buildActionList(context, saveManager)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(Team team, SaveManager saveManager) {
    final seasonInfo = SeasonCalendar.getSeasonInfo(saveManager.currentSeason);
    return Card(
      elevation: 4,
      color: const Color(0xFF1D1E33),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFDC0000),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  team.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'الموسم ${saveManager.currentSeason} - الجولة ${saveManager.currentRace}/${seasonInfo['totalRaces']}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.green[400],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Helpers.formatCurrency(team.budget),
                        style: TextStyle(
                          color: Colors.green[400],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'النقاط',
                    style: TextStyle(color: Colors.amber, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${team.points}',
                    style: const TextStyle(
                      color: Colors.amber,
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

  Widget _buildStatsGrid(Team team) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'أداء السيارة',
          '${team.carPerformance.toInt()}%',
          Icons.directions_car,
          Colors.blue,
        ),
        _buildStatCard(
          'مهارة السائقين',
          '${team.driverSkill.toInt()}%',
          Icons.groups,
          Colors.green,
        ),
        _buildStatCard(
          'السباقات الفائزة',
          '${team.racesWon}',
          Icons.emoji_events,
          Colors.amber,
        ),
        _buildStatCard(
          'السمعة',
          '${team.reputation}%',
          Icons.star,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      color: const Color(0xFF1D1E33),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextRaceCard(BuildContext context, SaveManager saveManager) {
    final raceEvent = SeasonCalendar.getRaceByRound(
      saveManager.currentRace, 
      saveManager.currentSeason
    );
    return Card(
      elevation: 4,
      color: const Color(0xFF1D1E33),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: Color(0xFFDC0000), size: 24),
                const SizedBox(width: 8),
                const Text(
                  'السباق القادم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC0000).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'الجولة ${saveManager.currentRace}',
                    style: const TextStyle(
                      color: Color(0xFFDC0000),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              raceEvent.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[300], size: 14),
                const SizedBox(width: 4),
                Text(
                  '${raceEvent.circuitName} - ${raceEvent.country}',
                  style: TextStyle(color: Colors.blue[300], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildRaceInfoItem(
                  'اللفات',
                  '${raceEvent.totalLaps}',
                  Icons.repeat,
                ),
                _buildRaceInfoItem(
                  'الطقس',
                  raceEvent.weatherEmoji,
                  Icons.wb_sunny,
                ),
                _buildRaceInfoItem(
                  'الصعوبة',
                  raceEvent.difficultyLevel,
                  Icons.leaderboard,
                ),
                _buildRaceInfoItem(
                  'المسافة',
                  '${(raceEvent.circuitLength / 1000).toStringAsFixed(1)} كم',
                  Icons.linear_scale,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
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
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'بدء السباق',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  Widget _buildRaceInfoItem(String title, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // RaceEvent _generateRaceEvent(int round) {
  //   final eventData = _getRaceEventData(round);
  //   return RaceEvent(
  //     id: eventData['id'],
  //     name: eventData['name'],
  //     country: eventData['country'],
  //     city: eventData['city'],
  //     circuitName: eventData['circuitName'],
  //     totalLaps: eventData['totalLaps'],
  //     circuitLength: eventData['circuitLength'],
  //     lapRecord: eventData['lapRecord'],
  //     baseWeather: eventData['baseWeather'],
  //     difficulty: eventData['difficulty'],
  //     characteristics: eventData['characteristics'],
  //   );
  // }

  // Map<String, dynamic> _getRaceEventData(int round) {
  //   final List<Map<String, dynamic>> raceEvents = [
  //     {
  //       'id': 'bahrain',
  //       'name': 'جائزة البحرين الكبرى',
  //       'country': 'البحرين',
  //       'city': 'الصخير',
  //       'circuitName': 'حلبة البحرين الدولية',
  //       'totalLaps': 57,
  //       'circuitLength': 5412,
  //       'lapRecord': 91,
  //       'baseWeather': WeatherType.dry,
  //       'difficulty': 1.2,
  //       'characteristics': ['سرعات عالية', 'كبح قوي', 'استهلاك إطارات'],
  //     },
  //     {
  //       'id': 'jeddah',
  //       'name': 'جائزة السعودية الكبرى',
  //       'country': 'السعودية',
  //       'city': 'جدة',
  //       'circuitName': 'حلبة كورنيش جدة',
  //       'totalLaps': 50,
  //       'circuitLength': 6174,
  //       'lapRecord': 104,
  //       'baseWeather': WeatherType.dry,
  //       'difficulty': 1.8,
  //       'characteristics': ['شارع سريع', 'جدران قريبة', 'تحدي عالي'],
  //     },
  //     {
  //       'id': 'melbourne',
  //       'name': 'جائزة أستراليا الكبرى',
  //       'country': 'أستراليا',
  //       'city': 'ملبورن',
  //       'circuitName': 'حلبة ألبرت بارك',
  //       'totalLaps': 58,
  //       'circuitLength': 5278,
  //       'lapRecord': 78,
  //       'baseWeather': WeatherType.changeable,
  //       'difficulty': 1.4,
  //       'characteristics': ['شارع سريع', 'منعطفات متوسطة', 'طقس متغير'],
  //     },
  //     {
  //       'id': 'imola',
  //       'name': 'جائزة إيميليا رومانيا الكبرى',
  //       'country': 'إيطاليا',
  //       'city': 'إيمولا',
  //       'circuitName': 'حلبة إنزو و دينو فيراري',
  //       'totalLaps': 63,
  //       'circuitLength': 4909,
  //       'lapRecord': 76,
  //       'baseWeather': WeatherType.changeable,
  //       'difficulty': 1.6,
  //       'characteristics': ['منعطفات سريعة', 'ديناميكا هوائية', 'تحدي تقني'],
  //     },
  //     {
  //       'id': 'monaco',
  //       'name': 'جائزة موناكو الكبرى',
  //       'country': 'موناكو',
  //       'city': 'مونت كارلو',
  //       'circuitName': 'حلبة مونت كارلو',
  //       'totalLaps': 78,
  //       'circuitLength': 3337,
  //       'lapRecord': 71,
  //       'baseWeather': WeatherType.dry,
  //       'difficulty': 2.0,
  //       'characteristics': ['شارع ضيق', 'دقة عالية', 'لا مجال للخطأ'],
  //     },
  //   ];

  //   final eventIndex = (round - 1) % raceEvents.length;
  //   return raceEvents[eventIndex];
  // }

  Widget _buildActionList(BuildContext context, SaveManager saveManager) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
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
        ),
      ],
    );
  }

  Widget _buildActionItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    IconData trailingIcon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      color: const Color(0xFF1D1E33),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(trailingIcon, color: Colors.white70, size: 16),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.build, color: Colors.green),
            SizedBox(width: 8),
            Text('تطوير السيارة', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'هنا يمكنك تطوير أجزاء السيارة المختلفة لتحسين أداء الفريق',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showSeasonStats(BuildContext context, SaveManager saveManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.orange),
            SizedBox(width: 8),
            Text('إحصائيات الموسم', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatItem('الموسم الحالي', '${saveManager.currentSeason}'),
            _buildStatItem(
              'السباقات المكتملة',
              '${saveManager.currentRace - 1}/${AppConstants.racesPerSeason}',
            ),
            _buildStatItem(
              'إجمالي النقاط',
              '${saveManager.playerTeam?.points ?? 0}',
            ),
            _buildStatItem(
              'السباقات الفائزة',
              '${saveManager.playerTeam?.racesWon ?? 0}',
            ),
            _buildStatItem(
              'الميزانية',
              Helpers.formatCurrency(saveManager.playerTeam?.budget ?? 0),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
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

  void _showRaceResults(BuildContext context, SaveManager saveManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.flag, color: Colors.purple),
            SizedBox(width: 8),
            Text('نتائج السباقات', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: saveManager.raceResults.isEmpty
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag_outlined, color: Colors.white70, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'لا توجد نتائج حتى الآن',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: saveManager.raceResults.length,
                  itemBuilder: (context, index) {
                    final result = saveManager.raceResults[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _getPositionColor(
                              result.finalPosition,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(18),
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
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'النقاط: ${result.pointsEarned}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          _getPositionText(result.finalPosition),
                          style: TextStyle(
                            color: _getPositionColor(result.finalPosition),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('إغلاق'),
          ),
        ],
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
