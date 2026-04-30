import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../home/providers/user_provider.dart';
import '../../onboarding/screens/avatar_selection_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    // final user = await _authService.getCurrentUser();
    // if (!mounted) return;
    // if (user != null) {
    //   context.read<UserProvider>().setUser(
    //         user['name'] as String,
    //         '🦁',
    //         'ليو',
    //         AppColors.avatarLion,
    //       );
    // }


    final user = await _authService.getCurrentUser();
    if (!mounted) return;
    if (user != null) {
      context.read<UserProvider>().setUser(
            user['name'] as String,
            user['avatarEmoji'] as String? ?? '🦁',
            user['avatarName'] as String? ?? 'ليو',
            user['avatarColor'] != null
                ? Color(user['avatarColor'] as int)
                : AppColors.avatarLion,
            userId: user['id'] as String,
          );
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AvatarSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AppScaffold(
      gradient: AppGradients.bgLogin,
      padding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl + bottomInset * 0.1,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: AppBackButton(),
                      ).animate().fadeIn(),

                      const SizedBox(height: AppSpacing.lg),

                      // الشعار في دائرة gradient
                      // Center(
                      //   child: Container(
                      //     width: 100,
                      //     height: 100,
                      //     decoration: BoxDecoration(
                      //       shape: BoxShape.circle,
                      //       gradient: AppGradients.primary,
                      //       boxShadow:
                      //           AppShadows.button(AppColors.primary),
                      //     ),
                      //     child: const Center(
                      //       child: Text('🤟',
                      //           style: TextStyle(fontSize: 56)),
                      //     ),
                      //   ),
                      // ).animate().scale(curve: Curves.elasticOut),


                      Center(
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                            boxShadow: AppShadows.elevated,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ).animate().scale(curve: Curves.elasticOut),



                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        'أهلاً بعودتك!',
                        textAlign: TextAlign.center,
                        style: AppTypography.displaySmall,
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        'سجّل دخولك وأكمل رحلتك',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: AppSpacing.xxl),

                      AppFormField(
                        controller: _emailController,
                        hint: 'البريد الإلكتروني',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      )
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideX(begin: 0.1),

                      const SizedBox(height: AppSpacing.sm + 2),

                      AppPasswordField(
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleLogin(),
                      )
                          .animate()
                          .fadeIn(delay: 500.ms)
                          .slideX(begin: 0.1),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.sm + 2),
                        AppStatusCard(
                          message: _errorMessage!,
                          type: AppStatusType.error,
                        ).animate().fadeIn().shake(),
                      ],

                      const Spacer(),
                      const SizedBox(height: AppSpacing.lg),

                      // 🌸 زر pastel
                      AppPrimaryButton(
                        label: 'تسجيل الدخول',
                        icon: Icons.login_rounded,
                        gradient: AppGradients.pastelSky,
                        shadowColor: AppColors.pastelSky,
                        textColor: AppColors.pastelButtonText,
                        onTap: _handleLogin,
                        isLoading: _isLoading,
                      )
                          .animate()
                          .fadeIn(delay: 600.ms)
                          .slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
