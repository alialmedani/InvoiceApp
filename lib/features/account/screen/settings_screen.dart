import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/core/cubit/theme_cubit.dart';
import 'package:invoice/features/shared/widgets/detail_app_bar.dart';
import 'package:invoice/features/shared/widgets/document_sections.dart';

/// Dark-mode toggle, wired to the app-wide `ThemeCubit`.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            DetailAppBar(title: 'settings'.tr()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: SectionCard(
                  child: BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, mode) {
                      final isDark = mode == ThemeMode.dark;
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              'dark_mode'.tr(),
                              style: AppTextStyle.getSemiBoldStyle(
                                fontSize: 14,
                                color: AppColors.getPrimary(context),
                              ),
                            ),
                          ),
                          Switch(
                            value: isDark,
                            activeThumbColor: AppColors.getPrimary(context),
                            onChanged: (value) =>
                                context.read<ThemeCubit>().toggleDark(value),
                          ),
                        ],
                      );
                    },
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
