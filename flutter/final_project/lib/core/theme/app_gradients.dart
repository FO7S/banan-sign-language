import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 🌈 Vibrant Gradients
class AppGradients {
  AppGradients._();

  // ═══════════════════════════════════════════════
  // 🎯 تدرجات الأقسام - جريئة ومميزة
  // ═══════════════════════════════════════════════

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.secondary],
  );

  static const LinearGradient primaryDeep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  static const LinearGradient letters = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.lettersStart, AppColors.lettersEnd],
  );

  static const LinearGradient words = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.wordsStart, AppColors.wordsEnd],
  );

  static const LinearGradient challenges = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.challengesStart, AppColors.challengesEnd],
  );

  static const LinearGradient freeSpace = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.freeSpaceStart, AppColors.freeSpaceEnd],
  );

  // ═══════════════════════════════════════════════
  // 🖼️ تدرجات الخلفيات
  // ═══════════════════════════════════════════════

  static const LinearGradient bgWelcome = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.bgWelcome1,
      AppColors.bgWelcome2,
      AppColors.bgWelcome3,
    ],
  );

  static const LinearGradient bgLogin = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.bgLogin1, AppColors.bgLogin2],
  );

  static const LinearGradient bgRegister = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.bgRegister1, AppColors.bgRegister2],
  );

  static const LinearGradient bgHome = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.bgHome1, AppColors.bgHome2],
  );

  static const LinearGradient bgLetters = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.bgLetters1, AppColors.bgLetters2],
  );

  static const LinearGradient bgWords = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.bgWords1, AppColors.bgWords2],
  );

  static const LinearGradient bgChallenges = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.bgChallenges1, AppColors.bgChallenges2],
  );

  static const LinearGradient bgFreeSpace = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.bgFreeSpace1, AppColors.bgFreeSpace2],
  );

  // ═══════════════════════════════════════════════
  // ⭐ تدرجات إضافية
  // ═══════════════════════════════════════════════

  static const LinearGradient success = LinearGradient(
    colors: [AppColors.success, Color(0xFF00E5A0)],
  );

  static const LinearGradient error = LinearGradient(
    colors: [AppColors.error, Color(0xFFFF6B9D)],
  );

  static const LinearGradient warning = LinearGradient(
    colors: [AppColors.warning, AppColors.accent],
  );

  // ═══════════════════════════════════════════════
  // 🌸 تدرجات Pastel - ناعمة ومريحة للعين
  // ═══════════════════════════════════════════════

  /// Pastel بنفسجي - ناعم ومريح
  static const LinearGradient pastelLavender = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC8B6FF), Color(0xFFB8C0FF)],
  );

  /// Pastel وردي - حنون ودافئ
  static const LinearGradient pastelPink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC8DD), Color(0xFFFFAFCC)],
  );

  /// Pastel أزرق - هادئ
  static const LinearGradient pastelSky = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFBDE0FE), Color(0xFFA2D2FF)],
  );

  /// Pastel خوخي - دافئ
  static const LinearGradient pastelPeach = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD6BA), Color(0xFFFFB5A7)],
  );
}
