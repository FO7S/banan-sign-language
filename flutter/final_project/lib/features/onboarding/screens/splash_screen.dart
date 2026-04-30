import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/screens/welcome_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../home/providers/user_provider.dart';
import '../../home/screens/home_screen.dart';
import 'avatar_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final user = await _authService.getCurrentUser();
    if (!mounted) return;

    if (user == null) {
      _goTo(const WelcomeScreen());
      return;
    }

    final emoji = user['avatarEmoji'] as String?;
    final avatarName = user['avatarName'] as String?;
    final colorValue = user['avatarColor'] as int?;

    if (emoji != null && avatarName != null && colorValue != null) {
      context.read<UserProvider>().setUser(
            user['name'] as String,
            emoji,
            avatarName,
            Color(colorValue),
          );
      _goTo(const HomeScreen());
    } else {
      context.read<UserProvider>().setUser(
            user['name'] as String,
            '🦁',
            'ليو',
            AppColors.avatarLion,
          );
      _goTo(const AvatarSelectionScreen());
    }
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.bgWelcome),
        child: Stack(
          children: [
            // فقاعات زخرفية
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sparkle3.withOpacity(0.2),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sparkle2.withOpacity(0.18),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // اللوغو
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
                      .scale(
                          duration: 600.ms,
                          curve: Curves.elasticOut)
                      .then()
                      .shimmer(duration: 1200.ms),

                  const SizedBox(height: 44),

                  Text(
                    'بنان',
                    style: AppTypography.displayLarge,
                  )
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'لِتَكونَ يَدُك.. لِسانُك',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 60),

                  // نقاط التحميل
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 6),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .fadeIn(
                              delay: Duration(milliseconds: i * 200))
                          .then()
                          .fadeOut(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
