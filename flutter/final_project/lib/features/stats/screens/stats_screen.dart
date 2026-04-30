import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/api/progress_api.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../home/providers/user_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _progress;
  List<dynamic>? _leaderboard;
  List<dynamic>? _achievements;

  // ═══════════════════════════════════════════════
  // 📢 رسائل عامة بالعربية الفصحى
  // ═══════════════════════════════════════════════
  static const String _msgGenericError =
      'تعذّر تحميل الإحصائيات، يُرجى المحاولة لاحقاً';
  static const String _msgNotLoggedIn =
      'يُرجى تسجيل الدخول أوّلاً لعرض الإحصائيات';

  final _progressApi = ProgressApi.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = context.read<UserProvider>().userId;
    if (userId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = _msgNotLoggedIn;
      });
      return;
    }

    try {
      // ⚠️ /progress يرجع كل شي (including achievements)، فما نحتاج call منفصل
      final results = await Future.wait([
        _progressApi.getProgress(userId),
        _progressApi.getLeaderboard(),
      ]);

      if (!mounted) return;

      final progressRes = results[0];
      final leaderboardRes = results[1];

      if (!progressRes.success) {
        setState(() {
          _isLoading = false;
          // ✅ رسالة عامّة بدلاً من رسالة الخادم
          _errorMessage = _msgGenericError;
        });
        return;
      }

      final progressData = progressRes.data as Map<String, dynamic>?;

      List<dynamic>? leaderboardData;
      if (leaderboardRes.success) {
        final data = leaderboardRes.data as Map<String, dynamic>?;
        leaderboardData = data?['leaderboard'] as List<dynamic>?;
      }

      setState(() {
        _isLoading = false;
        _progress = progressData;
        _achievements = progressData?['achievements'] as List<dynamic>?;
        _leaderboard = leaderboardData;
      });

      // تحديث الـ provider بالبيانات الجديدة
      if (_progress != null) {
        final user = context.read<UserProvider>();
        user.updateStats(
          points: _progress!['total_score'] as int? ?? 0,
          streak: _progress!['best_streak'] as int? ?? 0,
          lettersLearned: _progress!['letters_count'] as int? ?? 0,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _msgGenericError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      gradient: AppGradients.bgHome,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppBackButton(),
              const SizedBox(width: AppSpacing.sm),
              Text('إحصائياتي 📊', style: AppTypography.headlineLarge),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: AppSpacing.lg),

          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            )
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 64, color: AppColors.error),
                    const SizedBox(height: AppSpacing.md),
                    Text(_errorMessage!,
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.md),
                    AppPrimaryButton(
                      label: 'إعادة المحاولة',
                      icon: Icons.refresh_rounded,
                      onTap: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMainStatsCard(),
                    const SizedBox(height: AppSpacing.md),

                    // 🏆 قسم الإنجازات
                    Text('الإنجازات 🏆',
                            style: AppTypography.headlineMedium)
                        .animate()
                        .fadeIn(delay: 200.ms),
                    const SizedBox(height: AppSpacing.sm),
                    if (_achievements != null && _achievements!.isNotEmpty)
                      _buildAchievements()
                    else
                      _buildEmptyState(
                        emoji: '🎯',
                        message:
                            'لم تحصل على أيّ إنجاز بعد، ابدأ التعلّم لفتح إنجازاتك الأولى!',
                      ),
                    const SizedBox(height: AppSpacing.md),

                    // ⭐ قسم المتصدّرين
                    Text('المتصدّرون ⭐',
                            style: AppTypography.headlineMedium)
                        .animate()
                        .fadeIn(delay: 400.ms),
                    const SizedBox(height: AppSpacing.sm),
                    if (_leaderboard != null && _leaderboard!.isNotEmpty)
                      _buildLeaderboard()
                    else
                      _buildEmptyState(
                        emoji: '🏅',
                        message:
                            'لا توجد بيانات للمتصدّرين حالياً، كن أوّل من يتصدّر القائمة!',
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 🆕 بطاقة موحّدة لعرض حالات الفراغ بشكل ودّي
  Widget _buildEmptyState({
    required String emoji,
    required String message,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildMainStatsCard() {
    final score = _progress?['total_score'] as int? ?? 0;
    final bestStreak = _progress?['best_streak'] as int? ?? 0;
    final rank = _progress?['rank'] as int? ?? 0;
    // ⚠️ نستخدم letters_count من الـ Backend مباشرة
    final lettersCount = _progress?['letters_count'] as int? ?? 0;

    return AppGradientCard(
      gradient: AppGradients.primary,
      borderRadius: AppSpacing.radiusXl,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('⭐', '$score', 'نقطة'),
              _statItem('🔥', '$bestStreak', 'أفضل سلسلة'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
              height: 1, color: AppColors.white.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('🔤', '$lettersCount', 'حرف'),
              _statItem('🏅', rank > 0 ? '#$rank' : '-', 'الترتيب'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _statItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.white,
              fontSize: 28,
            )),
        Text(label,
            style: AppTypography.caption.copyWith(
              color: AppColors.white.withOpacity(0.85),
              fontWeight: FontWeight.w800,
            )),
      ],
    );
  }

  Widget _buildAchievements() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.85,
      ),
      itemCount: _achievements!.length,
      itemBuilder: (context, i) {
        final ach = _achievements![i] as Map<String, dynamic>;
        final unlocked = ach['unlocked'] as bool? ?? false;
        final code = ach['code'] as String? ?? '';
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          shadow: unlocked
              ? AppShadows.colored(AppColors.accent, opacity: 0.25)
              : AppShadows.small,
          borderColor: unlocked
              ? AppColors.accent.withOpacity(0.5)
              : AppColors.borderLight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: unlocked ? 1 : 0.3,
                child: Text(
                  _achievementEmoji(code),
                  style: const TextStyle(fontSize: 36),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _achievementName(code),
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w900,
                  color: unlocked
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: 100 * i)).fadeIn().scale(
            begin: const Offset(0.85, 0.85),
            curve: Curves.elasticOut);
      },
    );
  }

  Widget _buildLeaderboard() {
    return Column(
      children: List.generate(_leaderboard!.length, (i) {
        final entry = _leaderboard![i] as Map<String, dynamic>;
        // ⚠️ rank يجي من الـ Backend مباشرة
        final rank = entry['rank'] as int? ?? (i + 1);
        final username = entry['username'] as String? ?? '-';
        final score = entry['total_score'] as int? ?? 0;
        // ⚠️ leaderboard من الـ Backend ما يرجع avatar_emoji
        final isMe =
            entry['user_id'] == context.read<UserProvider>().userId;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: AppCard(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            backgroundColor: isMe ? AppColors.primarySoft : AppColors.white,
            borderColor: isMe ? AppColors.primary : null,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _rankColor(rank),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      rank <= 3 ? _rankMedal(rank) : '$rank',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        fontSize: rank <= 3 ? 20 : 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    username + (isMe ? ' (أنت)' : ''),
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppBadge(
                  label: '$score',
                  icon: Icons.star_rounded,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        )
            .animate(delay: Duration(milliseconds: 50 * i))
            .fadeIn()
            .slideX(begin: 0.1);
      }),
    );
  }

  String _achievementEmoji(String code) {
    switch (code) {
      case 'first_letter':
        return '🌱';
      case 'pro_speller':
        return '💯';
      case 'sign_speaker':
        return '🎤';
      case 'challenge_hero':
        return '⚡';
      case 'fire_streak':
        return '🔥';
      case 'leaderboard_star':
        return '🌟';
      default:
        return '🏆';
    }
  }

  String _achievementName(String code) {
    switch (code) {
      case 'first_letter':
        return 'أوّل حرف';
      case 'pro_speller':
        return 'مهجٍّ محترف';
      case 'sign_speaker':
        return 'ناطق بالإشارة';
      case 'challenge_hero':
        return 'بطل التحدّيات';
      case 'fire_streak':
        return 'سلسلة متّقدة';
      case 'leaderboard_star':
        return 'نجم الترتيب';
      default:
        return '-';
    }
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.accent;
      case 2:
        return AppColors.textMuted;
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primary;
    }
  }

  String _rankMedal(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }
}
