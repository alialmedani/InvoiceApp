import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/utils/Navigation/navigation.dart';
import 'package:invoice/features/home/screen/home_screen.dart';
import 'package:flutter/material.dart';

import '../../widgets/loading_splash_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    // Brief branded splash, then straight into the documents hub.
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigation.pushAndRemoveUntil(const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.neutral900 : AppColors.neutral25,
      body: const EnkiSignatureLoadingOverlay(),
    );
  }
}
