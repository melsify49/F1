import 'driver.dart';

class Team {
  final String id;
  final String name;
  final String country;
  final int foundingYear;
  
  // موارد الفريق
  double budget;
  double carPerformance;
  double enginePower;
  double aerodynamics;
  double reliability;
  
  // الطموحات والمتطلبات
  final int championshipTarget;
  final int budgetTarget;
  final int developmentFocus;
  
  // السائقين
  Driver driver1;
  Driver driver2;
  
  // الإحصائيات (من النظام القديم + الجديد)
  int points = 0;
  int racesWon = 0;
  int constructorsChampionships = 0;
  int reputation;

  // نظام الترقيات (من النظام القديم)
  Map<String, int> upgrades;

  Team({
    required this.id,
    required this.name,
    required this.country,
    required this.foundingYear,
    required this.budget,
    required this.carPerformance,
    required this.enginePower,
    required this.aerodynamics,
    required this.reliability,
    required this.championshipTarget,
    required this.budgetTarget,
    required this.developmentFocus,
    required this.driver1,
    required this.driver2,
    required this.reputation,
    Map<String, int>? upgrades,
  }) : upgrades = upgrades ?? {
          'engine': 1, 
          'chassis': 1, 
          'aero': 1, 
          'reliability': 1,
          'electronics': 1,
        };

  // من النظام القديم - ترقية السيارة
  bool upgradeCar(String part, int cost, double performanceBoost) {
    if (budget >= cost && upgrades[part]! < 5) {
      budget -= cost;
      upgrades[part] = upgrades[part]! + 1;
      
      // تطبيق تأثير الترقية على الإحصائيات المناسبة
      switch (part) {
        case 'engine':
          enginePower += performanceBoost;
          carPerformance += performanceBoost * 0.7;
          break;
        case 'aero':
          aerodynamics += performanceBoost;
          carPerformance += performanceBoost * 0.8;
          break;
        case 'reliability':
          reliability += performanceBoost;
          break;
        case 'chassis':
          carPerformance += performanceBoost * 0.6;
          reliability += performanceBoost * 0.3;
          break;
        case 'electronics':
          carPerformance += performanceBoost * 0.4;
          reliability += performanceBoost * 0.2;
          break;
      }
      
      return true;
    }
    return false;
  }

  // دالة مساعدة للحصول على تكلفة الترقية
  int getUpgradeCost(String part) {
    final level = upgrades[part]!;
    switch (part) {
      case 'engine':
        return level * 5000000;
      case 'aero':
        return level * 4000000;
      case 'reliability':
        return level * 3000000;
      case 'chassis':
        return level * 3500000;
      case 'electronics':
        return level * 2500000;
      default:
        return level * 3000000;
    }
  }

  // دالة مساعدة للحصول على قيمة التعزيز
  double getUpgradeBoost(String part) {
    switch (part) {
      case 'engine':
        return 2.5;
      case 'aero':
        return 2.0;
      case 'reliability':
        return 1.8;
      case 'chassis':
        return 1.5;
      case 'electronics':
        return 1.2;
      default:
        return 1.0;
    }
  }

  // ترقية مبسطة - تستخدم التكلفة والتعزيز التلقائي
  bool upgrade(String part) {
    final cost = getUpgradeCost(part);
    final boost = getUpgradeBoost(part);
    return upgradeCar(part, cost, boost);
  }

  // الحصول على مستوى الترقية الحالي
  int getUpgradeLevel(String part) {
    return upgrades[part] ?? 1;
  }

  // الحصول على الحد الأقصى لمستوى الترقية
  int getMaxUpgradeLevel(String part) {
    return 5;
  }

  // هل يمكن ترقية جزء معين؟
  bool canUpgrade(String part) {
    return budget >= getUpgradeCost(part) && upgrades[part]! < getMaxUpgradeLevel(part);
  }

  // من النظام القديم
  double get overallPerformance {
    return (carPerformance * 0.4 +
            driver1.overallRating * 0.3 +
            driver2.overallRating * 0.3);
  }

  // الحصول على متوسط مهارة السائقين (للتوافق مع النظام القديم)
  double get driverSkill {
    return (driver1.overallRating + driver2.overallRating) / 2;
  }

  String get teamTier {
    final performance = overallPerformance;
    if (performance >= 85) return 'فريق مصنع 🏭';
    if (performance >= 70) return 'فريق منتصف 📊';
    return 'فريق صغير 🔰';
  }

  // الحصول على قائمة بجميع الترقيات المتاحة
  Map<String, Map<String, dynamic>> get availableUpgrades {
    return {
      'engine': {
        'name': 'المحرك',
        'level': upgrades['engine']!,
        'cost': getUpgradeCost('engine'),
        'boost': getUpgradeBoost('engine'),
        'canUpgrade': canUpgrade('engine'),
      },
      'aero': {
        'name': 'الديناميكا الهوائية',
        'level': upgrades['aero']!,
        'cost': getUpgradeCost('aero'),
        'boost': getUpgradeBoost('aero'),
        'canUpgrade': canUpgrade('aero'),
      },
      'reliability': {
        'name': 'الموثوقية',
        'level': upgrades['reliability']!,
        'cost': getUpgradeCost('reliability'),
        'boost': getUpgradeBoost('reliability'),
        'canUpgrade': canUpgrade('reliability'),
      },
      'chassis': {
        'name': 'الهيكل',
        'level': upgrades['chassis']!,
        'cost': getUpgradeCost('chassis'),
        'boost': getUpgradeBoost('chassis'),
        'canUpgrade': canUpgrade('chassis'),
      },
      'electronics': {
        'name': 'الإلكترونيات',
        'level': upgrades['electronics']!,
        'cost': getUpgradeCost('electronics'),
        'boost': getUpgradeBoost('electronics'),
        'canUpgrade': canUpgrade('electronics'),
      },
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'foundingYear': foundingYear,
      'budget': budget,
      'carPerformance': carPerformance,
      'enginePower': enginePower,
      'aerodynamics': aerodynamics,
      'reliability': reliability,
      'championshipTarget': championshipTarget,
      'budgetTarget': budgetTarget,
      'developmentFocus': developmentFocus,
      'driver1': driver1.toJson(),
      'driver2': driver2.toJson(),
      'points': points,
      'racesWon': racesWon,
      'constructorsChampionships': constructorsChampionships,
      'reputation': reputation,
      'upgrades': upgrades,
      'overallPerformance': overallPerformance,
      'teamTier': teamTier,
      'driverSkill': driverSkill,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      foundingYear: json['foundingYear'],
      budget: json['budget'].toDouble(),
      carPerformance: json['carPerformance'].toDouble(),
      enginePower: json['enginePower'].toDouble(),
      aerodynamics: json['aerodynamics'].toDouble(),
      reliability: json['reliability'].toDouble(),
      championshipTarget: json['championshipTarget'],
      budgetTarget: json['budgetTarget'],
      developmentFocus: json['developmentFocus'],
      driver1: Driver.fromJson(json['driver1']),
      driver2: Driver.fromJson(json['driver2']),
      reputation: json['reputation'],
      upgrades: Map<String, int>.from(json['upgrades']),
    )..points = json['points']
     ..racesWon = json['racesWon']
     ..constructorsChampionships = json['constructorsChampionships'];
  }
}