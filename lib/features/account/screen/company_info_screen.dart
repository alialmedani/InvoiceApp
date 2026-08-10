import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/features/shared/models/mock_seller.dart';
import 'package:invoice/features/shared/widgets/detail_app_bar.dart';
import 'package:invoice/features/shared/widgets/document_sections.dart';

/// Read-only display of `sellerCompany` + `sellerPaymentInfo`.
class CompanyInfoScreen extends StatelessWidget {
  const CompanyInfoScreen({super.key});

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyle.getRegularStyle(
                fontSize: 12.5,
                color: AppColors.getTextMuted(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.getSemiBoldStyle(
                fontSize: 12.5,
                color: AppColors.getPrimary(context),
              ),
            ),
          ),
        ],
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
            DetailAppBar(title: 'company_information'.tr()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    SectionCard(
                      titleKey: 'company_information',
                      child: Column(
                        children: [
                          _row(context, 'company_name'.tr(), sellerCompany.name),
                          _row(context, 'address'.tr(), sellerCompany.addressLine),
                          _row(context, 'city'.tr(), sellerCompany.city),
                          _row(context, 'phone'.tr(), sellerCompany.phone),
                          _row(context, 'email'.tr(), sellerCompany.email),
                          if (sellerCompany.taxNumber != null)
                            _row(
                              context,
                              'tax_number'.tr(),
                              sellerCompany.taxNumber!,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    PaymentInfoSection(paymentInfo: sellerPaymentInfo),
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
