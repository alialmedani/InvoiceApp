import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/features/shared/widgets/detail_app_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// App name/logo + version via `PackageInfo.fromPlatform()`.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = '${info.version}+${info.buildNumber}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            DetailAppBar(title: 'about'.tr()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.getCard(context),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.getBorder(context)),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/logo.svg',
                        colorFilter: AppColors.logoColorFilter(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'app_name'.tr(),
                      style: AppTextStyle.getBoldStyle(
                        fontSize: 18,
                        color: AppColors.getPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'about_description'.tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyle.getRegularStyle(
                        fontSize: 13,
                        color: AppColors.getTextMuted(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_version.isNotEmpty)
                      Text(
                        '${'app_version'.tr()}: $_version',
                        style: AppTextStyle.getRegularStyle(
                          fontSize: 12.5,
                          color: AppColors.getTextMuted(context),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
