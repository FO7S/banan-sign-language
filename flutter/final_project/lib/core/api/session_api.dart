import '../api/api_client.dart';

/// 🎮 أنواع جلسات اللعب (مطابق للـ Backend)
enum SessionMode {
  letter,
  word,
  challenge,
  free,
}

extension SessionModeX on SessionMode {
  String get value => name; // letter, word, challenge, free
}

/// 🎮 خدمة جلسات اللعب
class SessionApi {
  SessionApi._();
  static final instance = SessionApi._();

  final _api = ApiClient.instance;

  /// بدء جلسة جديدة
  /// يرجع: { session_id, mode, created_at }
  Future<ApiResponse> start({
    required String userId,
    required SessionMode mode,
  }) {
    return _api.post('/session/start', {
      'user_id': userId,
      'mode': mode.value,
    });
  }

  /// إنهاء الجلسة
  /// ⚠️ الـ Backend ما يحتاج score/streak — هم محفوظين أصلاً من /challenge/submit
  /// يرجع: { session_id, final_score, final_streak, duration_seconds }
  Future<ApiResponse> end({
    required String sessionId,
    required String userId,
  }) {
    return _api.post('/session/end', {
      'session_id': sessionId,
      'user_id': userId,
    });
  }
}

/// 🎯 خدمة إرسال الإجابات
class ChallengeApi {
  ChallengeApi._();
  static final instance = ChallengeApi._();

  final _api = ApiClient.instance;

  /// إرسال محاولة إجابة (حرف أو كلمة)
  ///
  /// [target] الحرف/الكلمة المطلوبة
  /// [answer] ما تم التعرّف عليه من الموديل
  /// [confidence] درجة الثقة (0.0 - 1.0)
  /// [timeTaken] الوقت المستغرق بالثواني
  ///
  /// يرجع: { correct, score_added, streak, total_session_score }
  Future<ApiResponse> submit({
    required String userId,
    required String sessionId,
    required SessionMode mode,
    required String target,
    required String answer,
    required double confidence,
    required double timeTaken,
  }) {
    return _api.post('/challenge/submit', {
      'user_id': userId,
      'session_id': sessionId,
      'mode': mode.value,
      'target': target,
      'answer': answer,
      'confidence': confidence,
      'time_taken': timeTaken,
    });
  }
}
