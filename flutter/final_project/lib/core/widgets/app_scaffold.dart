import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// 🖼️ Scaffold موحد مع زخارف اختيارية (sparkles/blobs)
class AppScaffold extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry? padding;
  final bool resizeToAvoidBottomInset;

  /// إذا true يضيف فقاعات زخرفية في الخلفية
  final bool showDecoration;

  const AppScaffold({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.resizeToAvoidBottomInset = true,
    this.showDecoration = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          children: [
            // فقاعات زخرفية في الخلفية
            if (showDecoration) ..._buildDecoration(context),

            // المحتوى
            SafeArea(
              child: Padding(
                padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDecoration(BuildContext context) {
    return [
      // فقاعة 1 - أعلى يمين
      Positioned(
        top: -40,
        right: -40,
        child: _Bubble(
          size: 160,
          color: AppColors.sparkle3.withOpacity(0.15),
        ),
      ),
      // فقاعة 2 - أعلى يسار
      Positioned(
        top: 80,
        left: -60,
        child: _Bubble(
          size: 120,
          color: AppColors.sparkle2.withOpacity(0.12),
        ),
      ),
      // فقاعة 3 - أسفل يمين
      Positioned(
        bottom: -80,
        right: -30,
        child: _Bubble(
          size: 200,
          color: AppColors.sparkle1.withOpacity(0.1),
        ),
      ),
      // فقاعة 4 - أسفل يسار
      Positioned(
        bottom: 100,
        left: -40,
        child: _Bubble(
          size: 90,
          color: AppColors.sparkle4.withOpacity(0.12),
        ),
      ),
    ];
  }
}

class _Bubble extends StatelessWidget {
  final double size;
  final Color color;

  const _Bubble({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
