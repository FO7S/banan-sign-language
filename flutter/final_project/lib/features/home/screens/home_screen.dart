import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../letters/screens/letters_screen.dart';
import '../../words/screens/words_screen.dart';
import '../../challenges/screens/challenges_screen.dart';
import '../../free_space/screens/free_space_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../settings/settings_screen.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    final List<Map<String, dynamic>> paths = [
      {
        'title': 'مسار الحروف',
        'subtitle': 'تعلَّم إشارة كلّ حرف',
        'emoji': '🔤',
        'gradient': AppGradients.letters,
      },
      {
        'title': 'مسار الكلمات',
        'subtitle': 'تهجَّ الكلمات بالإشارة',
        'emoji': '💬',
        'gradient': AppGradients.words,
      },
      {
        'title': 'التحدّيات',
        'subtitle': 'مهامّ صعبة وجمع نقاط',
        'emoji': '⚡',
        'gradient': AppGradients.challenges,
      },
      {
        'title': 'مساحة حرّة',
        'subtitle': 'حوِّل كلامك إلى إشارة',
        'emoji': '🎤',
        'gradient': AppGradients.freeSpace,
      },
    ];

    final List<Widget> screens = [
      const LettersScreen(),
      const WordsScreen(),
      const ChallengesScreen(),
      const FreeSpaceScreen(),
    ];

    return AppScaffold(
      gradient: AppGradients.bgHome,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الهيدر
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أهلاً، ${user.name}!',
                      style: AppTypography.headlineLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'هل أنت مستعدّ للتعلّم اليوم؟ ✨',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // كرت النقاط - 3D bubble
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 2,
                      vertical: AppSpacing.xs + 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.accent,
                        AppColors.warning,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: AppShadows.button(AppColors.accent),
                  ),
                  child: Row(
                    children: [
                      const Text('⭐',
                          style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 6),
                      Text(
                        '${user.points}',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.xs + 2),

              AppIconButton(
                icon: Icons.settings_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ).animate().fadeIn().slideY(begin: -0.2),

          const SizedBox(height: AppSpacing.xl),

          // كرت الأفاتار - أكبر وأكثر جذباً
          Container(
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusXl),
              boxShadow: AppShadows.colored(user.avatarColor,
                  opacity: 0.2),
              border: Border.all(
                color: user.avatarColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // الأفاتار في دائرة gradient
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        user.avatarColor.withOpacity(0.6),
                        user.avatarColor,
                      ],
                    ),
                    boxShadow:
                        AppShadows.colored(user.avatarColor, opacity: 0.4),
                  ),
                  child: Center(
                    child: Text(user.avatarEmoji,
                        style: const TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.avatarName,
                        style: AppTypography.headlineSmall.copyWith(
                          color: user.avatarColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'هيّا نتعلّم إشارة جديدة! 🌟',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

          const SizedBox(height: AppSpacing.lg),

          Text(
            'اختر مسارك 🗺️',
            style: AppTypography.headlineMedium,
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: AppSpacing.sm + 2),



          // // شبكة المسارات - أكبر وأكثر "pop"
          // Expanded(
          //   child: GridView.builder(
          //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //       crossAxisCount: 2,
          //       crossAxisSpacing: AppSpacing.md,
          //       mainAxisSpacing: AppSpacing.md,
          //       childAspectRatio: 0.85,
          //     ),
          //     itemCount: paths.length,
          //     itemBuilder: (context, i) {
          //       final path = paths[i];
          //       return AppGradientCard(
          //         gradient: path['gradient'] as Gradient,
          //         borderRadius: AppSpacing.radiusXl,
          //         padding: const EdgeInsets.all(AppSpacing.md + 2),
          //         onTap: () => Navigator.push(
          //           context,
          //           MaterialPageRoute(builder: (_) => screens[i]),
          //         ),
          //         child: Stack(
          //           children: [
          //             // فقاعة زخرفية في الزاوية
          //             Positioned(
          //               top: -20,
          //               left: -20,
          //               child: Container(
          //                 width: 80,
          //                 height: 80,
          //                 decoration: BoxDecoration(
          //                   shape: BoxShape.circle,
          //                   color: AppColors.white.withOpacity(0.15),
          //                 ),
          //               ),
          //             ),
          //             Column(
          //               mainAxisAlignment:
          //                   MainAxisAlignment.spaceBetween,
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 // الإيموجي في دائرة بيضاء
          //                 Container(
          //                   width: 64,
          //                   height: 64,
          //                   decoration: BoxDecoration(
          //                     shape: BoxShape.circle,
          //                     color: AppColors.white.withOpacity(0.3),
          //                   ),
          //                   child: Center(
          //                     child: Text(
          //                       path['emoji'],
          //                       style: const TextStyle(fontSize: 40),
          //                     ),
          //                   ),
          //                 ),
          //                 Column(
          //                   crossAxisAlignment:
          //                       CrossAxisAlignment.start,
          //                   children: [
          //                     Text(
          //                       path['title'],
          //                       style:
          //                           AppTypography.headlineSmall.copyWith(
          //                         color: AppColors.white,
          //                         fontSize: 18,
          //                       ),
          //                     ),
          //                     const SizedBox(height: 2),
          //                     Text(
          //                       path['subtitle'],
          //                       style: AppTypography.caption.copyWith(
          //                         color: AppColors.white.withOpacity(0.9),
          //                         fontWeight: FontWeight.w700,
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       )
          //           .animate(delay: Duration(milliseconds: 100 * i))
          //           .fadeIn()
          //           .scale(
          //             begin: const Offset(0.85, 0.85),
          //             curve: Curves.elasticOut,
          //           );
          //     },
          //   ),
          // ),



          // قائمة المسارات العموديّة - أزرار مستطيلة متراصّة
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: paths.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm + 2),
              itemBuilder: (context, i) {
                final path = paths[i];
                return AppGradientCard(
                  gradient: path['gradient'] as Gradient,
                  borderRadius: AppSpacing.radiusXl,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md + 2,
                      vertical: AppSpacing.md),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => screens[i]),
                  ),
                  child: Stack(
                    children: [


                      
                      // فقاعة زخرفية في الزاوية
                      // Positioned(
                      //   top: -20,
                      //   left: -20,
                      //   child: Container(
                      //     width: 80,
                      //     height: 80,
                      //     decoration: BoxDecoration(
                      //       shape: BoxShape.circle,
                      //       color: AppColors.white.withOpacity(0.15),
                      //     ),
                      //   ),
                      // ),



                      // فقاعة زخرفية في الزاوية متدرجة التلاشي
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 70,
                          height: 65,
                          decoration: BoxDecoration(
                            // استبدال اللون العادي بتدرج لوني للتلاشي
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppColors.white.withOpacity(0.2), // اللون في أقصى اليسار
                                AppColors.white.withOpacity(0.0), // يتلاشى تماماً عند الوصول لليمين
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              topRight: Radius.zero,
                              bottomRight: Radius.zero,
                            ),
                          ),
                        ),
                      ),



                      Row(
                        children: [
                          // الإيموجي في دائرة بيضاء
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white.withOpacity(0.3),
                            ),
                            child: Center(
                              child: Text(
                                path['emoji'],
                                style: const TextStyle(fontSize: 36),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  path['title'],
                                  style:
                                      AppTypography.headlineSmall.copyWith(
                                    color: AppColors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  path['subtitle'],
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.white.withOpacity(0.9),
                            size: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate(delay: Duration(milliseconds: 100 * i))
                    .fadeIn()
                    .slideX(begin: 0.1, curve: Curves.easeOut);
              },
            ),
          ),




        ],
      ),
    );
  }
}
