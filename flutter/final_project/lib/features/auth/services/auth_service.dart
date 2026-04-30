import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api/user_api.dart';

/// 🔐 خدمة المصادقة - تستخدم الـ Backend عبر API
class AuthService {
  static const _keyUserId = 'user_id';
  static const _keyEmail = 'email';
  static const _keyName = 'name';
  static const _keyAvatarEmoji = 'avatar_emoji';
  static const _keyAvatarName = 'avatar_name';
  static const _keyAvatarColor = 'avatar_color';

  // ═══════════════════════════════════════════════
  // 📢 رسائل عامة بالعربية الفصحى
  // ═══════════════════════════════════════════════
  static const String _msgGenericError =
      'تعذّر إتمام العملية، يُرجى المحاولة لاحقاً';
  static const String _msgConnectionError =
      'تعذّر الاتصال بالخادم، يُرجى التحقق من الاتصال والمحاولة مرّة أخرى';
  static const String _msgInvalidCredentials =
      'البريد الإلكتروني أو كلمة السر غير صحيحة';
  static const String _msgRegistrationFailed =
      'تعذّر إنشاء الحساب، يُرجى المحاولة لاحقاً';
  static const String _msgUpdateFailed =
      'تعذّر حفظ التغييرات، يُرجى المحاولة لاحقاً';
  static const String _msgNotLoggedIn = 'لم يتمّ تسجيل الدخول بعد';

  final _userApi = UserApi.instance;
  static const _uuid = Uuid();

  // ═══════════════════════════════════════════════
  // 🆕 تسجيل جديد
  // ═══════════════════════════════════════════════

  Future<String?> register({
    required String email,
    required String name,
    required String password,
  }) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      return 'البريد الإلكتروني غير صالح';
    }
    if (name.trim().isEmpty) {
      return 'الاسم مطلوب';
    }
    if (password.length < 6) {
      return 'يجب ألّا تقلّ كلمة السر عن ستّة أحرف';
    }

    try {
      // ⚠️ نولّد UUID للمستخدم لأن الـ Backend يطلبه من العميل
      final newUserId = _uuid.v4();

      final response = await _userApi.register(
        userId: newUserId,
        username: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (!response.success) {
        // ✅ نُرجع رسالة عامّة بدلاً من رسالة الخادم المباشرة
        return _msgRegistrationFailed;
      }

      // الـ Backend يرجع: { user_id, username, email, ... }
      final data = response.data as Map<String, dynamic>;
      final returnedUserId = data['user_id'] as String? ?? newUserId;

      await _saveUserData(
        userId: returnedUserId,
        email: email.trim().toLowerCase(),
        name: name.trim(),
      );

      return null;
    } catch (_) {
      return _msgConnectionError;
    }
  }

  // ═══════════════════════════════════════════════
  // 🔓 تسجيل الدخول
  // ═══════════════════════════════════════════════

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return 'يُرجى إدخال البريد الإلكتروني وكلمة السر';
    }

    try {
      final response = await _userApi.login(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (!response.success) {
        // ✅ رسالة موحّدة لبيانات الدخول الخاطئة
        return _msgInvalidCredentials;
      }

      // الـ Backend يرجع: { user_id, username, email, avatar_name, avatar_emoji }
      final data = response.data as Map<String, dynamic>;
      await _saveUserData(
        userId: data['user_id'] as String,
        email: data['email'] as String? ?? email.trim().toLowerCase(),
        name: data['username'] as String? ?? '',
        avatarEmoji: data['avatar_emoji'] as String?,
        avatarName: data['avatar_name'] as String?,
      );

      return null;
    } catch (_) {
      return _msgConnectionError;
    }
  }

  // ═══════════════════════════════════════════════
  // 📋 المستخدم الحالي
  // ═══════════════════════════════════════════════

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);
    if (userId == null) return null;

    return {
      'id': userId,
      'email': prefs.getString(_keyEmail),
      'name': prefs.getString(_keyName),
      'avatarEmoji': prefs.getString(_keyAvatarEmoji),
      'avatarName': prefs.getString(_keyAvatarName),
      'avatarColor': prefs.getInt(_keyAvatarColor),
    };
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // ═══════════════════════════════════════════════
  // ✏️ تعديل الاسم
  // ═══════════════════════════════════════════════

  Future<String?> changeName(String newName) async {
    if (newName.trim().isEmpty) return 'لا يمكن أن يكون الاسم فارغاً';

    final userId = await getCurrentUserId();
    if (userId == null) return _msgNotLoggedIn;

    try {
      final response = await _userApi.update(
        userId: userId,
        username: newName.trim(),
      );

      if (!response.success) return _msgUpdateFailed;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyName, newName.trim());
      return null;
    } catch (_) {
      return _msgConnectionError;
    }
  }

  // ═══════════════════════════════════════════════
  // 🔒 تعديل كلمة السر
  // ═══════════════════════════════════════════════

  /// ⚠️ ملاحظة مهمة: الـ Backend الحالي لا يتحقّق من كلمة السر القديمة
  /// نتحقّق منها يدوياً عبر محاولة login بها
  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (newPassword.length < 6) {
      return 'يجب ألّا تقلّ كلمة السر الجديدة عن ستّة أحرف';
    }

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyEmail);
    final userId = prefs.getString(_keyUserId);
    if (email == null || userId == null) return _msgNotLoggedIn;

    try {
      // التحقّق من كلمة السر القديمة عبر login
      final loginCheck = await _userApi.login(
        email: email,
        password: oldPassword,
      );
      if (!loginCheck.success) {
        return 'كلمة السر الحالية غير صحيحة';
      }

      // تحديث كلمة السر
      final response = await _userApi.update(
        userId: userId,
        newPassword: newPassword,
      );

      return response.success ? null : _msgUpdateFailed;
    } catch (_) {
      return _msgConnectionError;
    }
  }

  // ═══════════════════════════════════════════════
  // 🐾 حفظ الأفاتار
  // ═══════════════════════════════════════════════

  Future<String?> saveAvatar({
    required String emoji,
    required String avatarName,
    required int colorValue,
  }) async {
    final userId = await getCurrentUserId();
    if (userId == null) return _msgNotLoggedIn;

    try {
      final response = await _userApi.update(
        userId: userId,
        avatarName: avatarName,
        avatarEmoji: emoji,
      );

      if (!response.success) return _msgUpdateFailed;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAvatarEmoji, emoji);
      await prefs.setString(_keyAvatarName, avatarName);
      await prefs.setInt(_keyAvatarColor, colorValue);
      return null;
    } catch (_) {
      return _msgConnectionError;
    }
  }

  // ═══════════════════════════════════════════════
  // 🚪 تسجيل الخروج
  // ═══════════════════════════════════════════════

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyName);
    await prefs.remove(_keyAvatarEmoji);
    await prefs.remove(_keyAvatarName);
    await prefs.remove(_keyAvatarColor);
  }

  // ═══════════════════════════════════════════════
  // 🔧 Helpers
  // ═══════════════════════════════════════════════

  Future<void> _saveUserData({
    required String userId,
    required String email,
    required String name,
    String? avatarEmoji,
    String? avatarName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyName, name);
    if (avatarEmoji != null) {
      await prefs.setString(_keyAvatarEmoji, avatarEmoji);
    }
    if (avatarName != null) {
      await prefs.setString(_keyAvatarName, avatarName);
    }
  }
}
