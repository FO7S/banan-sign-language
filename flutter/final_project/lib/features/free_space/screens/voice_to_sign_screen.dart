import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

class VoiceToSignScreen extends StatefulWidget {
  const VoiceToSignScreen({super.key});

  @override
  State<VoiceToSignScreen> createState() => _VoiceToSignScreenState();
}

class _VoiceToSignScreenState extends State<VoiceToSignScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  List<String> _characters = [];

  // خريطة الحروف العربية لأسماء صور إشاراتها
  static const Map<String, String> _letterImages = {
    'أ': '01_Alif.png',
    'ا': '01_Alif.png',
    'إ': '01_Alif.png',
    'آ': '01_Alif.png',
    'ب': '02_Ba.png',
    'ت': '03_Ta.png',
    'ث': '04_Tha.png',
    'ج': '05_Jim.png',
    'ح': '06_Ha.png',
    'خ': '07_Kha.png',
    'د': '08_Dal.png',
    'ذ': '09_Dhal.png',
    'ر': '10_Ra.png',
    'ز': '11_Zay.png',
    'س': '12_Sin.png',
    'ش': '13_Shin.png',
    'ص': '14_Sad.png',
    'ض': '15_Dad.png',
    'ط': '16_Taa.png',
    'ظ': '17_Za.png',
    'ع': '18_Ayn.png',
    'غ': '19_Ghayn.png',
    'ف': '20_Fa.png',
    'ق': '21_Qaf.png',
    'ك': '22_Kaf.png',
    'ل': '23_Lam.png',
    'م': '24_Mim.png',
    'ن': '25_Nun.png',
    'ه': '26_Haa.png',
    'و': '27_Waw.png',
    'ي': '28_Ya.png',
    'ة': '29_TaaMarbuta.png',
    'ى': '32_Yaa.png',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    if (available) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            _characters = _recognizedText
                .split('')
                .where((c) => c.trim().isNotEmpty)
                .toList();
          });
        },
        localeId: 'ar_SA',
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      gradient: AppGradients.bgFreeSpace,
      child: Column(
        children: [
          Row(
            children: [
              AppBackButton(color: AppColors.challengesEnd),
              const SizedBox(width: AppSpacing.sm),
              Text('انطق وتعلَّم 🎤',
                  style: AppTypography.headlineLarge),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          AppCard(
            child: Row(
              children: [
                const Text('🗣️', style: TextStyle(fontSize: 36)),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    'اضغط على الميكروفون وانطق أيّ جملة، وسنعرض لك إشارة كلّ حرف!',
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: AppSpacing.xxxl),

          // زر الميكروفون - كبير 3D
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isListening
                    ? AppGradients.error
                    : AppGradients.primary,
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: AppColors.error.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 12,
                          offset: const Offset(0, 12),
                        ),
                      ]
                    : AppShadows.button(AppColors.primary),
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: AppColors.white,
                size: 72,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md + 2, vertical: AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusCircular),
              boxShadow: AppShadows.small,
            ),
            child: Text(
              _isListening ? '🔴 جارٍ الاستماع...' : 'اضغط للتسجيل',
              style: AppTypography.bodyLarge.copyWith(
                color: _isListening
                    ? AppColors.error
                    : AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          if (_recognizedText.isNotEmpty)
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              shadow: AppShadows.colored(AppColors.primary, opacity: 0.2),
              borderColor: AppColors.primarySoft,
              child: Text(
                '"$_recognizedText"',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(),

          const SizedBox(height: AppSpacing.lg),

          if (_characters.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إشارات الحروف بالتسلسل:',
                      style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),




                  // Expanded(
                  //   child: GridView.builder(
                  //     gridDelegate:
                  //         const SliverGridDelegateWithFixedCrossAxisCount(
                  //       crossAxisCount: 4,
                  //       crossAxisSpacing: AppSpacing.xs + 2,
                  //       mainAxisSpacing: AppSpacing.xs + 2,
                  //     ),
                  //     itemCount: _characters.length,
                  //     itemBuilder: (context, i) {
                  //       final letter = _characters[i];
                  //       final imageName = _letterImages[letter];
                  //       return Container(
                  //         decoration: BoxDecoration(
                  //           color: AppColors.white,
                  //           borderRadius: BorderRadius.circular(
                  //               AppSpacing.radiusLg),
                  //           boxShadow: AppShadows.colored(
                  //               AppColors.primary,
                  //               opacity: 0.15),
                  //           border: Border.all(
                  //               color: AppColors.primarySoft, width: 2),
                  //         ),
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             // صورة الإشارة (أو علامة سؤال إذا الحرف غير معروف)
                  //             Expanded(
                  //               child: Padding(
                  //                 padding: const EdgeInsets.all(6),
                  //                 child: imageName != null
                  //                     ? Image.asset(
                  //                         'assets/images/ArSL_letters/$imageName',
                  //                         fit: BoxFit.contain,
                  //                       )
                  //                     : Center(
                  //                         child: Text(
                  //                           '?',
                  //                           style: TextStyle(
                  //                             fontSize: 32,
                  //                             color: AppColors.textMuted,
                  //                           ),
                  //                         ),
                  //                       ),
                  //               ),
                  //             ),



                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: AppSpacing.xs,
                        mainAxisSpacing: AppSpacing.xs,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _characters.length,
                      itemBuilder: (context, i) {
                        final letter = _characters[i];
                        final imageName = _letterImages[letter];
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg),
                            boxShadow: AppShadows.colored(
                                AppColors.primary,
                                opacity: 0.15),
                            border: Border.all(
                                color: AppColors.primarySoft, width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // صورة الإشارة (أو علامة سؤال إذا الحرف غير معروف)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: imageName != null
                                      ? Image.asset(
                                          'assets/images/ArSL_letters/$imageName',
                                          fit: BoxFit.contain,
                                        )
                                      : Center(
                                          child: Text(
                                            '?',
                                            style: TextStyle(
                                              fontSize: 40,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ),
                                ),
                              ),


                              


                              Text(
                                letter,
                                style: AppTypography.headlineSmall
                                    .copyWith(
                                  fontSize: 22,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate(delay: Duration(milliseconds: 50 * i))
                            .fadeIn()
                            .scale(curve: Curves.elasticOut);
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
