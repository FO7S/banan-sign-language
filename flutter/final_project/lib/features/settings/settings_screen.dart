import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../auth/screens/welcome_screen.dart';
import '../auth/services/auth_service.dart';
import '../home/providers/user_provider.dart';
import '../onboarding/screens/avatar_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return AppScaffold(
      gradient: AppGradients.bgHome,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppIconButton(
                icon: Icons.home_rounded,
                onTap: () => Navigator.pop(context),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: AppShadows.colored(user.avatarColor,
                      opacity: 0.2),
                  border: Border.all(
                      color: user.avatarColor.withOpacity(0.3), width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            user.avatarColor.withOpacity(0.6),
                            user.avatarColor,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(user.avatarEmoji,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.name,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          user.avatarName,
                          style: AppTypography.overline.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: AppSpacing.xl),

          Text('الإعدادات ⚙️',
                  style: AppTypography.displaySmall)
              .animate()
              .fadeIn(delay: 100.ms),

          const SizedBox(height: AppSpacing.xxs),

          Text('غيِّر إعدادات حسابك',
                  style: AppTypography.bodySmall)
              .animate()
              .fadeIn(delay: 150.ms),

          const SizedBox(height: AppSpacing.xl + 4),

          _SettingButton(
            icon: Icons.person_rounded,
            title: 'تغيير الاسم',
            subtitle: user.name,
            color: AppColors.primary,
            onTap: _showChangeNameDialog,
            delay: 200,
          ),
          const SizedBox(height: AppSpacing.sm + 2),

          _SettingButton(
            icon: Icons.lock_rounded,
            title: 'تغيير كلمة السر',
            subtitle: '••••••••',
            color: AppColors.info,
            onTap: _showChangePasswordDialog,
            delay: 250,
          ),
          const SizedBox(height: AppSpacing.sm + 2),

          _SettingButton(
            icon: Icons.pets_rounded,
            title: 'تغيير رفيق الرحلة',
            subtitle: '${user.avatarEmoji}  ${user.avatarName}',
            color: AppColors.accent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AvatarSelectionScreen(isEditing: true),
              ),
            ),
            delay: 300,
          ),

          const Spacer(),

          // زر تسجيل الخروج 3D
          GestureDetector(
            onTap: _showLogoutConfirmation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md + 4),
              decoration: BoxDecoration(
                gradient: AppGradients.error,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow:
                    AppShadows.button(AppColors.errorStrong),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded,
                      color: AppColors.white, size: 22),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Text('تسجيل الخروج',
                      style: AppTypography.buttonMedium),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }

  void _showChangeNameDialog() {
    final controller =
        TextEditingController(text: context.read<UserProvider>().name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
        title: Row(
          children: [
            const Text('✏️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.sm),
            Text('تغيير الاسم',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                )),
          ],
        ),
        content: AppFormField(
          controller: controller,
          hint: 'الاسم الجديد',
          icon: Icons.person_rounded,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                )),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd)),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            ),
            onPressed: () async {
              final newName = controller.text.trim();
              final error = await _authService.changeName(newName);
              if (!mounted) return;
              if (error != null) {
                _showSnack(error, isError: true);
                return;
              }
              context.read<UserProvider>().updateName(newName);
              Navigator.pop(ctx);
              _showSnack('تمّ تغيير الاسم بنجاح ✓');
            },
            child: Text('حفظ', style: AppTypography.buttonSmall),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
        title: Row(
          children: [
            const Text('🔒', style: TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.sm),
            Text('تغيير كلمة السر',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.info,
                )),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppPasswordField(
                controller: oldController, hint: 'كلمة السر الحالية'),
            const SizedBox(height: AppSpacing.sm),
            AppPasswordField(
                controller: newController, hint: 'كلمة السر الجديدة'),
            const SizedBox(height: AppSpacing.sm),
            AppPasswordField(
                controller: confirmController,
                hint: 'تأكيد كلمة السر الجديدة'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                )),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd)),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            ),
            onPressed: () async {
              if (newController.text != confirmController.text) {
                _showSnack('كلمتا السر الجديدة غير متطابقتين',
                    isError: true);
                return;
              }
              final error = await _authService.changePassword(
                oldPassword: oldController.text,
                newPassword: newController.text,
              );
              if (!mounted) return;
              if (error != null) {
                _showSnack(error, isError: true);
                return;
              }
              Navigator.pop(ctx);
              _showSnack('تمّ تغيير كلمة السر بنجاح ✓');
            },
            child: Text('حفظ', style: AppTypography.buttonSmall),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
        title: Row(
          children: [
            const Text('👋', style: TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.sm),
            Text('تسجيل الخروج',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.errorStrong,
                )),
          ],
        ),
        content: Text('هل أنت متأكّد من رغبتك في تسجيل الخروج؟',
            style: AppTypography.bodyMedium, textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                )),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorStrong,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd)),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            ),
            onPressed: () async {
              await _authService.logout();
              if (!mounted) return;
              context.read<UserProvider>().clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: Text('نعم، تسجيل الخروج',
                style: AppTypography.buttonSmall),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white,
            )),
        backgroundColor:
            isError ? AppColors.errorStrong : AppColors.success,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SettingButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final int delay;

  const _SettingButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderRadius: AppSpacing.radiusXl,
      shadow: AppShadows.colored(color, opacity: 0.15),
      child: Row(
        children: [
          // أيقونة في دائرة gradient
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
              ),
              boxShadow: AppShadows.colored(color, opacity: 0.3),
            ),
            child: Icon(icon, color: AppColors.white, size: 28),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headlineSmall),
                Text(
                  subtitle,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left_rounded,
              color: color, size: 24),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn()
        .slideX(begin: 0.1);
  }
}
