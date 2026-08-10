import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';

/// Quiet empty state for filtered document lists.
class DocumentsEmptyState extends StatelessWidget {
  const DocumentsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.getTextMuted(context);
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.getCard(context),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.getBorder(context)),
            ),
            child: Icon(Icons.description_outlined, size: 28, color: muted),
          ),
          const SizedBox(height: 16),
          Text(
            'no_documents_title'.tr(),
            style: AppTextStyle.getSemiBoldStyle(
              fontSize: 15,
              color: AppColors.getPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'no_documents_message'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyle.getRegularStyle(fontSize: 13, color: muted),
          ),
        ],
      ),
    );
  }
}
