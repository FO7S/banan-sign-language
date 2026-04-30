import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../home/providers/user_provider.dart';
import '../../sign_camera_box/sign_camera_box.dart';

class WordsScreen extends StatefulWidget {
  const WordsScreen({super.key});

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  int currentWordIndex = 0;
  int currentLetterIndex = 0;
  bool showFeedback = false;
  bool isCorrect = false;
  bool wordCompleted = false;
  bool isCameraActive = true;
  late ConfettiController _confettiController;

  final List<Map<String, dynamic>> words = [
    {'word': 'مرحبا', 'meaning': 'تحية', 'emoji': '👋', 'letters': ['م', 'ر', 'ح', 'ب', 'ا']},
    {'word': 'شكراً', 'meaning': 'امتنان', 'emoji': '🙏', 'letters': ['ش', 'ك', 'ر', 'ا']},
    {'word': 'أحبك', 'meaning': 'محبة', 'emoji': '❤️', 'letters': ['أ', 'ح', 'ب', 'ك']},
    {'word': 'ماء', 'meaning': 'شراب', 'emoji': '💧', 'letters': ['م', 'ا', 'ء']},
    {'word': 'بيت', 'meaning': 'منزل', 'emoji': '🏠', 'letters': ['ب', 'ي', 'ت']},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get currentWord => words[currentWordIndex];
  List<String> get letters =>
      (currentWord['letters'] as List).cast<String>();

  /// تخطّي الحرف الحاليّ في الكلمة دون احتساب نقاط
  void _skipLetter() {
    if (!mounted || showFeedback || wordCompleted) return;
    if (currentLetterIndex < letters.length - 1) {
      setState(() {
        currentLetterIndex++;
        isCameraActive = true;
      });
    }
  }

  void _onCameraResult(bool correct) {
    if (!mounted || showFeedback || wordCompleted) return;
    setState(() {
      showFeedback = true;
      isCorrect = correct;
      isCameraActive = false;
    });
    if (correct) context.read<UserProvider>().addPoints(5);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        showFeedback = false;
        if (correct) {
          if (currentLetterIndex < letters.length - 1) {
            currentLetterIndex++;
          } else {
            wordCompleted = true;
            _confettiController.play();
            context.read<UserProvider>().addPoints(20);
          }
        }
        isCameraActive = true;
      });
    });
  }

  void nextWord() {
    setState(() {
      wordCompleted = false;
      currentLetterIndex = 0;
      isCameraActive = true;
      if (currentWordIndex < words.length - 1) {
        currentWordIndex++;
      } else {
        currentWordIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.bgWords),
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
                      AppBackButton(color: AppColors.wordsDark),
                      Text('مسار الكلمات 💬',
                          style: AppTypography.headlineMedium),
                      AppBadge(
                        label: '${user.points}',
                        icon: Icons.star_rounded,
                        color: AppColors.accent,
                      ),
                    ],
                  ).animate().fadeIn(),

                  const SizedBox(height: AppSpacing.md),

                  // مؤشرات تقدم الكلمات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      words.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentWordIndex == i ? 32 : 12,
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: currentWordIndex == i
                              ? AppGradients.words
                              : null,
                          color: currentWordIndex == i
                              ? null
                              : AppColors.borderLight,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: currentWordIndex == i
                              ? AppShadows.colored(AppColors.wordsStart,
                                  opacity: 0.3)
                              : null,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // كرت الكلمة
                  AppGradientCard(
                    gradient: AppGradients.words,
                    padding: const EdgeInsets.all(AppSpacing.md + 4),
                    borderRadius: AppSpacing.radiusXl,
                    child: Stack(
                      children: [
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 80,
                            height: 80,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(currentWord['word'],
                                    style: AppTypography.displayMedium
                                        .copyWith(
                                      color: AppColors.white,
                                      height: 1,
                                      fontSize: 42,
                                    )),
                                Text(currentWord['meaning'],
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.white
                                          .withOpacity(0.9),
                                      fontWeight: FontWeight.w800,
                                    )),
                              ],
                            ),
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white.withOpacity(0.25),
                              ),
                              child: Center(
                                child: Text(currentWord['emoji'],
                                    style: const TextStyle(fontSize: 40)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate(key: ValueKey(currentWordIndex)).fadeIn().slideX(begin: 0.2),

                  const SizedBox(height: AppSpacing.sm + 2),

                  // تقدم الحروف
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
                          width: isCurrent ? 50 : 40,
                          height: isCurrent ? 50 : 40,
                          decoration: BoxDecoration(
                            gradient: isDone
                                ? AppGradients.success
                                : isCurrent
                                    ? AppGradients.words
                                    : null,
                            color: !isDone && !isCurrent
                                ? Colors.grey.shade100
                                : null,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                            boxShadow: isCurrent
                                ? AppShadows.colored(AppColors.wordsStart,
                                    opacity: 0.3)
                                : null,
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check_rounded,
                                    color: AppColors.white, size: 22)
                                : Text(
                                    letters[i],
                                    style: AppTypography.headlineSmall
                                        .copyWith(
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
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'إشارة حرف "${letters[currentLetterIndex]}" (${currentLetterIndex + 1}/${letters.length})',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.wordsDark,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // زرّ تخطّي الحرف الحاليّ
                  _SkipButton(
                    color: AppColors.wordsDark,
                    onTap: currentLetterIndex < letters.length - 1 &&
                            !wordCompleted
                        ? _skipLetter
                        : null,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Expanded(
                    child: SignCameraBox(
                      expectedLetter: letters[currentLetterIndex],
                      onResult: _onCameraResult,
                      accentColor: AppColors.wordsStart,
                      isActive: isCameraActive &&
                          !showFeedback &&
                          !wordCompleted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (showFeedback)
            Container(
              color: (isCorrect ? AppColors.success : AppColors.error)
                  .withOpacity(0.92),
              child: Center(
                child: Text(isCorrect ? '🎉' : '💪',
                        style: const TextStyle(fontSize: 96))
                    .animate()
                    .scale(curve: Curves.elasticOut),
              ),
            ).animate().fadeIn(),

          if (wordCompleted)
            Container(
              color: Colors.black.withOpacity(0.55),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.xxl),
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusXxl),
                    boxShadow: AppShadows.elevated,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(currentWord['emoji'],
                              style: const TextStyle(fontSize: 80))
                          .animate()
                          .scale(curve: Curves.elasticOut),
                      const SizedBox(height: AppSpacing.sm),
                      Text('أحسنت! 🏆',
                          style: AppTypography.displayMedium),
                      Text('أكملت كلمة "${currentWord['word']}"',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          )),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs + 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.accent,
                              AppColors.warning,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusCircular),
                          boxShadow:
                              AppShadows.colored(AppColors.accent),
                        ),
                        child: Text(
                          '+20 نقطة! ⭐',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppPrimaryButton(
                        label: 'الكلمة التالية ←',
                        onTap: nextWord,
                        gradient: AppGradients.words,
                      ),
                    ],
                  ),
                ).animate().scale(curve: Curves.elasticOut),
              ),
            ).animate().fadeIn(),

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
