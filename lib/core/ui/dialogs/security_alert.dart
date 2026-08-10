import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/core/variables/variables.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void showSecurityAlert(
  BuildContext context,
  String messageKey,
  VoidCallback onRetry,
) {
  final bg = AppColors.getDialogCard(context);
  final border = AppColors.getDialogBorder(context);
  final titleColor = AppColors.getDialogTitleText(context);
  final bodyColor = AppColors.getDialogBodyText(context);
  final danger = AppColors.getDialogDanger(context);

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.getDialogBarrier(context),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border.withValues(alpha: 0.9)),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(context),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: danger.withValues(alpha: 0.12),
                border: Border.all(color: danger.withValues(alpha: 0.22)),
              ),
              child: Icon(Icons.shield_rounded, color: danger, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              'security_alert'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyle.getBoldStyle(
                fontSize: 15.5,
                color: titleColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              messageKey.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyle.getSemiBoldStyle(
                fontSize: 13,
                color: bodyColor.withValues(alpha: 0.95),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();

                  // Reset location variables before retry
                  lat = null;
                  long = null;
                  currtLocation = null;

                  // Retry initialization
                  onRetry();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: danger,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'retry_button'.tr(),
                  style: AppTextStyle.getBoldStyle(
                    fontSize: 12.5,
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showLocationPermissionAlert({
  required BuildContext context,
  required bool isPermanentlyDenied,
  required VoidCallback onRetry,
  required bool Function() isMounted,
}) {
  final bg = AppColors.getDialogCard(context);
  final border = AppColors.getDialogBorder(context);
  final titleColor = AppColors.getDialogTitleText(context);
  final bodyColor = AppColors.getDialogBodyText(context);

  // Permanently denied = Danger (red), else Warning (amber)
  final tone = isPermanentlyDenied
      ? AppColors.getDialogDanger(context)
      : AppColors.getDialogDanger(context);

  final icon = isPermanentlyDenied
      ? Icons.location_disabled
      : Icons.location_off;

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.getDialogBarrier(context),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border.withValues(alpha: 0.9)),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(context),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: tone.withValues(alpha: 0.12),
                border: Border.all(color: tone.withValues(alpha: 0.22)),
              ),
              child: Icon(icon, color: tone, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              'security_alert'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyle.getBoldStyle(
                fontSize: 15.5,
                color: titleColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              (isPermanentlyDenied
                      ? 'Location_permission_is_permanently_denied_Please_enable_it_in_app_settings.'
                      : 'Location_permission_is_required_for_attendance.')
                  .tr(),
              textAlign: TextAlign.center,
              style: AppTextStyle.getSemiBoldStyle(
                fontSize: 13,
                color: bodyColor.withValues(alpha: 0.95),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();

                  if (isPermanentlyDenied) {
                    if (kDebugMode) {
                      print("Opening app settings for location permission");
                    }
                    await openAppSettings();

                    if (isMounted()) {
                      showRetryAfterSettingsAlert(
                        context: context,
                        onRetry: onRetry,
                      );
                    }
                  } else {
                    // Reset location variables before retry
                    lat = null;
                    long = null;
                    currtLocation = null;

                    if (kDebugMode) {
                      print("Retrying location permission request");
                    }
                    onRetry();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: tone,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  (isPermanentlyDenied
                          ? 'permission.open_settings'
                          : 'retry_button')
                      .tr(),
                  style: AppTextStyle.getBoldStyle(
                    fontSize: 12.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showRetryAfterSettingsAlert({
  required BuildContext context,
  required VoidCallback onRetry,
}) {
  final bg = AppColors.getDialogCard(context);
  final border = AppColors.getDialogBorder(context);
  final titleColor = AppColors.getDialogTitleText(context);
  final bodyColor = AppColors.getDialogBodyText(context);
  final primary = AppColors.getPrimary(context);

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.getDialogBarrier(context),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border.withValues(alpha: 0.9)),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(context),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: primary.withValues(alpha: 0.10),
                border: Border.all(color: primary.withValues(alpha: 0.18)),
              ),
              child: Icon(Icons.settings, color: primary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              'security_alert'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyle.getBoldStyle(
                fontSize: 15.5,
                color: titleColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'retry_after_settings'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyle.getSemiBoldStyle(
                fontSize: 13,
                color: bodyColor.withValues(alpha: 0.95),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();

                  // Reset location variables before retry
                  lat = null;
                  long = null;
                  currtLocation = null;

                  onRetry();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimary(context),
                  foregroundColor: AppColors.getBackground(context),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'retry_button'.tr(),
                  style: AppTextStyle.getBoldStyle(
                    fontSize: 12.5,
                    color: AppColors.getBackground(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
