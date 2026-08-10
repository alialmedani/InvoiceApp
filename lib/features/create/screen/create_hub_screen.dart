import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/core/utils/Navigation/navigation.dart';
import 'package:invoice/features/invoices/screen/create_invoice_screen.dart';
import 'package:invoice/features/quotations/screen/create_quotation_screen.dart';
import 'package:invoice/features/shell/data/nav_destination.dart';

/// Tab 2 of `MainShellScreen`: pick which kind of document to create. A
/// genuine persistent tab (not a transient modal) so the moving nav circle
/// can settle here like any other destination.
class CreateHubScreen extends StatelessWidget {
  const CreateHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.getBackground(context),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, kFloatingNavClearance),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'create'.tr(),
                style: AppTextStyle.getBoldStyle(
                  fontSize: 22,
                  color: AppColors.getPrimary(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'create_hub_subtitle'.tr(),
                style: AppTextStyle.getRegularStyle(
                  fontSize: 13,
                  color: AppColors.getTextMuted(context),
                ),
              ),
              const SizedBox(height: 24),
              _createCard(
                context,
                key: const Key('create_invoice_card'),
                icon: Icons.receipt_long_rounded,
                titleKey: 'new_invoice',
                subtitleKey: 'create_invoice_subtitle',
                onTap: () => Navigation.push(const CreateInvoiceScreen()),
              ),
              const SizedBox(height: 16),
              _createCard(
                context,
                key: const Key('create_quotation_card'),
                icon: Icons.description_rounded,
                titleKey: 'new_offer',
                subtitleKey: 'create_quotation_subtitle',
                onTap: () => Navigation.push(const CreateQuotationScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createCard(
    BuildContext context, {
    required Key key,
    required IconData icon,
    required String titleKey,
    required String subtitleKey,
    required VoidCallback onTap,
  }) {
    return Material(
      key: key,
      color: AppColors.getCard(context),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.getBorder(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.getPrimary(context).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: AppColors.getPrimary(context)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleKey.tr(),
                      style: AppTextStyle.getSemiBoldStyle(
                        fontSize: 15.5,
                        color: AppColors.getPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitleKey.tr(),
                      style: AppTextStyle.getRegularStyle(
                        fontSize: 12,
                        color: AppColors.getTextMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.getTextMuted(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
