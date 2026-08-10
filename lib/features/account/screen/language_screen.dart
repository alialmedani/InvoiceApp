import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/features/shared/widgets/detail_app_bar.dart';
import 'package:invoice/features/shared/widgets/document_sections.dart';

/// en/ar/ku picker, using the same `context.setLocale(...)` call the old
/// home_screen's header toggle used.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _locales = <(Locale, String)>[
    (Locale('en'), 'english'),
    (Locale('ar'), 'arabic'),
    (Locale('ku'), 'kurdish'),
  ];

  Widget _row(BuildContext context, Locale locale, String labelKey) {
    final selected = context.locale.languageCode == locale.languageCode;
    return InkWell(
      onTap: () => context.setLocale(locale),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                labelKey.tr(),
                style: AppTextStyle.getSemiBoldStyle(
                  fontSize: 14,
                  color: AppColors.getPrimary(context),
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: AppColors.getPrimary(context),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            DetailAppBar(title: 'language'.tr()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: SectionCard(
                  child: Column(
                    children: [
                      for (int i = 0; i < _locales.length; i++) ...[
                        if (i > 0)
                          Divider(height: 1, color: AppColors.getBorder(context)),
                        _row(context, _locales[i].$1, _locales[i].$2),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
