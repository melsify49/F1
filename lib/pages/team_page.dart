import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../services/save_manager.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/team_manager.dart';
import 'career_page.dart';
import 'season_overview_screen.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  String? _selectedTeamId;
  final TextEditingController _teamNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار الفريق'),
        backgroundColor: AppConstants.secondaryColor,
      ),
      backgroundColor: AppConstants.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اختر فريقك:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // قائمة الفريق
            Expanded(
              child: ListView.builder(
                itemCount: TeamManager.getPresetTeams().length,
                itemBuilder: (context, index) {
                  final team = TeamManager.getPresetTeams()[index];
                  return _buildTeamCard(team, context);
                },
              ),
            ),

            // زر البدء
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _selectedTeamId != null ? _startCareer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'بدء المسيرة',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(Team team, BuildContext context) {
    final isSelected = _selectedTeamId == team.id;

    return Card(
      color: const Color(0xFF1D1E33),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor,
          child: Text(
            team.name[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          team.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'البلد: ${team.country}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'الميزانية: ${Helpers.formatCurrency(team.budget)}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'الأداء: ${team.overallPerformance.toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'السمعة: ${team.reputation}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              '${team.teamTier}',
              style: TextStyle(
                color: _getTierColor(team.teamTier),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: () {
          setState(() {
            _selectedTeamId = team.id;
          });
        },
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

  void _startCareer() {
    if (_selectedTeamId == null) return;

    final selectedTeam = TeamManager.getPresetTeams().firstWhere(
      (team) => team.id == _selectedTeamId,
    );

    final saveManager = Provider.of<SaveManager>(context, listen: false);
    saveManager.newGame(selectedTeam);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CareerPage()),
    );
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }
}