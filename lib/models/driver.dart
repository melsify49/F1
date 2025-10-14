// driver.dart
class Driver {
  final String id;
  final String name;
  final String nationality;
  final int age;
  
  // المهارات (0-100)
  final double speed;
  final double consistency;
  final double overtaking;
  final double defense;
  final double wetWeather;
  final double experience;
  
  // الإحصائيات
  int racesWon = 0;
  int podiums = 0;
  int points = 0;
  double salary;

  Driver({
    required this.id,
    required this.name,
    required this.nationality,
    required this.age,
    required this.speed,
    required this.consistency,
    required this.overtaking,
    required this.defense,
    required this.wetWeather,
    required this.experience,
    required this.salary,
  });

  double get overallRating {
    return (speed * 0.25 +
            consistency * 0.20 +
            overtaking * 0.15 +
            defense * 0.15 +
            wetWeather * 0.10 +
            experience * 0.15);
  }

  String get skillLevel {
    final rating = overallRating;
    if (rating >= 90) return 'أسطوري 🏆';
    if (rating >= 80) return 'خبير 💎';
    if (rating >= 70) return 'محترف ⭐';
    if (rating >= 60) return 'جيد 👍';
    return 'مبتدىء 🔰';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nationality': nationality,
      'age': age,
      'speed': speed,
      'consistency': consistency,
      'overtaking': overtaking,
      'defense': defense,
      'wetWeather': wetWeather,
      'experience': experience,
      'racesWon': racesWon,
      'podiums': podiums,
      'points': points,
      'salary': salary,
      'overallRating': overallRating,
      'skillLevel': skillLevel,
    };
  }

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      nationality: json['nationality'],
      age: json['age'],
      speed: json['speed'].toDouble(),
      consistency: json['consistency'].toDouble(),
      overtaking: json['overtaking'].toDouble(),
      defense: json['defense'].toDouble(),
      wetWeather: json['wetWeather'].toDouble(),
      experience: json['experience'].toDouble(),
      salary: json['salary'].toDouble(),
    )..racesWon = json['racesWon']
     ..podiums = json['podiums']
     ..points = json['points'];
  }
}