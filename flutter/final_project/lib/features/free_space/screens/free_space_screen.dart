import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import 'sign_to_text_screen.dart';
import 'voice_to_sign_screen.dart';

class FreeSpaceScreen extends StatelessWidget {
  const FreeSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      gradient: AppGradients.bgFreeSpace,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppBackButton(color: AppColors.freeSpaceDark),
              const SizedBox(width: AppSpacing.sm),
              Text('مساحة حرّة 🎤',
                  style: AppTypography.headlineLarge),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: AppSpacing.xxxl),

          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.7),
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusCircular),
            ),
            child: Text(
              'أنا ...',
              textAlign: TextAlign.center,
              style: AppTypography.displayMedium,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: AppSpacing.xxxl),

          _BigFunButton(
            emoji: '🤟',
            title: 'أشير وأتعلَّم',
            description: 'كوِّن أيّ جملة باستخدام إشاراتك!',
            gradient: AppGradients.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SignToTextScreen()),
            ),
            delay: 500,
          ),

          const SizedBox(height: AppSpacing.lg),

          _BigFunButton(
            emoji: '🎤',
            title: 'انطق وتعلَّم',
            description: 'انطق كلمة وسنعرض لك إشارة كلّ حرف فيها!',
            gradient: AppGradients.challenges,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const VoiceToSignScreen()),
            ),
            delay: 700,
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

class _BigFunButton extends StatefulWidget {
  final String emoji;
  final String title;
  final String description;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final int delay;

  const _BigFunButton({
    required this.emoji,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_BigFunButton> createState() => _BigFunButtonState();
}

class _BigFunButtonState extends State<_BigFunButton> {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.97 : 1.0)
          ..translate(0.0, _isPressed ? 4.0 : 0.0),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.xl + 4),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
          boxShadow: _isPressed
              ? AppShadows.colored(widget.gradient.colors.first,
                  opacity: 0.25)
              : AppShadows.button(widget.gradient.colors.first),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.15),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(widget.emoji,
                        style: const TextStyle(fontSize: 44)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTypography.headlineLarge.copyWith(
                          color: AppColors.white,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn()
        .slideY(begin: 0.2)
        .scale(begin: const Offset(0.95, 0.95));
  }
}
