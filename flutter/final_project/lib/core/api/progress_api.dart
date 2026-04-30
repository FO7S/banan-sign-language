import '../api/api_client.dart';

/// 📊 خدمة التقدم والإحصائيات
class ProgressApi {
  ProgressApi._();
  static final instance = ProgressApi._();

  final _api = ApiClient.instance;

  /// تقدم اللاعب الكامل
  /// يرجع:
  /// {
  ///   user_id, username, avatar_name, avatar_emoji,
  ///   total_score, best_streak,
  ///   letters_practiced: {...}, letters_count,
  ///   rank,
  ///   achievements: [...]  // الإنجازات الستة
  /// }
  Future<ApiResponse> getProgress(String userId) {
    return _api.get('/progress/$userId');
  }

  /// قائمة أفضل ١٠ لاعبين
  /// يرجع: { leaderboard: [{ rank, user_id, username, total_score, letters_count }] }
  Future<ApiResponse> getLeaderboard() {
    return _api.get('/leaderboard');
  }

  /// إنجازات اللاعب (٦ إنجازات)
  /// يرجع: { achievements: [{ code, unlocked, unlocked_at }] }
  Future<ApiResponse> getAchievements(String userId) {
    return _api.get('/achievements/$userId');
  }
}
