import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team.dart';
import '../models/race_result.dart';

class SaveManager with ChangeNotifier {
  static const String _teamKey = 'player_team';
  static const String _resultsKey = 'race_results';
  static const String _seasonKey = 'current_season';
  static const String _raceKey = 'current_race';

  Team? _playerTeam;
  List<RaceResult> _raceResults = [];
  int _currentSeason = 1;
  int _currentRace = 1;
  late int _seasonYear = DateTime.now().year;

  Team? get playerTeam => _playerTeam;
  List<RaceResult> get raceResults => _raceResults;
  int get currentSeason => _currentSeason;
  int get currentRace => _currentRace;

  bool get hasSavedGame => _playerTeam != null;

  SaveManager() {
    _loadGame();
  }

  void selectTeam(Team team) {
    _playerTeam = team;
    _currentRace = 1;
    _raceResults.clear();
    notifyListeners();
  }

  Future<void> _loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final teamJson = prefs.getString(_teamKey);
      if (teamJson != null) {
        _playerTeam = Team.fromJson(json.decode(teamJson));
      }

      final resultsJson = prefs.getStringList(_resultsKey);
      if (resultsJson != null) {
        _raceResults = resultsJson
            .map((jsonStr) => RaceResult.fromJson(json.decode(jsonStr)))
            .toList();
      }

      _currentSeason = prefs.getInt(_seasonKey) ?? 1;
      _currentRace = prefs.getInt(_raceKey) ?? 1;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error loading data: $e");
      }
    }
  }

  void completeRace(RaceResult result) {
  _raceResults.add(result);
  _currentRace++; // الانتقال للسباق التالي
  
  // إذا انتهى الموسم، ابدأ موسماً جديداً
  if (_currentRace > AppConstants.racesPerSeason) {
    _currentSeason++;
    _currentRace = 1; // ✅ إعادة الضبط لبداية الموسم الجديد
    _raceResults.clear();
  }
  
  saveGame(team: _playerTeam!);
}

  Future<void> saveGame({required Team team, RaceResult? newResult}) async {
    final prefs = await SharedPreferences.getInstance();

    _playerTeam = team;
    if (newResult != null) {
      _raceResults.add(newResult);
    }

    if (_currentRace < 10) {
      _currentRace++;
    } else {
      _currentRace = 1;
      _seasonYear++;
    }

    await prefs.setString(_teamKey, json.encode(team.toJson()));
    await prefs.setStringList(
      _resultsKey,
      _raceResults
          .where((result) => result != null)
          .map((result) => json.encode(result.toJson()))
          .toList(),
    );
    await prefs.setInt(_seasonKey, _currentSeason);
    await prefs.setInt(_raceKey, _currentRace);

    notifyListeners();
  }

  Future<void> newGame(Team team) async {
   _playerTeam = team;
  _currentSeason = 1;
  _currentRace = 1; // ✅ يجب أن يبدأ من 1
  _raceResults.clear();

    await saveGame(team: team);
    notifyListeners();
  }
}
