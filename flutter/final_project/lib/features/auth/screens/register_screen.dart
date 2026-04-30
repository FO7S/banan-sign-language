import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../home/providers/user_provider.dart';
import '../../onboarding/screens/avatar_selection_screen.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'كلمتا السر غير متطابقتين';
      });
      return;
    }

    final error = await _authService.register(
      email: _emailController.text,
      name: _nameController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    // context.read<UserProvider>().setUser(
    //       _nameController.text.trim(),
    //       '🦁',
    //       'ليو',
    //       AppColors.avatarLion,
    //     );


    final user = await _authService.getCurrentUser();
    if (!mounted) return;
    context.read<UserProvider>().setUser(
          _nameController.text.trim(),
          '🦁',
          'ليو',
          AppColors.avatarLion,
          userId: user?['id'] as String? ?? '',
        );

        
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AvatarSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AppScaffold(
      gradient: AppGradients.bgRegister,
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

                      const SizedBox(height: AppSpacing.md),

                      // Center(
                      //   child: Container(
                      //     width: 90,
                      //     height: 90,
                      //     decoration: BoxDecoration(
                      //       shape: BoxShape.circle,
                      //       gradient: const LinearGradient(
                      //         colors: [
                      //           AppColors.accent,
                      //           AppColors.warning,
                      //         ],
                      //       ),
                      //       boxShadow:
                      //           AppShadows.button(AppColors.accent),
                      //     ),
                      //     child: const Center(
                      //       child: Text('🌟',
                      //           style: TextStyle(fontSize: 50)),
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



                      const SizedBox(height: AppSpacing.md + 2),

                      Text(
                        'أهلاً بك في بنان!',
                        textAlign: TextAlign.center,
                        style: AppTypography.displaySmall.copyWith(
                          fontSize: 28,
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        'أنشئ حسابك وابدأ الرحلة',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: AppSpacing.xl),

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

                      const SizedBox(height: AppSpacing.sm),

                      AppFormField(
                        controller: _nameController,
                        hint: 'الاسم',
                        icon: Icons.person_rounded,
                        textInputAction: TextInputAction.next,
                      )
                          .animate()
                          .fadeIn(delay: 450.ms)
                          .slideX(begin: 0.1),

                      const SizedBox(height: AppSpacing.sm),

                      AppPasswordField(
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
                      )
                          .animate()
                          .fadeIn(delay: 500.ms)
                          .slideX(begin: 0.1),

                      const SizedBox(height: AppSpacing.sm),

                      AppPasswordField(
                        controller: _confirmPasswordController,
                        hint: 'تأكيد كلمة السر',
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleRegister(),
                      )
                          .animate()
                          .fadeIn(delay: 550.ms)
                          .slideX(begin: 0.1),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        AppStatusCard(
                          message: _errorMessage!,
                          type: AppStatusType.error,
                        ).animate().fadeIn().shake(),
                      ],

                      const Spacer(),
                      const SizedBox(height: AppSpacing.xl),

                      // 🌸 زر pastel
                      AppPrimaryButton(
                        label: 'تسجيل',
                        icon: Icons.check_circle_rounded,
                        gradient: AppGradients.pastelSky,
                        shadowColor: AppColors.pastelSky,
                        textColor: AppColors.pastelButtonText,
                        onTap: _handleRegister,
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
