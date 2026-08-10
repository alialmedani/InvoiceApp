import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/features/quotations/data/model/quotation_model.dart';
import 'package:invoice/features/shared/utils/document_format.dart';
import 'package:invoice/features/shared/widgets/detail_app_bar.dart';
import 'package:invoice/features/shared/widgets/document_sections.dart';
import 'package:invoice/features/shared/widgets/status_chip.dart';

class QuotationDetailsScreen extends StatelessWidget {
  const QuotationDetailsScreen({super.key, required this.quotation});

  final QuotationModel quotation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            DetailAppBar(title: 'price_offer'.tr()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    DocumentHeaderCard(
                      statusChip: DocumentStatusChip.quotation(
                        quotation.status,
                      ),
                      number: quotation.number,
                      totalLabelKey: 'total',
                      totalAmount: quotation.total,
                      metaEntries: [
                        (
                          'issue_date',
                          formatDate(context, quotation.issueDate),
                        ),
                        (
                          'valid_until',
                          formatDate(context, quotation.expiryDate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PartiesSection(
                      company: quotation.company,
                      customer: quotation.customer,
                      customerLabelKey: 'prepared_for',
                    ),
                    const SizedBox(height: 12),
                    DocumentItemsSection(items: quotation.items),
                    const SizedBox(height: 12),
                    TotalsSection(totals: quotation),
                    if (quotation.notes != null) ...[
                      const SizedBox(height: 12),
                      TextBlockSection(
                        titleKey: 'notes',
                        body: quotation.notes!,
                      ),
                    ],
                    if (quotation.terms != null) ...[
                      const SizedBox(height: 12),
                      TextBlockSection(
                        titleKey: 'terms_conditions',
                        body: quotation.terms!,
                      ),
                    ],
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
