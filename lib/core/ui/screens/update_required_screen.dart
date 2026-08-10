import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constant/app_colors/app_colors.dart';
import '../../constant/app_size/app_size.dart';

class UpdateRequiredScreen extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final String? googlePlayLink;
  final String? appStoreLink;

  const UpdateRequiredScreen({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    this.googlePlayLink,
    this.appStoreLink,
  });

  Future<void> _openStore() async {
    String? url;
    if (Platform.isAndroid && googlePlayLink != null) {
      url = googlePlayLink;
    } else if (Platform.isIOS && appStoreLink != null) {
      url = appStoreLink;
    }

    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.neutral900 : AppColors.neutral25,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Update Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.system_update_alt_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 32),

              // Title
              Text(
                'update_required'.tr(),
                style: GoogleFonts.cairo(
                  fontSize: AppSize.size_24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.neutral800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // Description
              Text(
                'update_description'.tr(),
                style: GoogleFonts.cairo(
                  fontSize: AppSize.size_16,
                  color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              // Version Info
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.neutral800 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.neutral700 : AppColors.neutral200,
                  ),
                ),
                child: Column(
                  children: [
                    _buildVersionRow(
                      'current_version'.tr(),
                      currentVersion,
                      Icons.smartphone,
                      isDark,
                    ),
                    SizedBox(height: 16),
                    Divider(
                      color: isDark
                          ? AppColors.neutral700
                          : AppColors.neutral200,
                    ),
                    SizedBox(height: 16),
                    _buildVersionRow(
                      'latest_version'.tr(),
                      latestVersion,
                      Icons.cloud_download,
                      isDark,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _openStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_rounded, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'update_now'.tr(),
                        style: GoogleFonts.cairo(
                          fontSize: AppSize.size_16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionRow(
    String label,
    String version,
    IconData icon,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: AppSize.size_12,
                  color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                version,
                style: GoogleFonts.cairo(
                  fontSize: AppSize.size_16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.neutral800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
