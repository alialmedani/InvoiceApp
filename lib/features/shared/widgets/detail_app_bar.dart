import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/core/utils/Navigation/navigation.dart';

/// Minimal flat app bar for document detail screens: circular back button,
/// centered title, and either a trailing action or a symmetric spacer.
class DetailAppBar extends StatelessWidget {
  const DetailAppBar({super.key, required this.title, this.trailing});

  final String title;

  /// Optional 42px-wide action (e.g. delete) shown opposite the back
  /// button; when null a same-width spacer keeps the title centered.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Material(
            color: AppColors.getCard(context),
            shape: CircleBorder(
              side: BorderSide(color: AppColors.getBorder(context)),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigation.pop(),
              child: SizedBox(
                width: 42,
                height: 42,
                child: Center(
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: AppColors.getPrimary(context),
                    textDirection:
                        Directionality.of(context) == TextDirection.rtl
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.getSemiBoldStyle(
                fontSize: 16,
                color: AppColors.getPrimary(context),
              ),
            ),
          ),
          trailing ?? const SizedBox(width: 42),
        ],
      ),
    );
  }
}
