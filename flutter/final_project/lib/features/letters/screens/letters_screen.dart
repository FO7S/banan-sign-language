import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../../../core/api/session_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../home/providers/user_provider.dart';
import '../../sign_camera_box/sign_camera_box.dart';

class LettersScreen extends StatefulWidget {
  const LettersScreen({super.key});

  @override
  State<LettersScreen> createState() => _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen> {
  int currentIndex = 0;
  bool showFeedback = false;
  bool isCorrect = false;
  bool isCameraActive = true;
  late ConfettiController _confettiController;

  // 🆕 ربط Backend
  String? _sessionId;
  DateTime? _letterStartTime;

  final _sessionApi = SessionApi.instance;
  final _challengeApi = ChallengeApi.instance;

  final List<Map<String, dynamic>> letters = [
    {'letter': 'أ', 'name': 'ألف', 'image': '01_Alif.png'},
    {'letter': 'ب', 'name': 'باء', 'image': '02_Ba.png'},
    {'letter': 'ت', 'name': 'تاء', 'image': '03_Ta.png'},
    {'letter': 'ث', 'name': 'ثاء', 'image': '04_Tha.png'},
    {'letter': 'ج', 'name': 'جيم', 'image': '05_Jim.png'},
    {'letter': 'ح', 'name': 'حاء', 'image': '06_Ha.png'},
    {'letter': 'خ', 'name': 'خاء', 'image': '07_Kha.png'},
    {'letter': 'د', 'name': 'دال', 'image': '08_Dal.png'},
    {'letter': 'ذ', 'name': 'ذال', 'image': '09_Dhal.png'},
    {'letter': 'ر', 'name': 'راء', 'image': '10_Ra.png'},
    {'letter': 'ز', 'name': 'زاي', 'image': '11_Zay.png'},
    {'letter': 'س', 'name': 'سين', 'image': '12_Sin.png'},
    {'letter': 'ش', 'name': 'شين', 'image': '13_Shin.png'},
    {'letter': 'ص', 'name': 'صاد', 'image': '14_Sad.png'},
    {'letter': 'ض', 'name': 'ضاد', 'image': '15_Dad.png'},
    {'letter': 'ط', 'name': 'طاء', 'image': '16_Taa.png'},
    {'letter': 'ظ', 'name': 'ظاء', 'image': '17_Za.png'},
    {'letter': 'ع', 'name': 'عين', 'image': '18_Ayn.png'},
    {'letter': 'غ', 'name': 'غين', 'image': '19_Ghayn.png'},
    {'letter': 'ف', 'name': 'فاء', 'image': '20_Fa.png'},
    {'letter': 'ق', 'name': 'قاف', 'image': '21_Qaf.png'},
    {'letter': 'ك', 'name': 'كاف', 'image': '22_Kaf.png'},
    {'letter': 'ل', 'name': 'لام', 'image': '23_Lam.png'},
    {'letter': 'م', 'name': 'ميم', 'image': '24_Mim.png'},
    {'letter': 'ن', 'name': 'نون', 'image': '25_Nun.png'},
    {'letter': 'ه', 'name': 'هاء', 'image': '26_Haa.png'},
    {'letter': 'و', 'name': 'واو', 'image': '27_Waw.png'},
    {'letter': 'ي', 'name': 'ياء', 'image': '28_Ya.png'},
    {'letter': 'ة', 'name': 'تاء مربوطة', 'image': '29_TaaMarbuta.png'},
    {'letter': 'ى', 'name': 'ألف مقصورة', 'image': '32_Yaa.png'},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _letterStartTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _endSession();
    super.dispose();
  }

  /// بدء جلسة جديدة في الـ Backend
  /// ⚠️ نتجاهل الأخطاء بصمت كي لا تُعطّل تجربة التعلّم
  Future<void> _startSession() async {
    final userId = context.read<UserProvider>().userId;
    if (userId.isEmpty) return;

    try {
      final response = await _sessionApi.start(
        userId: userId,
        mode: SessionMode.letter,
      );

      if (response.success && mounted) {
        final data = response.data as Map<String, dynamic>;
        // ⚠️ الـ Backend يرجع session_id (وليس id)
        setState(() => _sessionId = data['session_id'] as String?);
      }
    } catch (_) {
      // ✅ تجاهل صامت - التعلّم يستمرّ بدون اتّصال
    }
  }

  /// إنهاء الجلسة
  Future<void> _endSession() async {
    if (_sessionId == null) return;
    final userId = context.read<UserProvider>().userId;
    if (userId.isEmpty) return;

    try {
      // ⚠️ الـ Backend ما يحتاج score/streak
      await _sessionApi.end(sessionId: _sessionId!, userId: userId);
    } catch (_) {
      // ✅ تجاهل صامت
    }
  }

  /// عند نتيجة من الكاميرا
  void _onCameraResult(bool correct) {
    if (!mounted || showFeedback) return;

    final timeTaken = _letterStartTime != null
        ? DateTime.now().difference(_letterStartTime!).inMilliseconds / 1000.0
        : 0.0;

    setState(() {
      showFeedback = true;
      isCorrect = correct;
      isCameraActive = false;
    });

    if (correct) {
      _confettiController.play();
    }

    // 🆕 إرسال المحاولة للـ Backend (الـ Backend يحسب النقاط ويحدّث كل شي)
    _submitToBackend(correct: correct, timeTaken: timeTaken);

    Future.delayed(Duration(seconds: correct ? 2 : 1), () {
      if (!mounted) return;
      setState(() {
        showFeedback = false;
        if (correct && currentIndex < letters.length - 1) currentIndex++;
        isCameraActive = true;
        _letterStartTime = DateTime.now();
      });
    });
  }

  /// تخطّي الحرف الحاليّ والانتقال إلى التالي دون احتساب نقاط
  void _skipCurrent() {
    if (!mounted || showFeedback) return;
    if (currentIndex >= letters.length - 1) return;
    setState(() {
      currentIndex++;
      isCameraActive = true;
      _letterStartTime = DateTime.now();
    });
  }

  /// إرسال المحاولة للسيرفر
  /// الـ Backend يرجع: { correct, score_added, streak, total_session_score }
  /// ⚠️ نتجاهل الأخطاء بصمت لأنّ التغذية الراجعة من الكاميرا سبق وعُرضت
  Future<void> _submitToBackend({
    required bool correct,
    required double timeTaken,
  }) async {
    final user = context.read<UserProvider>();
    if (user.userId.isEmpty || _sessionId == null) return;

    try {
      final current = letters[currentIndex];
      final response = await _challengeApi.submit(
        userId: user.userId,
        sessionId: _sessionId!,
        mode: SessionMode.letter,
        target: current['letter'] as String,
        answer: correct ? current['letter'] as String : '?',
        confidence: correct ? 0.95 : 0.5,
        timeTaken: timeTaken,
      );

      // تحديث الـ UI بالنقاط الفعلية من الـ Backend
      if (response.success && mounted) {
        final data = response.data as Map<String, dynamic>;
        final scoreAdded = data['score_added'] as int? ?? 0;
        final newStreak = data['streak'] as int? ?? 0;

        if (scoreAdded > 0) {
          user.addPoints(scoreAdded);
        }
        user.setStreak(newStreak);

        if (correct) {
          user.addLetterLearned();
        }
      }
    } catch (_) {
      // ✅ تجاهل صامت - التغذية الراجعة المحلّية سبق وعُرضت
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = letters[currentIndex];
    final user = context.watch<UserProvider>();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.bgLetters),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppBackButton(color: AppColors.lettersDark),
                        Text('مسار الحروف 🔤',
                            style: AppTypography.headlineMedium),
                        AppBadge(
                          label: '${user.points}',
                          icon: Icons.star_rounded,
                          color: AppColors.accent,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Stack(
                      children: [
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.borderLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 500),
                          widthFactor:
                              (currentIndex + 1) / letters.length,
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              gradient: AppGradients.letters,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: AppShadows.colored(
                                  AppColors.lettersStart,
                                  opacity: 0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${currentIndex + 1} من ${letters.length}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.lettersDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md + 4,
                          horizontal: AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.white,
                            AppColors.secondarySoft,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXxl),
                        boxShadow: AppShadows.colored(
                            AppColors.lettersStart,
                            opacity: 0.3),
                        border: Border.all(
                            color: AppColors.lettersStart
                                .withOpacity(0.3),
                            width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(current['letter'],
                                    style: AppTypography.letterDisplay
                                        .copyWith(
                                      color: AppColors.lettersDark,
                                      fontSize: 80,
                                    )),
                                Text(current['name'],
                                    style: AppTypography.letterName),
                              ],
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.lettersStart
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              child: Image.asset(
                                'assets/images/ArSL_letters/${current['image']}',
                                fit: BoxFit.contain,
                                height: 160,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate(key: ValueKey(currentIndex)).fadeIn().scale(
                        begin: const Offset(0.9, 0.9),
                        curve: Curves.elasticOut),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      'قم بإشارة حرف "${current['letter']}" أمام الكاميرا',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lettersDark,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // زرّ تخطّي الحرف الحاليّ
                    _SkipButton(
                      color: AppColors.lettersDark,
                      onTap: currentIndex < letters.length - 1
                          ? _skipCurrent
                          : null,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Expanded(
                      child: SignCameraBox(
                        expectedLetter: current['letter'],
                        onResult: _onCameraResult,
                        accentColor: AppColors.lettersStart,
                        isActive: isCameraActive && !showFeedback,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                AppColors.sparkle1,
                AppColors.sparkle2,
                AppColors.sparkle3,
                AppColors.sparkle4,
              ],
            ),
          ),

          if (showFeedback)
            Container(
              color: (isCorrect ? AppColors.success : AppColors.error)
                  .withOpacity(0.92),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isCorrect ? '🎉' : '💪',
                            style: const TextStyle(fontSize: 96))
                        .animate()
                        .scale(curve: Curves.elasticOut),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      isCorrect ? 'ممتاز!' : 'حاول مرّة أخرى!',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(),
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
