import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M \$';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K \$';
    }
    return '${amount.toInt()} \$';
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static String getPositionIcon(int position) {
    switch (position) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '${position}';
    }
  }

  static Color getPositionColor(int position) {
    switch (position) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      case 4: case 5: case 6: return const Color(0xFF4CAF50);
      case 7: case 8: case 9: case 10: return const Color(0xFF2196F3);
      default: return const Color(0xFF757575);
    }
  }

  static String getTireEmoji(String tireType) {
    switch (tireType) {
      case 'ناعمة':
        return '🔴';
      case 'متوسطة':
        return '🟡';
      case 'صلبة':
        return '⚪';
      case 'مطر':
        return '🔵';
      default:
        return '🛞';
    }
  }

  static String getAggressionEmoji(String aggression) {
    switch (aggression) {
      case 'محافظ':
        return '🐢';
      case 'متوازن':
        return '⚖️';
      case 'عدواني':
        return '💥';
      default:
        return '🎯';
    }
  }
}
