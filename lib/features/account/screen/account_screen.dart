import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/core/utils/Navigation/navigation.dart';
import 'package:invoice/features/account/data/mock_account.dart';
import 'package:invoice/features/account/screen/about_screen.dart';
import 'package:invoice/features/account/screen/company_info_screen.dart';
import 'package:invoice/features/account/screen/language_screen.dart';
import 'package:invoice/features/account/screen/settings_screen.dart';
import 'package:invoice/features/shared/widgets/document_sections.dart';
import 'package:invoice/features/shell/data/nav_destination.dart';

/// Tab 4 of `MainShellScreen`: profile summary + navigable rows to the
/// company info / settings / language / about sub-screens.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.getBackground(context),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            kFloatingNavClearance,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'account'.tr(),
                style: AppTextStyle.getBoldStyle(
                  fontSize: 22,
                  color: AppColors.getPrimary(context),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'profile'.tr(),
                style: AppTextStyle.getSemiBoldStyle(
                  fontSize: 13,
                  color: AppColors.getTextMuted(context),
                ),
              ),
              const SizedBox(height: 10),
              _profileCard(context),
              const SizedBox(height: 20),
              _menu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getBorder(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.getPrimary(context),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              mockAccountUser.initials,
              style: AppTextStyle.getBoldStyle(
                fontSize: 18,
                color: AppColors.getCard(context),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mockAccountUser.name,
                  style: AppTextStyle.getSemiBoldStyle(
                    fontSize: 15.5,
                    color: AppColors.getPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mockAccountUser.role,
                  style: AppTextStyle.getRegularStyle(
                    fontSize: 12.5,
                    color: AppColors.getTextMuted(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context) {
    final items = <(IconData, String, VoidCallback)>[
      (
        Icons.business_rounded,
        'company_information',
        () => Navigation.push(const CompanyInfoScreen()),
      ),
      (
        Icons.settings_rounded,
        'settings',
        () => Navigation.push(const SettingsScreen()),
      ),
      (
        Icons.language_rounded,
        'language',
        () => Navigation.push(const LanguageScreen()),
      ),
      (
        Icons.info_outline_rounded,
        'about',
        () => Navigation.push(const AboutScreen()),
      ),
    ];

    return SectionCard(
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.getBorder(context)),
            _menuRow(context, items[i].$1, items[i].$2, items[i].$3),
          ],
        ],
      ),
    );
  }

  Widget _menuRow(
    BuildContext context,
    IconData icon,
    String labelKey,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.getPrimary(context)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                labelKey.tr(),
                style: AppTextStyle.getSemiBoldStyle(
                  fontSize: 14,
                  color: AppColors.getPrimary(context),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.getTextMuted(context),
            ),
          ],
        ),
      ),
    );
  }
}
