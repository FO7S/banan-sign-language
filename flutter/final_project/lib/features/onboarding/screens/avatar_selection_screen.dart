import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/services/auth_service.dart';
import '../../home/providers/user_provider.dart';
import '../../home/screens/home_screen.dart';

class AvatarSelectionScreen extends StatefulWidget {
  final bool isEditing;
  const AvatarSelectionScreen({super.key, this.isEditing = false});

  @override
  State<AvatarSelectionScreen> createState() =>
      _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  int selectedAvatar = -1;
  final _authService = AuthService();

  final List<Map<String, dynamic>> avatars = const [
    {'emoji': '🦁', 'name': 'ليو', 'color': AppColors.avatarLion},
    {'emoji': '🐬', 'name': 'دولفي', 'color': AppColors.avatarDolphin},
    {'emoji': '🦊', 'name': 'فوكسي', 'color': AppColors.avatarFox},
    {'emoji': '🐼', 'name': 'باندا', 'color': AppColors.avatarPanda},
    {'emoji': '🦄', 'name': 'يونيكورن', 'color': AppColors.avatarUnicorn},
    {'emoji': '🐸', 'name': 'فروجي', 'color': AppColors.avatarFrog},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final currentEmoji = context.read<UserProvider>().avatarEmoji;
      final idx = avatars.indexWhere((a) => a['emoji'] == currentEmoji);
      if (idx != -1) selectedAvatar = idx;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<UserProvider>().name;

    return AppScaffold(
      gradient: AppGradients.bgHome,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          if (widget.isEditing)
            const Align(
              alignment: Alignment.centerLeft,
              child: AppBackButton(),
            ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            widget.isEditing
                ? 'غيِّر رفيقك'
                : 'مرحباً بك يا $userName',
            style: AppTypography.displaySmall.copyWith(fontSize: 30),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(begin: -0.2),

          const SizedBox(height: AppSpacing.xs + 2),

          Text(
            widget.isEditing
                ? 'اختر رفيقك الجديد'
                : 'اختر رفيق رحلتك لتبدأ التعلّم',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: AppSpacing.xl),

          // كرت تنبيهي
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 32)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'سيرافقك هذا الصديق طوال رحلتك',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: AppSpacing.lg),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: avatars.length,
              itemBuilder: (context, i) {
                final isSelected = selectedAvatar == i;
                final color = avatars[i]['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => selectedAvatar = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [color.withOpacity(0.7), color],
                            )
                          : null,
                      color: isSelected ? null : AppColors.white,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusXl),
                      border: Border.all(
                        color: isSelected ? color : AppColors.borderLight,
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: isSelected
                          ? AppShadows.button(color)
                          : AppShadows.small,
                    ),
                    transform: isSelected
                        ? (Matrix4.identity()..scale(1.05))
                        : Matrix4.identity(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(avatars[i]['emoji'],
                            style: const TextStyle(fontSize: 44)),
                        const SizedBox(height: 6),
                        Text(
                          avatars[i]['name'],
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: Duration(milliseconds: 100 * i))
                    .fadeIn()
                    .scale(begin: const Offset(0.8, 0.8));
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          AppPrimaryButton(
            label: widget.isEditing ? 'حفظ التغيير' : 'لنبدأ الآن',
            onTap: () async {
              if (selectedAvatar == -1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'يُرجى اختيار شخصية أوّلاً',
                      style: AppTypography.bodyMedium,
                    ),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              final a = avatars[selectedAvatar];
              final emoji = a['emoji'] as String;
              final avatarName = a['name'] as String;
              final color = a['color'] as Color;

              final error = await _authService.saveAvatar(
                emoji: emoji,
                avatarName: avatarName,
                colorValue: color.value,
              );

              if (!mounted) return;

              // ✅ في حال فشل حفظ الأفاتار في الـ Backend، نعرض رسالة عامّة
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      error,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    backgroundColor: AppColors.errorStrong,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              if (widget.isEditing) {
                context
                    .read<UserProvider>()
                    .updateAvatar(emoji, avatarName, color);
                Navigator.pop(context);
              } else {
                final user = context.read<UserProvider>();
                context
                    .read<UserProvider>()
                    .setUser(user.name, emoji, avatarName, color);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }
}
