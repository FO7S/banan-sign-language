/// 🌐 إعدادات التطبيق العامة
class AppConfig {
  AppConfig._();

  /// عنوان الـ Backend API
  static const String baseUrl =
      'https://banan-sign-language-production.up.railway.app';

  /// مدة المهلة للطلبات (ثانية)
  static const int timeoutSeconds = 15;

  /// حد الثقة الأدنى لقبول الإجابة (من الـ Backend: 0.80)
  static const double confidenceThreshold = 0.80;
}
