import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../config/app_config.dart';

/// 🤖 خدمة تصنيف الإشارة (Backend)
///
/// قبل الإرسال نُجري ٣ تحضيرات على الصورة لضمان أفضل أداء للنموذج:
///
///   1. 🔄 عكس أفقيّ (flip): الكاميرا الأماميّة تُنتج صور mirrored،
///      والنموذج تدرّب على صور غير معكوسة.
///
///   2. ✂️ قصّ مركزيّ (center-crop): نقصّ مربّعاً في وسط الصورة بنسبة 80%
///      لتركيز انتباه النموذج على منطقة اليد، وتقليل التشويش من الخلفيّة.
///
///   3. 🎚️ جودة JPEG عالية (95): لتقليل ضوضاء الضغط ومساعدة MediaPipe
///      على استخراج landmarks دقيقة.
///
/// كلّ شيء آخر يحدث على Backend:
///   - MediaPipe Hands → 21 landmark
///   - Normalize
///   - TFLite predict → label
class SignApi {
  SignApi._();
  static final instance = SignApi._();

  static const _timeout = Duration(seconds: 8);

  Future<SignClassifyResult?> classify({
    required Uint8List imageBytes,
  }) async {
    try {
      // 🔧 معالجة الصورة في isolate منفصل لتجنّب تجميد الـ UI
      final processedBytes = await compute(_prepareImageForModel, imageBytes);

      final uri = Uri.parse('${AppConfig.baseUrl}/classify/sign');
      final base64Image = base64Encode(processedBytes);

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'image': base64Image}),
          )
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('🔴 [SIGN] HTTP ${response.statusCode}');
        return null;
      }

      final body = jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
      if (body['success'] != true) {
        debugPrint('🔴 [SIGN] success=false: ${body['message']}');
        return null;
      }

      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      final result = SignClassifyResult.fromJson(data);
      debugPrint('🟢 [SIGN] detected=${result.detected} '
          'label=${result.modelLabel} confidence=${result.confidence}');
      return result;
    } catch (e, st) {
      debugPrint('🔴 [SIGN] classify threw: $e\n$st');
      return null;
    }
  }
}

/// 🔧 دالة مستقلّة (top-level) ضروريّة لعمل compute().
/// تُحضّر الصورة قبل إرسالها للنموذج عبر ٣ خطوات.
///
/// النسبة 0.80 للقصّ المركزيّ مختارة بحيث تشمل اليد كاملة عند المسافة
/// الطبيعيّة من الكاميرا، بدون قصّ أصابع. لو وجدت أن المستخدم يحتاج مساحة
/// أوسع، ارفعها لـ 0.90؛ ولو تبي قصّاً أكثر تركيزاً، اخفضها لـ 0.70.
Uint8List _prepareImageForModel(Uint8List inputBytes) {
  // 1️⃣ فكّ ترميز الـ JPEG
  final decoded = img.decodeJpg(inputBytes);
  if (decoded == null) {
    // فشل فكّ الترميز — أرجع الصورة الأصليّة بدلاً من إسقاط الطلب
    return inputBytes;
  }

  // 2️⃣ عكس أفقيّ (لأن الكاميرا الأماميّة تنتج صور معكوسة)
  img.Image processed = img.flipHorizontal(decoded);

  // 3️⃣ قصّ مركزيّ — مربّع في وسط الصورة بنسبة 80% من الأقصر بُعد
  const cropRatio = 0.80;
  final shortSide = processed.width < processed.height
      ? processed.width
      : processed.height;
  final cropSize = (shortSide * cropRatio).round();
  final cropX = ((processed.width - cropSize) / 2).round();
  final cropY = ((processed.height - cropSize) / 2).round();
  processed = img.copyCrop(
    processed,
    x: cropX,
    y: cropY,
    width: cropSize,
    height: cropSize,
  );

  // 4️⃣ إعادة الترميز بجودة عالية (95) لتقليل ضوضاء الضغط
  return Uint8List.fromList(img.encodeJpg(processed, quality: 95));
}

/// 📊 نتيجة التصنيف من Backend
class SignClassifyResult {
  final bool detected;
  final String? modelLabel;
  final double confidence;

  SignClassifyResult({
    required this.detected,
    required this.modelLabel,
    required this.confidence,
  });

  factory SignClassifyResult.fromJson(Map<String, dynamic> json) {
    return SignClassifyResult(
      detected: json['detected'] as bool? ?? false,
      modelLabel: json['label'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static const double confidenceThreshold = 0.70;
  bool get isConfident => confidence >= confidenceThreshold;
}
