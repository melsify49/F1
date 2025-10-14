enum TireType { soft, medium, hard, wet }

enum AggressionLevel { conservative, balanced, aggressive }

enum WeatherType { dry, wet, changeable }

class RaceStrategy {
  TireType tireChoice;
  int pitStopLap;
  AggressionLevel aggression;
  bool weatherAdjustment;
  int fuelLoad;
  int brakeBalance;

  RaceStrategy({
    this.tireChoice = TireType.medium,
    this.pitStopLap = 20,
    this.aggression = AggressionLevel.balanced,
    this.weatherAdjustment = false,
    this.fuelLoad = 100,
    this.brakeBalance = 0,
  });

  double calculateStrategyScore(WeatherType weather) {
    double score = 0.0;

    // نقاط الإطارات والطقس
    switch (tireChoice) {
      case TireType.soft:
        score += 80;
        if (weather == WeatherType.wet) score -= 30;
        break;
      case TireType.medium:
        score += 70;
        break;
      case TireType.hard:
        score += 60;
        break;
      case TireType.wet:
        score += 50;
        if (weather == WeatherType.dry) score -= 40;
        break;
    }

    // نقاط Pit Stop
    if (pitStopLap >= 15 && pitStopLap <= 25) {
      score += 20;
    } else if (pitStopLap >= 10 && pitStopLap <= 30) {
      score += 10;
    } else {
      score += 5;
    }

    // نقاط العدوانية
    switch (aggression) {
      case AggressionLevel.conservative:
        score += 15;
        break;
      case AggressionLevel.balanced:
        score += 25;
        break;
      case AggressionLevel.aggressive:
        score += 35;
        break;
    }

    // نقاط تعديل الطقس
    if (weatherAdjustment && weather == WeatherType.changeable) {
      score += 20;
    }

    return score;
  }

  String get tireName {
    switch (tireChoice) {
      case TireType.soft:
        return "ناعمة";
      case TireType.medium:
        return "متوسطة";
      case TireType.hard:
        return "صلبة";
      case TireType.wet:
        return "مطر";
    }
  }

  String get aggressionName {
    switch (aggression) {
      case AggressionLevel.conservative:
        return "محافظ";
      case AggressionLevel.balanced:
        return "متوازن";
      case AggressionLevel.aggressive:
        return "عدواني";
    }
  }

  RaceStrategy copyWith({
    TireType? tireChoice,
    int? pitStopLap,
    AggressionLevel? aggression,
    bool? weatherAdjustment,
    int? fuelLoad,
    int? brakeBalance,
  }) {
    return RaceStrategy(
      tireChoice: tireChoice ?? this.tireChoice,
      pitStopLap: pitStopLap ?? this.pitStopLap,
      aggression: aggression ?? this.aggression,
      weatherAdjustment: weatherAdjustment ?? this.weatherAdjustment,
      fuelLoad: fuelLoad ?? this.fuelLoad,
      brakeBalance: brakeBalance ?? this.brakeBalance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tireChoice': tireChoice.index,
      'pitStopLap': pitStopLap,
      'aggression': aggression.index,
      'weatherAdjustment': weatherAdjustment,
      'fuelLoad': fuelLoad,
      'brakeBalance': brakeBalance,
    };
  }

  factory RaceStrategy.fromJson(Map<String, dynamic> json) {
    return RaceStrategy(
      tireChoice: TireType.values[json['tireChoice']],
      pitStopLap: json['pitStopLap'],
      aggression: AggressionLevel.values[json['aggression']],
      weatherAdjustment: json['weatherAdjustment'],
      fuelLoad: json['fuelLoad'],
      brakeBalance: json['brakeBalance'],
    );
  }
}
