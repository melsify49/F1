// [file name]: championship_page.dart
// [file content begin]
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/championship.dart';
import '../services/save_manager.dart';
import '../models/team.dart';
// import '../services/team_manager.dart';
import '../utils/team_manager.dart';

class ChampionshipPage extends StatelessWidget {
  const ChampionshipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final saveManager = Provider.of<SaveManager>(context);
    final championship = saveManager.currentChampionship;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'بطولة الموسم',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF1D1E33),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF0A0E21),
      body: championship == null
          ? _buildNoChampionship()
          : _buildChampionshipView(championship, saveManager),
    );
  }

  Widget _buildNoChampionship() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 64, color: Colors.amber),
          SizedBox(height: 16),
          Text(
            'لا توجد بطولة نشطة',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildChampionshipView(Championship championship, SaveManager saveManager) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF1D1E33),
            child: TabBar(
              indicatorColor: const Color(0xFFDC0000),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'ترتيب السائقين'),
                Tab(text: 'ترتيب الفرق'),
                Tab(text: 'نتائج السباقات'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDriverStandings(championship, saveManager),
                _buildTeamStandings(championship, saveManager),
                _buildRaceResults(championship, saveManager),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStandings(Championship championship, SaveManager saveManager) {
  // الحصول على جميع السائقين من جميع الفرق
  final allDrivers = _getAllDrivers(saveManager);
  
  // تهيئة جميع السائقين إذا كانوا غير موجودين
  championship.initializeAllDriverStandings(allDrivers);
  
  final sortedDrivers = championship.driverStandings.values.toList()
    ..sort((a, b) => a.position.compareTo(b.position));

  return Column(
    children: [
      // رأس الجدول
      _buildStandingsHeader(['المركز', 'السائق', 'الفريق', 'النقاط', 'انتصارات']),
      Expanded(
        child: sortedDrivers.isEmpty 
            ? _buildEmptyState('لا توجد بيانات للسائقين بعد')
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedDrivers.length,
                itemBuilder: (context, index) {
                  final driver = sortedDrivers[index];
                  return _buildDriverStandingItem(driver, index + 1);
                },
              ),
      ),
    ],
  );
}

  Widget _buildTeamStandings(Championship championship, SaveManager saveManager) {
  // الحصول على جميع الفرق
  final allTeams = _getAllTeams(saveManager);
  
  // تهيئة جميع الفرق إذا كانت غير موجودة
  championship.initializeAllTeamStandings(allTeams);
  
  final sortedTeams = championship.teamStandings.values.toList()
    ..sort((a, b) => a.position.compareTo(b.position));

  return Column(
    children: [
      // رأس الجدول
      _buildStandingsHeader(['المركز', 'الفريق', 'النقاط', 'انتصارات', 'منصات']),
      Expanded(
        child: sortedTeams.isEmpty 
            ? _buildEmptyState('لا توجد بيانات للفرق بعد')
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedTeams.length,
                itemBuilder: (context, index) {
                  final team = sortedTeams[index];
                  return _buildTeamStandingItem(team, index + 1);
                },
              ),
      ),
    ],
  );
}

// أضف دالة للعرض عندما لا توجد بيانات
Widget _buildEmptyState(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline, size: 48, color: Colors.white.withOpacity(0.5)),
        const SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildRaceResults(Championship championship, SaveManager saveManager) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: championship.raceResults.length,
      itemBuilder: (context, index) {
        final result = championship.raceResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: const Color(0xFF1D1E33),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC0000),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        result.raceName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDriverResultChip(result.driver1Name, result.driver1Position),
                    _buildDriverResultChip(result.driver2Name, result.driver2Position),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Text(
                        '${result.pointsEarned} نقطة',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // دوال مساعدة جديدة
  List<Map<String, dynamic>> _getAllDrivers(SaveManager saveManager) {
    final allTeams = _getAllTeams(saveManager);
    List<Map<String, dynamic>> allDrivers = [];

    for (final team in allTeams) {
      allDrivers.add({
        'driverId': '${team.id}_driver1',
        'driverName': team.driver1.name,
        'teamId': team.id,
        'teamName': team.name,
      });
      allDrivers.add({
        'driverId': '${team.id}_driver2',
        'driverName': team.driver2.name,
        'teamId': team.id,
        'teamName': team.name,
      });
    }

    return allDrivers;
  }

  List<Team> _getAllTeams(SaveManager saveManager) {
    final playerTeam = saveManager.playerTeam;
    final presetTeams = TeamManager.getPresetTeams();
    
    // دمج فريق اللاعب مع الفرق المسبقة
    final allTeams = <Team>[];
    
    if (playerTeam != null) {
      allTeams.add(playerTeam);
    }
    
    // إضافة الفرق المسبقة مع تجنب التكرار
    for (final presetTeam in presetTeams) {
      if (playerTeam == null || presetTeam.id != playerTeam.id) {
        allTeams.add(presetTeam);
      }
    }
    
    return allTeams;
  }

  void _updateDriverStandingsWithAllDrivers(Championship championship, List<Map<String, dynamic>> allDrivers) {
    // التأكد من وجود جميع السائقين في الترتيب
    for (final driver in allDrivers) {
      if (!championship.driverStandings.containsKey(driver['driverId'])) {
        championship.driverStandings[driver['driverId']] = DriverStandings(
          driverId: driver['driverId'],
          driverName: driver['driverName'],
          teamId: driver['teamId'],
          points: 0,
          position: 0,
          wins: 0,
          podiums: 0,
        );
      }
    }
    
    // إعادة حساب المراكز
    championship.recalculateDriverPositions();
  }

  void _updateTeamStandingsWithAllTeams(Championship championship, List<Team> allTeams) {
    // التأكد من وجود جميع الفرق في الترتيب
    for (final team in allTeams) {
      if (!championship.teamStandings.containsKey(team.id)) {
        championship.teamStandings[team.id] = TeamStandings(
          teamId: team.id,
          teamName: team.name,
          points: 0,
          position: 0,
          wins: 0,
          podiums: 0,
        );
      }
    }
    
    // إعادة حساب المراكز
    championship.recalculateTeamPositions();
  }

  Widget _buildStandingsHeader(List<String> headers) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: headers.map((header) {
          final flex = header == 'السائق' || header == 'الفريق' ? 3 : 2;
          return Expanded(
            flex: flex,
            child: Text(
              header,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDriverStandingItem(DriverStandings driver, int index) {
    final isPlayer = driver.teamId == 'player_team';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isPlayer ? const Color(0xFFDC0000).withOpacity(0.2) : const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // المركز
          Expanded(
            flex: 2,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _getPositionColor(driver.position),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '${driver.position}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          
          // اسم السائق
          Expanded(
            flex: 3,
            child: Text(
              driver.driverName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // الفريق
          Expanded(
            flex: 2,
            child: Text(
              _getTeamName(driver.teamId),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // النقاط
          Expanded(
            flex: 2,
            child: Text(
              '${driver.points}',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // الانتصارات
          Expanded(
            flex: 2,
            child: Text(
              '${driver.wins}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStandingItem(TeamStandings team, int index) {
    final isPlayer = team.teamId == 'player_team';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isPlayer ? const Color(0xFFDC0000).withOpacity(0.2) : const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // المركز
          Expanded(
            flex: 2,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _getPositionColor(team.position),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '${team.position}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          
          // اسم الفريق
          Expanded(
            flex: 3,
            child: Text(
              team.teamName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // النقاط
          Expanded(
            flex: 2,
            child: Text(
              '${team.points}',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // الانتصارات
          Expanded(
            flex: 2,
            child: Text(
              '${team.wins}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // المنصات
          Expanded(
            flex: 2,
            child: Text(
              '${team.podiums}',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverResultChip(String driverName, int position) {
    return Column(
      children: [
        Text(
          driverName.split(' ').last, // عرض الاسم الأخير فقط
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getPositionColor(position).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getPositionColor(position)),
          ),
          child: Text(
            _getPositionText(position),
            style: TextStyle(
              color: _getPositionColor(position),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getTeamName(String teamId) {
    final presetTeams = TeamManager.getPresetTeams();
    final team = presetTeams.firstWhere((team) => team.id == teamId, orElse: () => TeamManager.getPresetTeams().first);
    return team.name;
  }

  String _getPositionText(int position) {
    switch (position) {
      case 1: return '1st';
      case 2: return '2nd';
      case 3: return '3rd';
      default: return '${position}th';
    }
  }

  Color _getPositionColor(int position) {
    if (position == 1) return Colors.amber;
    if (position <= 3) return Colors.green;
    if (position <= 10) return Colors.blue;
    return Colors.grey;
  }
}
// [file content end]