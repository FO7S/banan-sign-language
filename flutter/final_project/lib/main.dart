import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/splash_screen.dart';
import 'features/home/providers/user_provider.dart';

void main() {
  // ✅ كلّ التصنيف يحدث على Backend - لا حاجة لتحميل أيّ نموذج محلّي
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const BananApp(),
    ),
  );
}

class BananApp extends StatelessWidget {
  const BananApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بنان',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.secondary,
          primary: AppColors.primary,
        ),
        textTheme: GoogleFonts.tajawalTextTheme(),
        scaffoldBackgroundColor: AppColors.bgHome1,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
