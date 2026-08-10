import 'package:invoice/core/ui/dialogs/security_alert.dart';
import 'package:invoice/core/utils/Navigation/navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import '../../widgets/loading_splash_screen.dart';
import '../widgets/checck_time.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    initializeApp();
  }

  void initializeApp() async {
    try {
      // ✅ فقط فحص الأمان (timezone + وقت) بدون طلب أذونات
      final isCorrectTimezone = checkTimezone();
      final isTimeManipulated = await checkTimeManipulation();

      // Minimum splash display time (شاشة ترحيب سريعة)
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      if (!isCorrectTimezone) {
        showSecurityAlert(context, 'incorrect_timezone', initializeApp);
      } else if (isTimeManipulated) {
        showSecurityAlert(context, 'time_manipulated', initializeApp);
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      if (kDebugMode) print("Error initializing: $e");
      if (mounted) _navigateToLogin();
    }
  }

  bool checkTimezone() {
    try {
      // Get device timezone
      final String deviceTimezone = DateTime.now().timeZoneName;
      final Duration deviceOffset = DateTime.now().timeZoneOffset;

      // Asia/Baghdad is UTC+3
      const Duration baghdadOffset = Duration(hours: 3);

      if (kDebugMode) {
        print("Device timezone: $deviceTimezone");
        print("Device offset: $deviceOffset");
        print("Expected offset: $baghdadOffset");
      }

      // Check if offset matches Baghdad (UTC+3)
      return deviceOffset == baghdadOffset;
    } catch (e) {
      if (kDebugMode) {
        print("Error checking timezone: $e");
      }
      return true; // Allow if check fails
    }
  }

  void _navigateToLogin() {
    // TODO: replace with the app's real first screen once features exist.
    Navigation.pushAndRemoveUntil(const _PlaceholderHomeScreen());
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

class _PlaceholderHomeScreen extends StatelessWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home screen goes here')),
    );
  }
}
