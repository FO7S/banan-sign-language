import 'package:flutter/material.dart';

/// 🍭 Candy Pop Palette - ألوان حيوية للأطفال
///
/// الفلسفة:
/// - ألوان مشبعة (saturated) بدلاً من pastel
/// - تباين عالي يجذب الانتباه
/// - كل لون له "shadow color" أغمق منه للعمق ثلاثي الأبعاد
/// - مستوحاة من الحلويات والكرتون الحديث
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════
  // 🌟 الألوان الأساسية - Vibrant Brand
  // ═══════════════════════════════════════════════

  /// البنفسجي الكهربائي - هوية التطبيق
  // static const Color primary = Color(0xFF7C5CFF);
  // static const Color primaryDark = Color(0xFF5A3FD9);
  // static const Color primarySoft = Color(0xFFE8E0FF);

static const Color primary = Color(0xFF1B4F8F);      // كوبالت
static const Color primaryDark = Color(0xFF0F3666);
static const Color primarySoft = Color(0xFFCFE0F2);

  /// الأزرق السماوي الحيوي
  static const Color secondary = Color(0xFF00D9FF);
  static const Color secondaryDark = Color(0xFF00A8C8);
  static const Color secondarySoft = Color(0xFFD0F4FF);

  /// البرتقالي الناري
  static const Color accent = Color(0xFFFF8A3D);
  static const Color accentDark = Color(0xFFD96A1F);
  static const Color accentSoft = Color(0xFFFFE0CC);

  // ═══════════════════════════════════════════════
  // 🌈 ألوان الأقسام - Bold & Distinctive
  // ═══════════════════════════════════════════════

  /// الحروف - أزرق سماوي → أخضر فيروزي
  static const Color lettersStart = Color(0xFF00D9FF);
  static const Color lettersEnd = Color(0xFF00E5A0);
  static const Color lettersDark = Color(0xFF00A8C8);

  /// الكلمات - وردي → بنفسجي
  static const Color wordsStart = Color(0xFFFF6B9D);
  static const Color wordsEnd = Color(0xFFB66BFF);
  static const Color wordsDark = Color(0xFFC4317A);

  /// التحديات - برتقالي → أحمر
  static const Color challengesStart = Color(0xFFFFAA3D);
  static const Color challengesEnd = Color(0xFFFF5C5C);
  static const Color challengesDark = Color(0xFFE07A2B);

  /// المساحة الحرة - أصفر → برتقالي
  static const Color freeSpaceStart = Color(0xFFFFD93D);
  static const Color freeSpaceEnd = Color(0xFFFF8A3D);
  static const Color freeSpaceDark = Color(0xFFD9B033);

  // ═══════════════════════════════════════════════
  // 💬 ألوان الحالة - Friendly Semantic
  // ═══════════════════════════════════════════════

  static const Color success = Color(0xFF2ED573);
  static const Color successDark = Color(0xFF20A557);
  static const Color successSoft = Color(0xFFD4F5E0);

  static const Color error = Color(0xFFFF4757);
  static const Color errorDark = Color(0xFFCC2A37);
  static const Color errorSoft = Color(0xFFFFD8DC);

  static const Color errorStrong = Color(0xFFFF4757);

  static const Color warning = Color(0xFFFFA502);
  static const Color warningDark = Color(0xFFCC8401);
  static const Color warningSoft = Color(0xFFFFE9C4);

  static const Color info = Color(0xFF00D9FF);
  static const Color infoDark = Color(0xFF00A8C8);
  static const Color infoSoft = Color(0xFFD0F4FF);

  // ═══════════════════════════════════════════════
  // ⚪ Neutrals - Warm not cold
  // ═══════════════════════════════════════════════

  static const Color textPrimary = Color(0xFF1A1B3D);
  static const Color textSecondary = Color(0xFF5C5F8C);
  static Color textMuted = const Color(0xFF9CA3D9).withOpacity(0.8);

  static const Color white = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color borderLight = Color(0xFFE8E9F5);

  // ═══════════════════════════════════════════════
  // 🐾 ألوان الأفاتار - Bright & Cheerful
  // ═══════════════════════════════════════════════

  static const Color avatarLion = Color(0xFFFFAA3D);
  static const Color avatarDolphin = Color(0xFF00D9FF);
  static const Color avatarFox = Color(0xFFFF6B9D);
  static const Color avatarPanda = Color(0xFF2ED573);
  static const Color avatarUnicorn = Color(0xFFB66BFF);
  static const Color avatarFrog = Color(0xFF7CD933);

  // ═══════════════════════════════════════════════
  // 🖼️ خلفيات - Soft & Dreamy
  // ═══════════════════════════════════════════════

  /// خلفية الترحيب
  // static const Color bgWelcome1 = Color(0xFFFFF0F5);
  // static const Color bgWelcome2 = Color(0xFFE8E0FF);
  // static const Color bgWelcome3 = Color(0xFFD0F4FF);
  static const Color bgWelcome1 = Color(0xFFE8F4FF);
  static const Color bgWelcome2 = Color(0xFFD6EBFF);
  static const Color bgWelcome3 = Color(0xFFE0F5F0);

  /// خلفية تسجيل الدخول
  // static const Color bgLogin1 = Color(0xFFE8E0FF);
  // static const Color bgLogin2 = Color(0xFFFFE0F0);
  static const Color bgLogin1 = Color(0xFFE8F4FF);
  static const Color bgLogin2 = Color(0xFFE0F5F0);

  /// خلفية التسجيل
  // static const Color bgRegister1 = Color(0xFFFFF0E5);
  // static const Color bgRegister2 = Color(0xFFE8E0FF);
  static const Color bgRegister1 = Color(0xFFE0F5F0);
  static const Color bgRegister2 = Color(0xFFE8F4FF);

  /// خلفية الهوم
  static const Color bgHome1 = Color(0xFFE8F4FF);
  static const Color bgHome2 = Color(0xFFFFE8F0);

  /// خلفية الحروف
  static const Color bgLetters1 = Color(0xFFD0F4FF);
  static const Color bgLetters2 = Color(0xFFD4F5E0);

  /// خلفية الكلمات
  static const Color bgWords1 = Color(0xFFFFE0F0);
  static const Color bgWords2 = Color(0xFFEDE0FF);

  /// خلفية التحديات
  static const Color bgChallenges1 = Color(0xFFFFE9C4);
  static const Color bgChallenges2 = Color(0xFFFFD8DC);

  /// خلفية المساحة الحرة
  static const Color bgFreeSpace1 = Color(0xFFFFF8D6);
  static const Color bgFreeSpace2 = Color(0xFFFFE0CC);

  // ═══════════════════════════════════════════════
  // ✨ Sparkle / Decoration colors
  // ═══════════════════════════════════════════════

  /// نقاط زخرفية
  static const Color sparkle1 = Color(0xFFFFD93D);
  static const Color sparkle2 = Color(0xFFFF6B9D);
  static const Color sparkle3 = Color(0xFF00D9FF);
  static const Color sparkle4 = Color(0xFFB66BFF);

  // ═══════════════════════════════════════════════
  // 🌸 ألوان Pastel - للأزرار الناعمة
  // ═══════════════════════════════════════════════

  /// Pastel بنفسجي - الأساسي للأزرار الناعمة
  static const Color pastelLavender = Color(0xFFC8B6FF);
  static const Color pastelLavenderDark = Color(0xFF9D8BE8);

  // /// نص داكن للأزرار الـ pastel (عشان التباين)
  // static const Color pastelButtonText = Color(0xFF4A3F8C);

  /// نص داكن للأزرار الـ pastel (عشان التباين)
  static const Color pastelButtonText =  Color.fromARGB(255, 1, 71, 161); // Color(0xFF1E3A5F);

  /// Pastel أزرق سماوي - ناعم متوازن
  static const Color pastelSky = Color(0xFFA2D2FF);
}
