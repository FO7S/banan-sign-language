import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/sign_api.dart';
import '../../core/ml/letter_mapping.dart';

class SignCameraBox extends StatefulWidget {
  final String expectedLetter;
  final void Function(bool correct) onResult;
  final Color accentColor;
  final bool isActive;

  const SignCameraBox({
    super.key,
    required this.expectedLetter,
    required this.onResult,
    required this.accentColor,
    this.isActive = true,
  });

  @override
  State<SignCameraBox> createState() => _SignCameraBoxState();
}

enum _DetectionState {
  idle,
  waiting,
  detecting,
  wrongLetter,
  matched,
}

// 🔧 FIX: implement WidgetsBindingObserver to react to app lifecycle changes
class _SignCameraBoxState extends State<SignCameraBox>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initFuture;

  bool _isProcessing = false;
  bool _cameraError = false;
  bool _initialized = false;
  String _statusText = 'جارٍ تشغيل الكاميرا...';

  bool _captureLoopRunning = false;

  // 🔧 FIX: track consecutive failures so we can rebuild the controller
  int _consecutiveFailures = 0;
  static const int _maxFailuresBeforeRebuild = 3;

  SignClassifyResult? _lastResult;
  _DetectionState _detectionState = _DetectionState.idle;

  bool _resultEmitted = false;

  static const Duration _delayBetweenCaptures = Duration(milliseconds: 1000);
  // 🔧 FIX: hard timeout on every capture so a hung call can never freeze the loop
  static const Duration _captureTimeout = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 🔧 FIX
    _initFuture = _setupCamera();
  }

  // 🔧 FIX: critical — on Android/iOS the camera is released when the app
  // is backgrounded. We must dispose and re-init on resume, otherwise every
  // subsequent takePicture() call will hang forever.
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
        setState(() {
          _cameraError = true;
          _statusText = 'لا توجد كاميرا متاحة';
        });
        return;
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // 🔧 FIX: dispose any stale controller from a previous lifecycle
      await _disposeController();

      _controller = CameraController(
        frontCamera,
        // 🔧 FIX: medium = 480p which is too low for the model to distinguish
        // similar hand signs (ب / ت / ث differ in finger details). high = 720p
        // gives MediaPipe enough detail without blowing up payload size.
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) {
        await _disposeController();
        return;
      }
      setState(() {
        _initialized = true;
        _cameraError = false;
        _statusText = 'قم بالإشارة 👋';
        _detectionState = _DetectionState.waiting;
      });

      _consecutiveFailures = 0;
      _startCaptureLoop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = true;
        _statusText = 'تعذّر تشغيل الكاميرا';
      });
    }
  }

  void _startCaptureLoop() async {
    if (_captureLoopRunning) return;
    _captureLoopRunning = true;

    while (_captureLoopRunning && mounted && !_resultEmitted) {
      if (widget.isActive && _initialized && !_cameraError) {
        await _captureAndClassify();
      }
      await Future.delayed(_delayBetweenCaptures);
    }
  }

  void _stopCaptureLoop() {
    _captureLoopRunning = false;
  }

  Future<void> _captureAndClassify() async {
    if (_isProcessing ||
        !_initialized ||
        !mounted ||
        !widget.isActive ||
        _resultEmitted) {
      return;
    }
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    _isProcessing = true;
    if (mounted) setState(() {});

    try {
      final xfile = await _controller!
          .takePicture()
          .timeout(_captureTimeout);
      final bytes = await xfile.readAsBytes();

      // 🔧 FIX: takePicture() writes a JPEG to disk every call. If we don't
      // delete it, after ~2-3 minutes at 1 capture/sec the cache fills up
      // and the OS blocks the main isolate doing cleanup → whole app freezes.
      unawaited(File(xfile.path).delete().catchError((_) => File(xfile.path)));

      if (!mounted || _resultEmitted) return;

      final result = await SignApi.instance
          .classify(imageBytes: bytes)
          .timeout(const Duration(seconds: 8), onTimeout: () => null);

      if (!mounted || _resultEmitted) return;

      // success → reset failure counter
      _consecutiveFailures = 0;

      if (result == null) {
        if (mounted &&
            _statusText != 'تعذّر الاتصال، نحاول مرّة أخرى') {
          setState(() => _statusText = 'تعذّر الاتصال، نحاول مرّة أخرى');
        }
        return;
      }

      if (!result.detected) {
        if (mounted) {
          setState(() {
            _lastResult = null;
            _detectionState = _DetectionState.waiting;
            _statusText = 'لم نرَ يدك بعد، اقترب من الكاميرا';
          });
        }
        return;
      }

      final detectedArabic = result.modelLabel != null
          ? LetterMapping.toArabic(result.modelLabel!)
          : null;

      final isMatch = result.modelLabel != null &&
          LetterMapping.matches(result.modelLabel!, widget.expectedLetter);

      if (!result.isConfident) {
        if (mounted) {
          setState(() {
            _lastResult = result;
            _detectionState = _DetectionState.detecting;
            _statusText = 'استمرّ، نحاول التعرّف...';
          });
        }
        return;
      }

      if (isMatch) {
        if (mounted) {
          setState(() {
            _lastResult = result;
            _detectionState = _DetectionState.matched;
            _statusText = '✅ ممتاز!';
          });
        }
        _emitResult(correct: true);
      } else {
        if (mounted) {
          setState(() {
            _lastResult = result;
            _detectionState = _DetectionState.wrongLetter;
            _statusText =
                'اكتشفنا "${detectedArabic ?? '?'}" - حاول مرّة أخرى';
          });
        }
      }
    } on TimeoutException catch (_) {
      // 🔧 FIX: a hung capture is the #1 cause of the freeze you're seeing
      _consecutiveFailures++;
      debugPrint('⏱️ [CAM] takePicture timed out '
          '($_consecutiveFailures/$_maxFailuresBeforeRebuild)');
      await _maybeRebuildController();
    } on CameraException catch (e) {
      _consecutiveFailures++;
      debugPrint('📷 [CAM] CameraException: ${e.code} ${e.description}');
      await _maybeRebuildController();
    } catch (e) {
      _consecutiveFailures++;
      debugPrint('📷 [CAM] unknown error: $e');
      await _maybeRebuildController();
    } finally {
      _isProcessing = false;
      if (mounted) setState(() {});
    }
  }

  // 🔧 FIX: if the controller has gone bad, tear it down and rebuild instead
  // of looping forever on a broken instance
  Future<void> _maybeRebuildController() async {
    if (_consecutiveFailures < _maxFailuresBeforeRebuild) return;
    debugPrint('♻️ [CAM] Too many failures — rebuilding controller');
    _consecutiveFailures = 0;
    _stopCaptureLoop();
    if (mounted) {
      setState(() {
        _initialized = false;
        _statusText = 'إعادة تشغيل الكاميرا...';
      });
    }
    await _disposeController();
    if (!mounted) return;
    _initFuture = _setupCamera();
  }

  void _emitResult({required bool correct}) {
    if (_resultEmitted) return;
    _resultEmitted = true;
    _stopCaptureLoop();
    widget.onResult(correct);
  }

  @override
  void didUpdateWidget(covariant SignCameraBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.expectedLetter != widget.expectedLetter ||
        oldWidget.isActive != widget.isActive) {
      _resultEmitted = false;
      _lastResult = null;
      _detectionState = _DetectionState.waiting;

      if (widget.isActive && !_captureLoopRunning) {
        if (mounted) setState(() => _statusText = 'قم بالإشارة 👋');
        _startCaptureLoop();
      } else if (!widget.isActive) {
        _stopCaptureLoop();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 🔧 FIX
    _stopCaptureLoop();
    _disposeController();
    super.dispose();
  }

  Color get _frameColor {
    switch (_detectionState) {
      case _DetectionState.matched:
        return const Color(0xFF2ED573);
      case _DetectionState.wrongLetter:
        return const Color(0xFFFFA502);
      case _DetectionState.detecting:
        return const Color(0xFFFFD43B);
      case _DetectionState.waiting:
      case _DetectionState.idle:
        return Colors.white.withOpacity(0.5);
    }
  }

  /// 🔧 نسبة الإطار البصريّ من أصغر بُعد للصندوق.
  /// لازم تطابق `cropRatio` في sign_api.dart بحيث المستخدم يضع يده
  /// في المنطقة نفسها التي يقصّها التطبيق ويرسلها للسيرفر.
  ///
  /// النسبة الأساسية 0.80 = 80% (نفس cropRatio).
  /// نزيدها قليلاً عند المطابقة (matched) كردّ فعل بصريّ.
  double get _frameFraction {
    switch (_detectionState) {
      case _DetectionState.matched:
        return 0.86; // يكبر عند النجاح
      case _DetectionState.wrongLetter:
      case _DetectionState.detecting:
        return 0.82;
      case _DetectionState.waiting:
      case _DetectionState.idle:
        return 0.80; // يطابق cropRatio في sign_api.dart
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _detectionState == _DetectionState.matched
                ? const Color(0xFF2ED573)
                : (_isProcessing
                    ? widget.accentColor
                    : widget.accentColor.withOpacity(0.4)),
            width: _detectionState == _DetectionState.matched ? 4 : 2,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder(
              future: _initFuture,
              builder: (context, snapshot) {
                if (_cameraError) return _buildErrorFallback();
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              },
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.55),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 🔧 الإطار البصريّ — حجمه نسبة من أصغر بُعد للصندوق (80% افتراضياً)
            // ليطابق منطقة القصّ التي يُرسلها التطبيق للسيرفر فعلياً.
            LayoutBuilder(
              builder: (context, constraints) {
                final shortSide = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight;
                final size = shortSide * _frameFraction;
                return Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      border: Border.all(color: _frameColor, width: 3),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: _detectionState == _DetectionState.matched
                          ? [
                              BoxShadow(
                                color: _frameColor.withOpacity(0.6),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        ...['tl', 'tr', 'bl', 'br'].map(_buildCornerDot),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_isProcessing)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('جارٍ التحليل',
                          style: GoogleFonts.tajawal(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
              ),
            if (_lastResult != null && _lastResult!.modelLabel != null)
              Positioned(
                top: 12,
                left: 12,
                child: _buildDetectionCard(),
              ),
            Positioned(
              right: 12,
              bottom: 60,
              child: _buildHitsIndicator(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _statusText,
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerDot(String position) {
    final dot = Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _frameColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: _frameColor.withOpacity(0.7), blurRadius: 6),
        ],
      ),
    );
    return Positioned(
      top: position.startsWith('t') ? -6 : null,
      bottom: position.startsWith('b') ? -6 : null,
      left: position.endsWith('l') ? -6 : null,
      right: position.endsWith('r') ? -6 : null,
      child: dot,
    );
  }

  Widget _buildDetectionCard() {
    final arabic =
        LetterMapping.toArabic(_lastResult!.modelLabel!) ?? '?';
    final pct = (_lastResult!.confidence * 100).toStringAsFixed(0);
    final isMatch = arabic == widget.expectedLetter;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMatch
              ? const Color(0xFF2ED573)
              : Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('اكتُشف',
              style: GoogleFonts.tajawal(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(arabic,
                  style: GoogleFonts.tajawal(
                    color: isMatch
                        ? const Color(0xFF2ED573)
                        : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  )),
              const SizedBox(width: 8),
              Text('$pct%',
                  style: GoogleFonts.tajawal(
                    color: isMatch
                        ? const Color(0xFF2ED573)
                        : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHitsIndicator() => const SizedBox.shrink();

  Widget _buildErrorFallback() {
    return Container(
      color: const Color(0xFF2D3436),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography_rounded,
                  color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              Text(_statusText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  )),
              const SizedBox(height: 4),
              Text('يُرجى التأكّد من منح صلاحية الكاميرا',
                  style: GoogleFonts.tajawal(
                    color: Colors.white54,
                    fontSize: 12,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
