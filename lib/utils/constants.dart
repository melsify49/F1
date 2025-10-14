import 'package:flutter/material.dart';

import '../models/race_strategy.dart';

class AppConstants {
  // ألوان التطبيق
  static const Color primaryColor = Color(0xFFDC0000);
  static const Color secondaryColor = Color(0xFF1D1E33);
  static const Color backgroundColor = Color(0xFF0A0E21);
  static const Color cardColor = Color(0xFF1D1E33);
  static const Color accentColor = Color(0xFFFFD700);

  // نصوص
  static const String appName = 'F1 Manager';
  static const String appDescription = 'لعبة إدارة فرق الفورمولا 1';

  // إعدادات اللعبة
  static const int startingBudget = 1000000;
  static const int racesPerSeason = 24;
  static const int maxUpgradeLevel = 5;

  // قائمة الفرق
  
  // أسعار التطوير
  static const Map<String, int> upgradeCosts = {
    'engine': 20000000,
    'chassis': 15000000,
    'aero': 18000000,
    'reliability': 12000000,
  };

  // تحسينات الأداء
  static const Map<String, double> upgradeBoosts = {
    'engine': 8.0,
    'chassis': 6.0,
    'aero': 7.0,
    'reliability': 4.0,
  };

  // إضافة هذه المتغيرات المفقودة
  // static const int racesPerSeason = 10;
  
  // إضافة هذه الدوال المفقودة
  static String getTireName(TireType tire) {
    switch (tire) {
      case TireType.soft: return "ناعمة";
      case TireType.medium: return "متوسطة";
      case TireType.hard: return "صلبة";
      case TireType.wet: return "مطر";
    }
  }

  static String getAggressionName(AggressionLevel aggression) {
    switch (aggression) {
      case AggressionLevel.conservative: return "محافظ";
      case AggressionLevel.balanced: return "متوازن";
      case AggressionLevel.aggressive: return "عدواني";
    }
  }
}
