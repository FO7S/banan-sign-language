import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/api/sign_api.dart';
import '../../../core/ml/letter_mapping.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

class SignToTextScreen extends StatefulWidget {
  const SignToTextScreen({super.key});

  @override
  State<SignToTextScreen> createState() => _SignToTextScreenState();
}

// 🔧 implements WidgetsBindingObserver — camera is revoked when the app is
// backgrounded; we must re-init it when we come back, otherwise the next
// takePicture() call will hang.
class _SignToTextScreenState extends State<SignToTextScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initFuture;

  bool _isDetecting = false;
  bool _cameraError = false;
  bool _isPaused = false;
  bool _initialized = false;

  String? _detectedLetter;
  double _detectedConfidence = 0;
  String _composedText = '';

  // 🔧 auto-append state.
  // _lastAppendedLetter: the letter we most recently auto-added. We won't
  // add it again until the user lowers their hand (signaling they want a
  // new letter rather than holding the same sign).
  // _readyForNext: flips back to true the moment we see no hand or an
  // unconfident frame, so the next confident detection counts as "fresh".
  String? _lastAppendedLetter;
  bool _readyForNext = true;

  // 🔧 capture loop state (replaces Timer.periodic, which doesn't pause on
  // app lifecycle changes and can pile requests on top of each other)
  bool _captureLoopRunning = false;
  int _consecutiveFailures = 0;
  static const int _maxFailuresBeforeRebuild = 3;

  static const Duration _delayBetweenCaptures = Duration(seconds: 2);
  static const Duration _captureTimeout = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 🔧 lifecycle
    _initFuture = _setupCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _stopCaptureLoop();
      _disposeController();
    } else if (state == AppLifecycleState.resumed) {
      _initFuture = _setupCamera();
    }
  }

  Future<void> _disposeController() async {
    final c = _controller;
    _controller = null;
    _initialized = false;
    try {
      await c?.dispose();
    } catch (_) {}
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() => _cameraError = true);
        return;
      }
      final frontCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      await _disposeController();

      _controller = CameraController(
        frontCamera,
        // 🔧 high (720p) gives MediaPipe enough detail to distinguish similar
        // signs. medium (480p) was producing noisy classifications.
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) {
        await _disposeController();
        return;
      }
      setState(() {
        _initialized = true;
        _cameraError = false;
      });
      _consecutiveFailures = 0;
      _startCaptureLoop();
    } catch (e) {
      debugPrint('🔴 [S2T] camera init failed: $e');
      if (!mounted) return;
      setState(() => _cameraError = true);
    }
  }

  void _startCaptureLoop() async {
    if (_captureLoopRunning) return;
    _captureLoopRunning = true;
    while (_captureLoopRunning && mounted) {
      if (!_isPaused && _initialized && !_cameraError) {
        await _detectSign();
      }
      await Future.delayed(_delayBetweenCaptures);
    }
  }

  void _stopCaptureLoop() {
    _captureLoopRunning = false;
  }

  Future<void> _detectSign() async {
    if (!mounted || _isDetecting || _isPaused) return;
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    setState(() => _isDetecting = true);

    try {
      // 🔧 take picture with timeout — protects against silent hangs
      final xfile = await _controller!
          .takePicture()
          .timeout(_captureTimeout);
      final bytes = await xfile.readAsBytes();

      // 🔧 delete temp JPEG immediately — otherwise files accumulate in the
      // cache directory and the OS eventually freezes the main isolate to
      // clean up. This was the root cause of the camera freeze we hit before.
      unawaited(File(xfile.path).delete().catchError((_) => File(xfile.path)));

      if (!mounted || _isPaused) {
        if (mounted) setState(() => _isDetecting = false);
        return;
      }

      // 🔧 the actual ML pipeline — flip + center-crop + classify
      // (handled inside SignApi.classify, same as the challenges screen).
      final result = await SignApi.instance.classify(imageBytes: bytes);

      if (!mounted) return;

      _consecutiveFailures = 0;

      if (result == null || !result.detected) {
        // no hand visible / API failure — clear the displayed letter so we
        // don't show stale guesses from a previous frame.
        // 🔧 also flip _readyForNext on, so the next confident detection
        // counts as a fresh letter (this is what lets the user repeat a
        // letter — they lower their hand between repetitions).
        setState(() {
          _detectedLetter = null;
          _detectedConfidence = 0;
          _isDetecting = false;
          _readyForNext = true;
        });
        return;
      }

      // only act on confident classifications — otherwise we're just guessing
      if (!result.isConfident || result.modelLabel == null) {
        setState(() {
          _detectedLetter = null;
          _detectedConfidence = result.confidence;
          _isDetecting = false;
          _readyForNext = true; // 🔧 unconfident = same as no hand
        });
        return;
      }

      final arabic = LetterMapping.toArabic(result.modelLabel!);

      // 🔧 auto-append to the writing area when:
      //   1. We have a valid Arabic mapping for this label
      //   2. The user is "ready" (hand was down or unconfident since last add)
      //   3. This isn't the same letter we just added (extra safety)
      if (arabic != null &&
          _readyForNext &&
          arabic != _lastAppendedLetter) {
        HapticFeedback.lightImpact();
        setState(() {
          _composedText += arabic;
          _detectedLetter = arabic;
          _detectedConfidence = result.confidence;
          _lastAppendedLetter = arabic;
          _readyForNext = false; // 🔧 must lower hand before next add
          _isDetecting = false;
        });
      } else {
        // still confident, but it's the same letter being held — just show
        // it on the camera overlay without re-appending
        setState(() {
          _detectedLetter = arabic;
          _detectedConfidence = result.confidence;
          _isDetecting = false;
        });
      }
    } on TimeoutException {
      _consecutiveFailures++;
      debugPrint('⏱️ [S2T] takePicture timed out '
          '($_consecutiveFailures/$_maxFailuresBeforeRebuild)');
      if (mounted) setState(() => _isDetecting = false);
      await _maybeRebuildController();
    } on CameraException catch (e) {
      _consecutiveFailures++;
      debugPrint('📷 [S2T] CameraException: ${e.code} ${e.description}');
      if (mounted) setState(() => _isDetecting = false);
      await _maybeRebuildController();
    } catch (e, st) {
      _consecutiveFailures++;
      debugPrint('🔴 [S2T] _detectSign threw: $e\n$st');
      if (mounted) setState(() => _isDetecting = false);
      await _maybeRebuildController();
    }
  }

  Future<void> _maybeRebuildController() async {
    if (_consecutiveFailures < _maxFailuresBeforeRebuild) return;
    debugPrint('♻️ [S2T] rebuilding camera after repeated failures');
    _consecutiveFailures = 0;
    _stopCaptureLoop();
    if (mounted) setState(() => _initialized = false);
    await _disposeController();
    if (!mounted) return;
    _initFuture = _setupCamera();
  }

  void _confirmLetter() {
    // 🔧 in auto-append mode this is now a manual override. The letter is
    // usually already in _composedText. We only add if the displayed letter
    // wasn't already appended (e.g. the user held a sign and tapped the
    // button before the next detection cycle ran).
    if (_detectedLetter == null) return;
    if (_detectedLetter == _lastAppendedLetter && !_readyForNext) {
      // already appended by the auto-add logic — nothing to do
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _composedText += _detectedLetter!;
      _lastAppendedLetter = _detectedLetter;
      _readyForNext = false;
      _detectedLetter = null;
      _detectedConfidence = 0;
    });
  }

  void _addSpace() {
    if (_composedText.isEmpty || _composedText.endsWith(' ')) return;
    HapticFeedback.lightImpact();
    setState(() {
      _composedText += ' ';
      // 🔧 a space marks a new word — let the same letter that ended the
      // previous word start the next one (e.g. "بَب" then space then "ب")
      _lastAppendedLetter = null;
      _readyForNext = true;
    });
  }

  void _deleteLast() {
    if (_composedText.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _composedText =
          _composedText.substring(0, _composedText.length - 1);
      // 🔧 user manually removed a letter — let the auto-add system re-add
      // the same letter if the user signs it again immediately
      _lastAppendedLetter = null;
      _readyForNext = true;
    });
  }

  void _clearAll() {
    if (_composedText.isEmpty && _detectedLetter == null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _composedText = '';
      _detectedLetter = null;
      _detectedConfidence = 0;
      _lastAppendedLetter = null;
      _readyForNext = true;
    });
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 🔧 lifecycle
    _stopCaptureLoop();
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      gradient: AppGradients.bgLetters,
      padding: const EdgeInsets.all(AppSpacing.md),
      showDecoration: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppBackButton(color: AppColors.lettersDark),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('أشير وأتعلّم 🤟',
                    style: AppTypography.headlineMedium),
              ),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: AppSpacing.sm),

          // الجملة المكوّنة
          AppCard(
            shadow: AppShadows.colored(AppColors.lettersStart, opacity: 0.25),
            borderColor: AppColors.lettersStart.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: AppGradients.letters,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_note_rounded,
                          color: AppColors.white, size: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'جملتي:',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.lettersDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    _composedText.isEmpty
                        ? 'ابدأ بالإشارة لتكوين جملتك...'
                        : _composedText,
                    textAlign: TextAlign.right,
                    style: _composedText.isEmpty
                        ? AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    )
                        : AppTypography.headlineLarge,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Expanded(
                child: _ToolButton(
                  icon: Icons.space_bar_rounded,
                  label: 'مسافة',
                  color: AppColors.info,
                  onTap: _addSpace,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _ToolButton(
                  icon: Icons.backspace_rounded,
                  label: 'حذف',
                  color: AppColors.accent,
                  onTap: _deleteLast,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _ToolButton(
                  icon: Icons.delete_sweep_rounded,
                  label: 'مسح',
                  color: AppColors.error,
                  onTap: _clearAll,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: AppSpacing.sm),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(
                      color: AppColors.lettersStart, width: 3),
                  boxShadow: AppShadows.colored(AppColors.lettersStart,
                      opacity: 0.3),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FutureBuilder(
                      future: _initFuture,
                      builder: (context, snapshot) {
                        if (_cameraError) return _buildCameraError();
                        if (_controller != null &&
                            _controller!.value.isInitialized) {
                          return FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller!.value.previewSize?.height ?? 1,
                              height: _controller!.value.previewSize?.width ?? 1,
                              child: CameraPreview(_controller!),
                            ),
                          );
                        }
                        return Container(
                          color: Colors.black,
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white),
                            ),
                          ),
                        );
                      },
                    ),

                    // 🔧 frame is now sized as 80% of the camera box's
                    // shortest side — matches the cropRatio used in
                    // sign_api.dart so what the user puts in the frame is
                    // exactly what gets sent to the model.
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final shortSide =
                        constraints.maxWidth < constraints.maxHeight
                            ? constraints.maxWidth
                            : constraints.maxHeight;
                        final size = shortSide * 0.80;
                        return Center(
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.white.withOpacity(0.6),
                                  width: 3),
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg),
                            ),
                          ),
                        );
                      },
                    ),

                    if (_isPaused)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: GestureDetector(
                            onTap: _togglePause,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.button(
                                    AppColors.primary),
                              ),
                              child: const Icon(
                                Icons.pause_rounded,
                                size: 56,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (_detectedLetter != null && !_isPaused)
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md + 4,
                                vertical: AppSpacing.xs + 2),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusXl),
                              boxShadow: AppShadows.large,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('الإشارة المُكتشفة:',
                                    style: AppTypography.caption),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  _detectedLetter!,
                                  style: AppTypography.displayMedium.copyWith(
                                    color: AppColors.lettersDark,
                                    fontSize: 36,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                // 🔧 surface confidence so the user knows
                                // the detection is real (not a guess)
                                Text(
                                  '${(_detectedConfidence * 100).toStringAsFixed(0)}%',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          .animate(key: ValueKey(_detectedLetter))
                          .fadeIn()
                          .scale(
                          begin: const Offset(0.8, 0.8),
                          curve: Curves.elasticOut),

                    if (_detectedLetter != null && !_isPaused)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: _confirmLetter,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl,
                                  vertical: AppSpacing.sm + 4),
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary,
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusHuge),
                                boxShadow: AppShadows.button(
                                    AppColors.primary),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_rounded,
                                      color: AppColors.white, size: 24),
                                  const SizedBox(width: 6),
                                  Text('أضف الحرف',
                                      style: AppTypography.buttonMedium),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn().slideY(begin: 0.3),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: _togglePause,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.medium,
                          ),
                          child: Icon(
                            _isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    if (_isDetecting && !_isPaused)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppGradients.warning,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusCircular),
                            boxShadow: AppShadows.colored(AppColors.accent,
                                opacity: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('جارٍ التحليل',
                                  style: AppTypography.overline.copyWith(
                                    color: AppColors.white,
                                    fontSize: 12,
                                  )),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraError() {
    return Container(
      color: AppColors.textPrimary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_rounded,
                color: Colors.white54, size: 56),
            const SizedBox(height: AppSpacing.sm),
            Text('تعذّر تشغيل الكاميرا',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                )),
            Text('يُرجى التأكّد من منح صلاحية الكاميرا',
                style: AppTypography.caption.copyWith(
                  color: Colors.white54,
                )),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: color, width: 2),
          boxShadow: AppShadows.colored(color, opacity: 0.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

