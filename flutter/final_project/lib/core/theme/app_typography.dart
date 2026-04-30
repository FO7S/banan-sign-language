import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 🔤 خطوط Bold & Chunky - مناسبة للأطفال
///
/// كل النصوص أثقل وأكثر تعبيراً.
class AppTypography {
  AppTypography._();

  // ═══════════════════════════════════════════════
  // 📰 العناوين
  // ═══════════════════════════════════════════════

  static TextStyle get displayLarge => GoogleFonts.tajawal(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
        height: 1,
        letterSpacing: -1,
      );

  static TextStyle get displayMedium => GoogleFonts.tajawal(
        fontSize: 40,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
        letterSpacing: -0.5,
      );

  static TextStyle get displaySmall => GoogleFonts.tajawal(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
      );

  static TextStyle get headlineLarge => GoogleFonts.tajawal(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.tajawal(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      );

  // ═══════════════════════════════════════════════
  // 📝 النصوص العادية - أثقل من المعتاد
  // ═══════════════════════════════════════════════

  static TextStyle get bodyLarge => GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => GoogleFonts.tajawal(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );

  static TextStyle get overline => GoogleFonts.tajawal(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  // ═══════════════════════════════════════════════
  // 🔘 الأزرار - أكبر وأعرض
  // ═══════════════════════════════════════════════

  static TextStyle get buttonLarge => GoogleFonts.tajawal(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: AppColors.white,
        letterSpacing: 0.3,
      );

  static TextStyle get buttonMedium => GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: AppColors.white,
      );

  static TextStyle get buttonSmall => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: AppColors.white,
      );

  // ═══════════════════════════════════════════════
  // 🔤 الحروف
  // ═══════════════════════════════════════════════

  static TextStyle get letterDisplay => GoogleFonts.tajawal(
        fontSize: 96,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
        height: 1,
      );

  static TextStyle get letterMedium => GoogleFonts.tajawal(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
      );

  static TextStyle get letterName => GoogleFonts.tajawal(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      );

  // ═══════════════════════════════════════════════
  // ❌ رسائل
  // ═══════════════════════════════════════════════

  static TextStyle get errorMessage => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.error,
      );

  static TextStyle get successMessage => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.success,
      );
}
