import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 🎮 الزر الأساسي - 3D Squishy Style
///
/// الفكرة: زر يبان كأنه "مرفوع" 3D، ولما تضغط عليه ينضغط (scale down)
/// ويعطي إحساس أنه فعلاً قابل للضغط - زي ألعاب الأطفال.
class AppPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Gradient? gradient;
  final IconData? icon;
  final Color? shadowColor;

  /// لون النص (افتراضياً أبيض). استخدمه للأزرار الـ pastel
  /// اللي تحتاج نص داكن للتباين.
  final Color? textColor;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.gradient,
    this.icon,
    this.shadowColor,
    this.textColor,
  });

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = widget.gradient ?? AppGradients.primary;
    final effectiveShadowColor = widget.shadowColor ??
        ((effectiveGradient is LinearGradient)
            ? effectiveGradient.colors.first
            : AppColors.primary);

    return GestureDetector(
      onTapDown: widget.isLoading || widget.onTap == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isLoading || widget.onTap == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.96 : 1.0)
          ..translate(0.0, _isPressed ? 4.0 : 0.0),
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusHuge),
          boxShadow: _isPressed
              ? AppShadows.colored(effectiveShadowColor, opacity: 0.25)
              : AppShadows.button(effectiveShadowColor),
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                        widget.textColor ?? Colors.white),
                    strokeWidth: 3,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon,
                          color: widget.textColor ?? AppColors.white,
                          size: 24),
                      const SizedBox(width: AppSpacing.xs + 2),
                    ],
                    Text(
                      widget.label,
                      style: AppTypography.buttonLarge.copyWith(
                        color: widget.textColor ?? AppColors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// 🔘 الزر الثانوي - outline مع نفس squishy effect
class AppSecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;

  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.icon,
  });

  @override
  State<AppSecondaryButton> createState() => _AppSecondaryButtonState();
}

class _AppSecondaryButtonState extends State<AppSecondaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? AppColors.primary;

    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.96 : 1.0)
          ..translate(0.0, _isPressed ? 4.0 : 0.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusHuge),
          border: Border.all(color: c, width: 3),
          boxShadow: _isPressed
              ? AppShadows.small
              : AppShadows.colored(c, opacity: 0.2),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: c, size: 24),
                const SizedBox(width: AppSpacing.xs + 2),
              ],
              Text(
                widget.label,
                style: AppTypography.buttonLarge.copyWith(color: c),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔙 زر الرجوع - دائري كبير مع 3D effect
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? color;

  const AppBackButton({super.key, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.colored(c, opacity: 0.15),
      ),
      child: IconButton(
        onPressed: onTap ?? () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios_rounded, color: c),
        iconSize: 22,
      ),
    );
  }
}

/// 🔘 زر أيقونة دائري - 3D bubble
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final Color? iconColor;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.white;
    final iColor = iconColor ?? AppColors.primary;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.colored(iColor, opacity: 0.15),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: iColor, size: 24),
        padding: const EdgeInsets.all(AppSpacing.sm),
      ),
    );
  }
}

/// ⭐ Badge صغير - للنقاط والإشعارات
class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
