// team_page.dart - تصميم محسن
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../services/save_manager.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/team_manager.dart';
import 'career_page.dart';
// import 'season_overview_screen.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار الفريق'),
        backgroundColor: AppConstants.secondaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 24,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(isSmallScreen),
              const SizedBox(height: 24),

              // Teams List
              Expanded(
                child: _buildTeamsList(isSmallScreen),
              ),

              // Start Button
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر فريقك:',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 20 : 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'اختر الفريق الذي تريد بدء مسيرتك المهنية معه',
          style: TextStyle(
            color: Colors.white70,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamsList(bool isSmallScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 600 ? 2 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: constraints.maxWidth > 600 ? 1.8 : 2.2,
          ),
          itemCount: TeamManager.getPresetTeams().length,
          itemBuilder: (context, index) {
            final team = TeamManager.getPresetTeams()[index];
            return _buildTeamCard(team, context, isSmallScreen);
          },
        );
      },
    );
  }

  Widget _buildTeamCard(Team team, BuildContext context, bool isSmallScreen) {
    final isSelected = _selectedTeamId == team.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [const Color(0xFFDC0000), const Color(0xFF850000)]
              : [const Color(0xFF1D1E33), const Color(0xFF0A0E21)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFFDC0000).withOpacity(0.4)
                : Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isSelected
              ? const Color(0xFFDC0000)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTeamId = team.id;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team Header
                Row(
                  children: [
                    Container(
                      width: isSmallScreen ? 40 : 50,
                      height: isSmallScreen ? 40 : 50,
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
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          team.name[0],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 16 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 16 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            team.country,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Team Stats
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 3,
                    children: [
                      _buildTeamStat(
                        'الميزانية',
                        Helpers.formatCurrency(team.budget),
                        Icons.account_balance_wallet,
                        Colors.green,
                        isSmallScreen,
                      ),
                      _buildTeamStat(
                        'الأداء',
                        '${team.overallPerformance.toStringAsFixed(1)}%',
                        Icons.rocket_launch,
                        Colors.blue,
                        isSmallScreen,
                      ),
                      _buildTeamStat(
                        'السمعة',
                        '${team.reputation}',
                        Icons.star,
                        Colors.amber,
                        isSmallScreen,
                      ),
                      _buildTeamStat(
                        'المستوى',
                        team.teamTier,
                        Icons.leaderboard,
                        _getTierColor(team.teamTier),
                        isSmallScreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamStat(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(icon, color: color, size: isSmallScreen ? 14 : 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 10 : 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: _selectedTeamId != null ? _startCareer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedTeamId != null
              ? const Color(0xFFDC0000)
              : Colors.grey[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFFDC0000).withOpacity(0.3),
        ),
        child: Text(
          'بدء المسيرة المهنية',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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