import 'package:flutter/material.dart';
import 'package:myapp/models/race_event.dart';
import 'package:myapp/pages/race_page.dart';
import 'package:myapp/services/save_manager.dart';
import 'package:myapp/utils/season_calendar.dart';
import 'package:provider/provider.dart';

class SeasonOverviewScreen extends StatelessWidget {
  const SeasonOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saveManager = Provider.of<SaveManager>(context);
    final team = saveManager.playerTeam!;
    final races = SeasonCalendar.getSeasonRaces();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text('موسم ${DateTime.now().year} - ${team.name}'),
        backgroundColor: const Color(0xFF1D1E33),
      ),
      body: Column(
        children: [
          // معلومات الفريق
          Card(
            color: const Color(0xFF1D1E33),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(team.name, style: TextStyle(color: Colors.white, fontSize: 20)),
                        Text('${team.country} • ${team.teamTier}', style: TextStyle(color: Colors.white70)),
                        Text('النقاط: ${team.points}', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // قائمة السباقات
          Expanded(
            child: ListView.builder(
              itemCount: races.length,
              itemBuilder: (context, index) {
                final race = races[index];
                return _buildRaceCard(race, index + 1, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaceCard(RaceEvent race, int round, BuildContext context) {
    return Card(
      color: const Color(0xFF1D1E33),
      child: ListTile(
        leading: CircleAvatar(child: Text('$round')),
        title: Text(race.name, style: TextStyle(color: Colors.white)),
        subtitle: Text('${race.circuitName} - ${race.difficultyLevel}', style: TextStyle(color: Colors.white70)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RacePage(
                raceEvent: race,
                round: round,
              ),
            ),
          );
        },
      ),
    );
  }
}