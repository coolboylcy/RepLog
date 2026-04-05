import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - 力量感的深蓝
  static const Color primary = Color(0xFF1A56DB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);

  // Accent - 活力橙
  static const Color accent = Color(0xFFFF6B2C);
  static const Color accentLight = Color(0xFFFF8F5E);

  // Background
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Muscle group colors
  static const Color muscleChest = Color(0xFFEF4444);
  static const Color muscleBack = Color(0xFF3B82F6);
  static const Color muscleShoulders = Color(0xFFF59E0B);
  static const Color muscleLegs = Color(0xFF22C55E);
  static const Color muscleArms = Color(0xFF8B5CF6);
  static const Color muscleCore = Color(0xFFEC4899);
  static const Color muscleFullBody = Color(0xFF6366F1);

  static Color forMuscleGroup(String group) {
    switch (group) {
      case 'chest':
        return muscleChest;
      case 'back':
        return muscleBack;
      case 'shoulders':
        return muscleShoulders;
      case 'legs':
        return muscleLegs;
      case 'arms':
        return muscleArms;
      case 'core':
        return muscleCore;
      case 'full_body':
        return muscleFullBody;
      default:
        return primary;
    }
  }
}
