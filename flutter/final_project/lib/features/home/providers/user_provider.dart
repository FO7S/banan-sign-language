import 'package:flutter/material.dart';

/// 🧑 Provider للمستخدم الحالي - يدير حالة المستخدم في الـ UI
class UserProvider extends ChangeNotifier {
  String _userId = ''; // 🆕 UUID من الـ Backend
  String _name = '';
  String _avatarEmoji = '🦁';
  String _avatarName = 'ليو';
  Color _avatarColor = const Color(0xFFFFAA3D);
  int _points = 0;
  int _streak = 0;
  int _lettersLearned = 0;
  int _wordsLearned = 0;

  // ═══ Getters ═══
  String get userId => _userId;
  String get name => _name;
  String get avatarEmoji => _avatarEmoji;
  String get avatarName => _avatarName;
  Color get avatarColor => _avatarColor;
  int get points => _points;
  int get streak => _streak;
  int get lettersLearned => _lettersLearned;
  int get wordsLearned => _wordsLearned;

  /// تعيين بيانات المستخدم الكاملة
  void setUser(
    String name,
    String emoji,
    String avatarName,
    Color color, {
    String userId = '',
  }) {
    _name = name;
    _avatarEmoji = emoji;
    _avatarName = avatarName;
    _avatarColor = color;
    if (userId.isNotEmpty) _userId = userId;
    notifyListeners();
  }

  /// تعيين الـ userId فقط
  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }

  /// تحديث الاسم فقط
  void updateName(String newName) {
    _name = newName;
    notifyListeners();
  }

  /// تحديث الأفاتار
  void updateAvatar(String emoji, String avatarName, Color color) {
    _avatarEmoji = emoji;
    _avatarName = avatarName;
    _avatarColor = color;
    notifyListeners();
  }

  /// إضافة نقاط (محلياً قبل الـ sync مع الـ Backend)
  void addPoints(int amount) {
    _points += amount;
    notifyListeners();
  }

  /// تعيين النقاط مباشرة (من الـ Backend)
  void setPoints(int points) {
    _points = points;
    notifyListeners();
  }

  /// تعيين الـ streak (من الـ Backend)
  void setStreak(int streak) {
    _streak = streak;
    notifyListeners();
  }

  /// زيادة عدد الحروف المتعلَّمة
  void addLetterLearned() {
    _lettersLearned++;
    notifyListeners();
  }

  /// زيادة عدد الكلمات المتعلَّمة
  void addWordLearned() {
    _wordsLearned++;
    notifyListeners();
  }

  /// تحديث الإحصائيات الكاملة (من الـ Backend)
  void updateStats({
    int? points,
    int? streak,
    int? lettersLearned,
    int? wordsLearned,
  }) {
    if (points != null) _points = points;
    if (streak != null) _streak = streak;
    if (lettersLearned != null) _lettersLearned = lettersLearned;
    if (wordsLearned != null) _wordsLearned = wordsLearned;
    notifyListeners();
  }

  /// مسح كل البيانات (عند تسجيل الخروج)
  void clear() {
    _userId = '';
    _name = '';
    _avatarEmoji = '🦁';
    _avatarName = 'ليو';
    _avatarColor = const Color(0xFFFFAA3D);
    _points = 0;
    _streak = 0;
    _lettersLearned = 0;
    _wordsLearned = 0;
    notifyListeners();
  }
}
