import '../api/api_client.dart';

/// 👤 خدمة المستخدمين - تسجيل، دخول، تحديث
class UserApi {
  UserApi._();
  static final instance = UserApi._();

  final _api = ApiClient.instance;

  /// تسجيل مستخدم جديد
  /// ⚠️ الـ Backend يطلب user_id (UUID) من العميل
  Future<ApiResponse> register({
    required String userId,
    required String username,
    required String email,
    required String password,
    String? avatarName,
    String? avatarEmoji,
  }) {
    return _api.post('/user/register', {
      'user_id': userId,
      'username': username,
      'email': email,
      'password': password,
      if (avatarName != null) 'avatar_name': avatarName,
      if (avatarEmoji != null) 'avatar_emoji': avatarEmoji,
    });
  }

  /// تسجيل الدخول
  Future<ApiResponse> login({
    required String email,
    required String password,
  }) {
    return _api.post('/user/login', {
      'email': email,
      'password': password,
    });
  }

  /// تحديث بيانات المستخدم (الاسم/الأفاتار/كلمة السر)
  /// ⚠️ الـ Backend يقبل password واحد فقط (ما يتحقق من القديم)
  Future<ApiResponse> update({
    required String userId,
    String? username,
    String? avatarName,
    String? avatarEmoji,
    String? newPassword,
  }) {
    return _api.put('/user/update', {
      'user_id': userId,
      if (username != null) 'username': username,
      if (avatarName != null) 'avatar_name': avatarName,
      if (avatarEmoji != null) 'avatar_emoji': avatarEmoji,
      if (newPassword != null) 'password': newPassword,
    });
  }

  /// عرض بيانات مستخدم معين
  Future<ApiResponse> get(String userId) {
    return _api.get('/user/$userId');
  }
}
