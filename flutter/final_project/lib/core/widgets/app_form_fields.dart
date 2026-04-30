import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 📝 حقل إدخال بستايل bubbly
class AppFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;

  const AppFormField({
    super.key,
    this.controller,
    required this.hint,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.textAlign = TextAlign.right,
  });

  @override
  State<AppFormField> createState() => _AppFormFieldState();
}

class _AppFormFieldState extends State<AppFormField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: _isFocused
            ? AppShadows.colored(AppColors.primary, opacity: 0.25)
            : AppShadows.medium,
        border: Border.all(
          color: _isFocused
              ? AppColors.primary
              : AppColors.borderLight,
          width: _isFocused ? 2.5 : 2,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        textAlign: widget.textAlign,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: widget.icon == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(
                      right: AppSpacing.md, left: AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isFocused
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm - 4),
                    ),
                    child: Icon(widget.icon,
                        color: AppColors.primary, size: 20),
                  ),
                ),
          prefixIconConstraints: const BoxConstraints(
              minWidth: 0, minHeight: 0),
          suffixIcon: widget.suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md + 2),
        ),
      ),
    );
  }
}

/// 🔐 حقل كلمة السر
class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String hint;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const AppPasswordField({
    super.key,
    this.controller,
    this.hint = 'كلمة السر',
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      controller: widget.controller,
      hint: widget.hint,
      icon: Icons.lock_rounded,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      suffixIcon: IconButton(
        icon: Icon(
          _obscure
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          color: AppColors.textMuted,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
