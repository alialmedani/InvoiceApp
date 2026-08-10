import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../constant/app_colors/app_colors.dart';

class AppLoadingOverlay extends StatelessWidget {
  final String? message;
  final Duration duration;

  const AppLoadingOverlay({
    super.key,
    this.message,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            decoration: BoxDecoration(
              color: AppColors.getCard(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.getBorder(context)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadow(context),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo
                Container(
                  height: 70,
                  width: 70,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.getPrimary(
                      context,
                    ).withValues(alpha: 0.08),
                    border: Border.all(
                      color: AppColors.getPrimary(
                        context,
                      ).withValues(alpha: 0.12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 0.65,
                      child: Transform.scale(
                        scale: 1.0,
                        child: SvgPicture.asset(
                          'assets/icons/logo.svg',
                          colorFilter: ColorFilter.mode(
                            AppColors.getPrimary(context),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Spinner
                SizedBox(
                  height: 36,
                  width: 36,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.getPrimary(context).withValues(alpha: 0.85),
                    ),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),

                // Message
                if (message != null)
                  Text(
                    message!,
                    style: TextStyle(
                      color: AppColors.getPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
