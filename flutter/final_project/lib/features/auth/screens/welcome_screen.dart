import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      gradient: AppGradients.bgWelcome,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // اللوغو
          Stack(
            alignment: Alignment.center,
            children: [
              // halo / glow خلفية
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.15),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 2.seconds,
                  ),

              // دائرة اللوغو مع الصورة
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  boxShadow: AppShadows.elevated,
                ),

                // child: ClipOval(
                //   child: Image.asset(
                //     'assets/images/logo.png',
                //     fit: BoxFit.cover,
                //   ),
                // ),

                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),

              )
                  .animate()
                  .scale(duration: 700.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(duration: 1500.ms),
            ],
          ),

          const SizedBox(height: 48),

          // اسم التطبيق
          Text(
            'بنان',
            style: AppTypography.displayLarge.copyWith(fontSize: 64),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

          const SizedBox(height: AppSpacing.md),

          // الجملة في pill شكل
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg + 4, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusCircular),
              boxShadow: AppShadows.colored(AppColors.primary,
                  opacity: 0.15),
            ),
            child: Text(
              'لِتَكونَ يَدُك.. لِسانُك',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ).animate().fadeIn(delay: 600.ms),

          const Spacer(flex: 3),

          // 🌸 زر تسجيل الدخول - pastel ناعم
          AppPrimaryButton(
            label: 'تسجيل الدخول',
            icon: Icons.login_rounded,
            gradient: AppGradients.pastelSky,
            shadowColor: AppColors.pastelSky,
            textColor: AppColors.pastelButtonText,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),

          const SizedBox(height: AppSpacing.md),

          AppSecondaryButton(
            label: 'تسجيل جديد',
            icon: Icons.person_add_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
          ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.3),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
