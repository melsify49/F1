// [file name]: championship.dart
// [file content begin]
import 'dart:math';

import 'package:myapp/models/race_result.dart';
import 'package:myapp/models/team.dart';

class Championship {
  final int season;
  final Map<String, DriverStandings> driverStandings;
  final Map<String, TeamStandings> teamStandings;
  final List<RaceResult> raceResults;
  final DateTime startDate;
  DateTime? endDate;

  Championship({
    required this.season,
    required this.startDate,
    this.endDate,
    Map<String, DriverStandings>? driverStandings,
    Map<String, TeamStandings>? teamStandings,
    List<RaceResult>? raceResults,
  }) : driverStandings = driverStandings ?? {},
       teamStandings = teamStandings ?? {},
       raceResults = raceResults ?? [];

  void updateStandings(RaceResult result, List<Team> allTeams) {
    // تحديث ترتيب جميع السائقين من جميع الفرق
    _updateAllDriverStandings(result, allTeams);

    // تحديث ترتيب جميع الفرق
    _updateAllTeamStandings(result, allTeams);

    // إضافة نتيجة السباق
    raceResults.add(result);
  }

  void _updateAllDriverStandings(RaceResult result, List<Team> allTeams) {
    // محاكاة نتائج جميع السائقين من جميع الفرق
    for (final team in allTeams) {
      if (team.id == result.teamId) {
        // فريق اللاعب - استخدم النتائج الفعلية
        _updateDriverPoints(
          '${team.id}_driver1',
          result.driver1Name,
          team.id,
          result.driver1Position,
        );
        _updateDriverPoints(
          '${team.id}_driver2',
          result.driver2Name,
          team.id,
          result.driver2Position,
        );
      } else {
        // فرق الـ AI - محاكاة نتائج عشوائية واقعية
        _updateAIDriverStandings(team, result);
      }
    }

    // إعادة حساب المراكز
    recalculateDriverPositions();
  }

  void _updateAllTeamStandings(RaceResult result, List<Team> allTeams) {
    // محاكاة نتائج جميع الفرق
    for (final team in allTeams) {
      if (team.id == result.teamId) {
        // فريق اللاعب - استخدم النتائج الفعلية
        final teamPoints = result.pointsEarned;
        teamStandings[team.id] = TeamStandings(
          teamId: team.id,
          teamName: team.name,
          points: (teamStandings[team.id]?.points ?? 0) + teamPoints,
          position: 0,
          wins:
              (teamStandings[team.id]?.wins ?? 0) +
              (result.finalPosition == 1 ? 1 : 0),
          podiums:
              (teamStandings[team.id]?.podiums ?? 0) +
              (result.finalPosition <= 3 ? 1 : 0),
        );
      } else {
        // فرق الـ AI - محاكاة نتائج عشوائية
        _updateAITeamStandings(team, result);
      }
    }

    // إعادة حساب مراكز الفرق
    recalculateTeamPositions();
  }

  void _updateDriverPoints(
    String driverId,
    String driverName,
    String teamId,
    int position,
  ) {
    final points = _calculatePoints(position);
    if (points > 0) {
      driverStandings[driverId] = DriverStandings(
        driverId: driverId,
        driverName: driverName,
        teamId: teamId,
        points: (driverStandings[driverId]?.points ?? 0) + points,
        position: 0,
        wins: (driverStandings[driverId]?.wins ?? 0) + (position == 1 ? 1 : 0),
        podiums:
            (driverStandings[driverId]?.podiums ?? 0) + (position <= 3 ? 1 : 0),
      );
    } else {
      // تأكد من وجود السائق في الترتيب حتى لو لم يحصل على نقاط
      driverStandings[driverId] = DriverStandings(
        driverId: driverId,
        driverName: driverName,
        teamId: teamId,
        points: driverStandings[driverId]?.points ?? 0,
        position: 0,
        wins: driverStandings[driverId]?.wins ?? 0,
        podiums: driverStandings[driverId]?.podiums ?? 0,
      );
    }
  }

  void _updateAIDriverStandings(Team aiTeam, RaceResult playerResult) {
    // محاكاة نتائج واقعية لسائقي الـ AI بناءً على قوة الفريق
    final teamStrength = aiTeam.overallPerformance / 100.0;
    final random = _getRealisticAIPosition(teamStrength);

    final driver1Position = random;
    final driver2Position = _getTeammatePosition(driver1Position, teamStrength);

    _updateDriverPoints(
      '${aiTeam.id}_driver1',
      aiTeam.driver1.name,
      aiTeam.id,
      driver1Position,
    );

    _updateDriverPoints(
      '${aiTeam.id}_driver2',
      aiTeam.driver2.name,
      aiTeam.id,
      driver2Position,
    );
  }

  void _updateAITeamStandings(Team aiTeam, RaceResult playerResult) {
    final teamStrength = aiTeam.overallPerformance / 100.0;
    final random = _getRealisticAIPosition(teamStrength);

    final teamPosition = random;
    final teamPoints = _calculatePoints(teamPosition);

    teamStandings[aiTeam.id] = TeamStandings(
      teamId: aiTeam.id,
      teamName: aiTeam.name,
      points: (teamStandings[aiTeam.id]?.points ?? 0) + teamPoints,
      position: 0,
      wins: (teamStandings[aiTeam.id]?.wins ?? 0) + (teamPosition == 1 ? 1 : 0),
      podiums:
          (teamStandings[aiTeam.id]?.podiums ?? 0) +
          (teamPosition <= 3 ? 1 : 0),
    );
  }

  int _getRealisticAIPosition(double teamStrength) {
    // محاكاة واقعية للمراكز بناءً على قوة الفريق
    final random = Random();

    if (teamStrength >= 0.9) {
      // فرق قوية (ريد بول، فيراري، مرسيدس)
      return random.nextInt(5) + 1; // مراكز 1-5
    } else if (teamStrength >= 0.8) {
      // فرق متوسطة (ماكلارين، أستون مارتن)
      return random.nextInt(8) + 3; // مراكز 3-10
    } else if (teamStrength >= 0.7) {
      // فرق ضعيفة (ألبين، هاس)
      return random.nextInt(7) + 8; // مراكز 8-14
    } else {
      // فرق ضعيفة جداً (ويليامز، ساوبر)
      return random.nextInt(6) + 12; // مراكز 12-17
    }
  }

  int _getTeammatePosition(int firstDriverPosition, double teamStrength) {
    final random = Random();
    int difference;
    
    if (teamStrength >= 0.85) {
      difference = random.nextInt(3) + 1; // فرق صغير بين السائقين
    } else {
      difference = random.nextInt(5) + 1; // فرق أكبر
    }
    
    return (firstDriverPosition + difference).clamp(1, 20);
  }

  // دوال عامة لإعادة حساب المراكز
  void recalculateDriverPositions() {
    final sortedDrivers = driverStandings.values.toList()
      ..sort((a, b) => b.points.compareTo(a.points));
    
    for (int i = 0; i < sortedDrivers.length; i++) {
      final driverId = sortedDrivers[i].driverId;
      driverStandings[driverId] = driverStandings[driverId]!.copyWith(position: i + 1);
    }
  }


  // دوال عامة لإعادة حساب المراكز
  // void recalculateDriverPositions() {
  //   final sortedDrivers = driverStandings.values.toList()
  //     ..sort((a, b) => b.points.compareTo(a.points));

  //   for (int i = 0; i < sortedDrivers.length; i++) {
  //     final driverId = sortedDrivers[i].driverId;
  //     driverStandings[driverId] = driverStandings[driverId]!.copyWith(
  //       position: i + 1,
  //     );
  //   }
  // }

  void recalculateTeamPositions() {
    final sortedTeams = teamStandings.values.toList()
      ..sort((a, b) => b.points.compareTo(a.points));
    
    for (int i = 0; i < sortedTeams.length; i++) {
      final teamId = sortedTeams[i].teamId;
      teamStandings[teamId] = teamStandings[teamId]!.copyWith(position: i + 1);
    }
  }

  // دوال مساعدة لإضافة جميع السائقين والفرق
  void updateAllDriverStandings(List<Map<String, dynamic>> allDrivers) {
    for (final driver in allDrivers) {
      if (!driverStandings.containsKey(driver['driverId'])) {
        driverStandings[driver['driverId']] = DriverStandings(
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
    recalculateDriverPositions();
  }
  // دوال مساعدة لإضافة جميع السائقين والفرق
  void initializeAllDriverStandings(List<Map<String, dynamic>> allDrivers) {
    for (final driver in allDrivers) {
      if (!driverStandings.containsKey(driver['driverId'])) {
        driverStandings[driver['driverId']] = DriverStandings(
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
    recalculateDriverPositions();
  }

  void initializeAllTeamStandings(List<Team> allTeams) {
    for (final team in allTeams) {
      if (!teamStandings.containsKey(team.id)) {
        teamStandings[team.id] = TeamStandings(
          teamId: team.id,
          teamName: team.name,
          points: 0,
          position: 0,
          wins: 0,
          podiums: 0,
        );
      }
    }
    recalculateTeamPositions();
  }

  void updateAllTeamStandings(List<Team> allTeams) {
    for (final team in allTeams) {
      if (!teamStandings.containsKey(team.id)) {
        teamStandings[team.id] = TeamStandings(
          teamId: team.id,
          teamName: team.name,
          points: 0,
          position: 0,
          wins: 0,
          podiums: 0,
        );
      }
    }
    recalculateTeamPositions();
  }

  int _calculatePoints(int position) {
    const pointsSystem = {
      1: 25,
      2: 18,
      3: 15,
      4: 12,
      5: 10,
      6: 8,
      7: 6,
      8: 4,
      9: 2,
      10: 1,
    };
    return pointsSystem[position] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'season': season,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'driverStandings': driverStandings.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'teamStandings': teamStandings.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'raceResults': raceResults.map((result) => result.toJson()).toList(),
    };
  }

  factory Championship.fromJson(Map<String, dynamic> json) {
    return Championship(
      season: json['season'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      driverStandings: (json['driverStandings'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, DriverStandings.fromJson(value)),
      ),
      teamStandings: (json['teamStandings'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, TeamStandings.fromJson(value)),
      ),
      raceResults: (json['raceResults'] as List)
          .map((result) => RaceResult.fromJson(result))
          .toList(),
    );
  }
}

class DriverStandings {
  final String driverId;
  final String driverName;
  final String teamId;
  final int points;
  final int position;
  final int wins;
  final int podiums;

  DriverStandings({
    required this.driverId,
    required this.driverName,
    required this.teamId,
    required this.points,
    required this.position,
    required this.wins,
    required this.podiums,
  });

  DriverStandings copyWith({
    int? points,
    int? position,
    int? wins,
    int? podiums,
  }) {
    return DriverStandings(
      driverId: driverId,
      driverName: driverName,
      teamId: teamId,
      points: points ?? this.points,
      position: position ?? this.position,
      wins: wins ?? this.wins,
      podiums: podiums ?? this.podiums,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'teamId': teamId,
      'points': points,
      'position': position,
      'wins': wins,
      'podiums': podiums,
    };
  }

  factory DriverStandings.fromJson(Map<String, dynamic> json) {
    return DriverStandings(
      driverId: json['driverId'],
      driverName: json['driverName'],
      teamId: json['teamId'],
      points: json['points'],
      position: json['position'],
      wins: json['wins'],
      podiums: json['podiums'],
    );
  }
}

class TeamStandings {
  final String teamId;
  final String teamName;
  final int points;
  final int position;
  final int wins;
  final int podiums;

  TeamStandings({
    required this.teamId,
    required this.teamName,
    required this.points,
    required this.position,
    required this.wins,
    required this.podiums,
  });

  TeamStandings copyWith({
    int? points,
    int? position,
    int? wins,
    int? podiums,
  }) {
    return TeamStandings(
      teamId: teamId,
      teamName: teamName,
      points: points ?? this.points,
      position: position ?? this.position,
      wins: wins ?? this.wins,
      podiums: podiums ?? this.podiums,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'points': points,
      'position': position,
      'wins': wins,
      'podiums': podiums,
    };
  }

  factory TeamStandings.fromJson(Map<String, dynamic> json) {
    return TeamStandings(
      teamId: json['teamId'],
      teamName: json['teamName'],
      points: json['points'],
      position: json['position'],
      wins: json['wins'],
      podiums: json['podiums'],
    );
  }
}
// [file content end]