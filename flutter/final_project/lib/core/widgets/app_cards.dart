import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 🎴 الكرت العادي - مرفوع 3D
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final List<BoxShadow>? shadow;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.shadow,
    this.borderRadius,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius:
            BorderRadius.circular(borderRadius ?? AppSpacing.radiusLg),
        boxShadow: shadow ?? AppShadows.medium,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2)
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return _PressableWrapper(onTap: onTap!, child: card);
    }
    return card;
  }
}

/// 🎴 كرت بتدرج لوني - 3D pop
class AppGradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final VoidCallback? onTap;

  const AppGradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shadowColor = (gradient is LinearGradient)
        ? (gradient as LinearGradient).colors.first
        : AppColors.primary;

    final card = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius:
            BorderRadius.circular(borderRadius ?? AppSpacing.radiusXl),
        boxShadow: AppShadows.button(shadowColor),
      ),
      child: child,
    );

    if (onTap != null) {
      return _PressableWrapper(onTap: onTap!, child: card);
    }
    return card;
  }
}

/// 🎴 كرت الحالة - أكثر حيوية
class AppStatusCard extends StatelessWidget {
  final String message;
  final AppStatusType type;
  final IconData? icon;

  const AppStatusCard({
    super.key,
    required this.message,
    required this.type,
    this.icon,
  });

  Color get _color {
    switch (type) {
      case AppStatusType.success:
        return AppColors.success;
      case AppStatusType.error:
        return AppColors.error;
      case AppStatusType.warning:
        return AppColors.warning;
      case AppStatusType.info:
        return AppColors.info;
    }
  }

  Color get _softColor {
    switch (type) {
      case AppStatusType.success:
        return AppColors.successSoft;
      case AppStatusType.error:
        return AppColors.errorSoft;
      case AppStatusType.warning:
        return AppColors.warningSoft;
      case AppStatusType.info:
        return AppColors.infoSoft;
    }
  }

  IconData get _defaultIcon {
    switch (type) {
      case AppStatusType.success:
        return Icons.check_circle_rounded;
      case AppStatusType.error:
        return Icons.error_rounded;
      case AppStatusType.warning:
        return Icons.warning_rounded;
      case AppStatusType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: _softColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: _color, width: 2),
        boxShadow: AppShadows.colored(_color, opacity: 0.15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon ?? _defaultIcon,
                color: AppColors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: _color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum AppStatusType { success, error, warning, info }

/// Helper: pressable scale effect
class _PressableWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableWrapper({required this.child, required this.onTap});

  @override
  State<_PressableWrapper> createState() => _PressableWrapperState();
}

class _PressableWrapperState extends State<_PressableWrapper> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
