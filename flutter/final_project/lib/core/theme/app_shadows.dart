import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ☁️ Soft 3D Shadows - عمق ثلاثي الأبعاد للأطفال
///
/// الفلسفة: ظلال أعمق وأنعم تعطي إحساس "puffy/squishy"
/// كأن العناصر قابلة للضغط (squishable)
class AppShadows {
  AppShadows._();

  /// ظل خفيف
  static List<BoxShadow> get small => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// ظل عادي ⭐
  static List<BoxShadow> get medium => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// ظل كبير
  static List<BoxShadow> get large => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.18),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  /// ظل ملوّن - puffy effect
  static List<BoxShadow> colored(Color color, {double opacity = 0.4}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity * 0.8),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: color.withOpacity(opacity * 0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// ظل الأزرار - 3D button effect
  /// طبقتان: ظل ملوّن واسع + خط داكن أسفل (يعطي عمق "زر مرفوع")
  static List<BoxShadow> button(Color color) {
    return [
      // ظل خارجي ملوّن (الجو حول الزر)
      BoxShadow(
        color: color.withOpacity(0.4),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
      // ظل قوي قريب
      BoxShadow(
        color: color.withOpacity(0.25),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// ظل عميق - للعناصر المهمة المرفوعة
  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.25),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: AppColors.primary.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// ظل داخلي (inner shadow effect عبر container)
  static List<BoxShadow> get inset => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
      ];
}
