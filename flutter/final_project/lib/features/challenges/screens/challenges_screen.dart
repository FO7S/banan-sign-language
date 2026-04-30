import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../home/providers/user_provider.dart';
import '../../sign_camera_box/sign_camera_box.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int currentChallengeIndex = 0;
  int currentLetterIndex = 0;
  int timeLeft = 30;
  bool isRunning = false;
  bool challengeFailed = false;
  bool challengeWon = false;
  bool showLetterFeedback = false;
  bool letterCorrect = false;
  bool isCameraActive = true;
  Timer? _timer;
  late ConfettiController _confettiController;
  int streak = 0;

  final List<Map<String, dynamic>> challenges = [
    {'word': 'قمر', 'emoji': '🌙', 'letters': ['ق', 'م', 'ر'], 'time': 30, 'difficulty': 'سهل', 'points': 30},
    {'word': 'نجمة', 'emoji': '⭐', 'letters': ['ن', 'ج', 'م', 'ة'], 'time': 25, 'difficulty': 'متوسط', 'points': 50},
    {'word': 'فراشة', 'emoji': '🦋', 'letters': ['ف', 'ر', 'ا', 'ش', 'ة'], 'time': 20, 'difficulty': 'صعب', 'points': 80},
  ];

  Map<String, dynamic> get current => challenges[currentChallengeIndex];
  List<String> get letters => (current['letters'] as List).cast<String>();
  double get timerPercent => timeLeft / (current['time'] as int);
  Color get timerColor {
    if (timerPercent > 0.5) return AppColors.success;
    if (timerPercent > 0.25) return AppColors.warning;
    return AppColors.error;
  }

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    timeLeft = current['time'] as int;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void startChallenge() {
    setState(() {
      isRunning = true;
      challengeFailed = false;
      challengeWon = false;
      currentLetterIndex = 0;
      isCameraActive = true;
      timeLeft = current['time'] as int;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          t.cancel();
          isRunning = false;
          challengeFailed = true;
          streak = 0;
        }
      });
    });
  }

  void _onCameraResult(bool correct) {
    if (!mounted || !isRunning || showLetterFeedback) return;
    setState(() {
      showLetterFeedback = true;
      letterCorrect = correct;
      isCameraActive = false;
    });
    if (correct) {
      context.read<UserProvider>().addPoints(5);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          showLetterFeedback = false;
          if (currentLetterIndex < letters.length - 1) {
            currentLetterIndex++;
            isCameraActive = true;
          } else {
            _timer?.cancel();
            isRunning = false;
            challengeWon = true;
            streak++;
            final pts = (current['points'] as int) + (timeLeft * 2);
            context.read<UserProvider>().addPoints(pts);
            _confettiController.play();
          }
        });
      });
    } else {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          showLetterFeedback = false;
          isCameraActive = true;
        });
      });
    }
  }

  void nextChallenge() {
    setState(() {
      challengeWon = false;
      challengeFailed = false;
      currentLetterIndex = 0;
      isCameraActive = true;
      if (currentChallengeIndex < challenges.length - 1) {
        currentChallengeIndex++;
      } else {
        currentChallengeIndex = 0;
      }
      timeLeft = current['time'] as int;
    });
  }

  /// تخطّي الحرف الحاليّ في التحدّي (لا يؤثّر على السلسلة)
  void _skipLetter() {
    if (!mounted || !isRunning || showLetterFeedback) return;
    if (currentLetterIndex < letters.length - 1) {
      setState(() {
        currentLetterIndex++;
        isCameraActive = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration:
                const BoxDecoration(gradient: AppGradients.bgChallenges),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBackButton(
                        color: AppColors.challengesEnd,
                        onTap: () {
                          _timer?.cancel();
                          Navigator.pop(context);
                        },
                      ),
                      Text('التحدّيات ⚡',
                          style: AppTypography.headlineMedium),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppBadge(
                            label: '${streak}x',
                            icon: Icons.local_fire_department_rounded,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 2),
                          AppBadge(
                            label: '${user.points}',
                            icon: Icons.star_rounded,
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(),

                  const SizedBox(height: AppSpacing.md),

                  // كرت التحدي
                  AppGradientCard(
                    gradient: AppGradients.challenges,
                    padding: const EdgeInsets.all(AppSpacing.md + 4),
                    borderRadius: AppSpacing.radiusXl,
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
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusCircular),
                                    ),
                                    child: Text(
                                      current['difficulty'],
                                      style: AppTypography.overline
                                          .copyWith(
                                        color: AppColors.challengesEnd,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    current['word'],
                                    style: AppTypography.displayMedium
                                        .copyWith(
                                      fontSize: 44,
                                      color: AppColors.white,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    '${current['points']} نقطة + وقت×2',
                                    style: AppTypography.caption
                                        .copyWith(
                                      color: AppColors.white
                                          .withOpacity(0.9),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white.withOpacity(0.25),
                              ),
                              child: Center(
                                child: Text(current['emoji'],
                                    style: const TextStyle(fontSize: 56)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate(key: ValueKey(currentChallengeIndex))
                      .fadeIn()
                      .slideX(begin: 0.2),

                  const SizedBox(height: AppSpacing.sm + 2),

                  Expanded(
                    child: isRunning
                        ? _buildRunningContent()
                        : _buildIntroContent(),
                  ),
                ],
              ),
            ),
          ),

          if (showLetterFeedback)
            Container(
              color: (letterCorrect
                      ? AppColors.success
                      : AppColors.error)
                  .withOpacity(0.92),
              child: Center(
                child: Text(letterCorrect ? '🎉' : '💪',
                        style: const TextStyle(fontSize: 96))
                    .animate()
                    .scale(curve: Curves.elasticOut),
              ),
            ).animate().fadeIn(),

          if (challengeFailed) _buildFailedDialog(),
          if (challengeWon) _buildWonDialog(),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 50,
              colors: const [
                AppColors.sparkle1,
                AppColors.sparkle2,
                AppColors.sparkle3,
                AppColors.sparkle4,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunningContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // تايمر كبير وملوّن
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [timerColor, timerColor.withOpacity(0.7)],
                ),
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: AppShadows.colored(timerColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_rounded,
                      color: AppColors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$timeLeft ث',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 14,
                  color: AppColors.borderLight,
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 500),
                    widthFactor: timerPercent,
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [timerColor, timerColor.withOpacity(0.7)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(),

        const SizedBox(height: AppSpacing.sm + 2),

        AppCard(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          borderRadius: AppSpacing.radiusLg,
          shadow: AppShadows.small,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(letters.length, (i) {
              final isDone = i < currentLetterIndex;
              final isCurrent = i == currentLetterIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: isCurrent ? 48 : 40,
                height: isCurrent ? 48 : 40,
                decoration: BoxDecoration(
                  gradient: isDone
                      ? AppGradients.success
                      : isCurrent
                          ? AppGradients.challenges
                          : null,
                  color: !isDone && !isCurrent ? Colors.grey.shade100 : null,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                  boxShadow: isCurrent
                      ? AppShadows.colored(AppColors.challengesStart,
                          opacity: 0.3)
                      : null,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.white, size: 22)
                      : Text(
                          letters[i],
                          style: AppTypography.headlineSmall.copyWith(
                            fontSize: isCurrent ? 22 : 16,
                            color: isCurrent
                                ? AppColors.white
                                : AppColors.textMuted,
                          ),
                        ),
                ),
              );
            }),
          ),
        ).animate().fadeIn(),

        const SizedBox(height: AppSpacing.sm),

        Text(
          'أَشِر إلى حرف "${letters[currentLetterIndex]}" أمام الكاميرا',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.challengesEnd,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // زرّ تخطّي الحرف الحاليّ (لا يكسر السلسلة)
        _SkipButton(
          color: AppColors.challengesEnd,
          onTap: currentLetterIndex < letters.length - 1
              ? _skipLetter
              : null,
        ),

        const SizedBox(height: AppSpacing.sm),

        Expanded(
          child: SignCameraBox(
            expectedLetter: letters[currentLetterIndex],
            onResult: _onCameraResult,
            accentColor: AppColors.challengesStart,
            isActive: isCameraActive && !showLetterFeedback && isRunning,
          ),
        ),
      ],
    );
  }

  Widget _buildIntroContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          borderRadius: AppSpacing.radiusXl,
          shadow: AppShadows.medium,
          child: Column(
            children: [
              Text('كيف تلعب؟ 🎮',
                  style: AppTypography.headlineMedium),
              const SizedBox(height: AppSpacing.md),
              _infoRow('⏱', 'لديك ${current['time']} ثانية'),
              _infoRow('📷', 'أَشِر إلى الحروف أمام الكاميرا'),
              _infoRow('✋', 'تهجَّ الكلمة حرفاً بحرف'),
              _infoRow('⭐',
                  'اجمع ${current['points']} نقطة + مكافأة الوقت'),
              _infoRow('🔥', 'السلسلة المتواصلة تضاعف نقاطك!'),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

        const SizedBox(height: AppSpacing.xl),

        AppPrimaryButton(
          label: 'ابدأ التحدّي! ⚡',
          icon: Icons.bolt_rounded,
          onTap: startChallenge,
          gradient: AppGradients.challenges,
        ).animate().fadeIn().scale(curve: Curves.elasticOut),
      ],
    );
  }

  Widget _infoRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedDialog() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.xxl),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
            boxShadow: AppShadows.elevated,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😅', style: TextStyle(fontSize: 80))
                  .animate()
                  .scale(curve: Curves.elasticOut),
              const SizedBox(height: AppSpacing.sm),
              Text('انتهى الوقت!',
                  style: AppTypography.displaySmall
                      .copyWith(color: AppColors.error)),
              Text('حاول أن تكون أسرع في المرّة القادمة',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  )),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      label: 'تخطي',
                      onTap: () {
                        setState(() => challengeFailed = false);
                        nextChallenge();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppPrimaryButton(
                      label: '🔄 أعد المحاولة',
                      onTap: startChallenge,
                      gradient: AppGradients.challenges,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().scale(curve: Curves.elasticOut),
      ),
    ).animate().fadeIn();
  }

  Widget _buildWonDialog() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.xl),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
            boxShadow: AppShadows.elevated,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(current['emoji'],
                      style: const TextStyle(fontSize: 80))
                  .animate()
                  .scale(curve: Curves.elasticOut),
              Text('🏆 أحسنت!',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.accent,
                  )),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs + 2),
                decoration: BoxDecoration(
                  gradient: AppGradients.warning,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusCircular),
                  boxShadow: AppShadows.colored(AppColors.accent),
                ),
                child: Text(
                  '+${(current['points'] as int) + (timeLeft * 2)} نقطة! ⭐',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                label: 'التحدّي التالي ←',
                onTap: nextChallenge,
                gradient: AppGradients.challenges,
              ),
            ],
          ),
        ).animate().scale(curve: Curves.elasticOut),
      ),
    ).animate().fadeIn();
  }
}

/// 🔘 زرّ التخطّي - مستطيل عريض بنفس أسلوب AppBackButton
class _SkipButton extends StatelessWidget {
  final Color color;
  final VoidCallback? onTap;

  const _SkipButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: enabled
                  ? AppShadows.colored(color, opacity: 0.15)
                  : AppShadows.small,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm + 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.skip_next_rounded,
                    color: enabled ? color : AppColors.textMuted,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'تخطّي الحرف',
                    style: AppTypography.bodyMedium.copyWith(
                      color: enabled ? color : AppColors.textMuted,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
