// `hide TextDirection`: easy_localization re-exports intl's TextDirection
// (RTL/LTR constants), which otherwise shadows dart:ui's TextDirection
// (rtl/ltr) needed for the Directionality check in _downloadPdf.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/core/ui/widgets/custom_button.dart';
import 'package:invoice/core/utils/Navigation/navigation.dart';
import 'package:invoice/features/quotations/cubit/quotations_cubit.dart';
import 'package:invoice/features/quotations/data/model/quotation_model.dart';
import 'package:invoice/features/shared/pdf/document_pdf.dart';
import 'package:invoice/features/shared/widgets/delete_document_action.dart';
import 'package:invoice/features/shared/utils/document_format.dart';
import 'package:invoice/features/shared/widgets/detail_app_bar.dart';
import 'package:invoice/features/shared/widgets/document_sections.dart';
import 'package:invoice/features/shared/widgets/status_chip.dart';
import 'package:printing/printing.dart';

class QuotationDetailsScreen extends StatelessWidget {
  const QuotationDetailsScreen({super.key, required this.quotation});

  final QuotationModel quotation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DetailAppBar(
              title: 'price_offer'.tr(),
              trailing: DeleteDocumentAction(
                titleKey: 'delete_offer_title',
                message: 'delete_confirm_message'.tr(args: [quotation.number]),
                onConfirmed: () => _delete(context),
              ),
            ),
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
      bottomNavigationBar: _downloadBar(context),
    );
  }

  Widget _downloadBar(BuildContext context) {
    final buttonColor = AppColors.getPrimary(context);
    final labelColor = AppColors.getBackground(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        border: Border(top: BorderSide(color: AppColors.getBorder(context))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: CustomButton(
            h: 52,
            radius: 14,
            color: buttonColor,
            icon: Icon(Icons.download_rounded, size: 20, color: labelColor),
            text: 'download_offer'.tr(),
            textStyle: AppTextStyle.getSemiBoldStyle(
              fontSize: 15,
              color: labelColor,
            ),
            onPressed: () => _downloadPdf(context),
          ),
        ),
      ),
    );
  }

  /// Runs only after the user confirmed in the dialog. The messenger is the
  /// app-level ScaffoldMessenger, so the confirmation SnackBar survives this
  /// screen being popped (same pattern as the create screens).
  void _delete(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final snackStyle = AppTextStyle.getMediumStyle(
      fontSize: 13.5,
      color: AppColors.getBackground(context),
    );
    final snackColor = AppColors.getPrimary(context);
    context.read<QuotationsCubit>().deleteQuotation(quotation.id);
    Navigation.pop();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: snackColor,
        content: Text('offer_deleted'.tr(), style: snackStyle),
      ),
    );
  }

  String _statusLabelKey(QuotationStatus status) => switch (status) {
    QuotationStatus.draft => 'status_draft',
    QuotationStatus.sent => 'status_sent',
    QuotationStatus.accepted => 'status_accepted',
    QuotationStatus.declined => 'status_declined',
    QuotationStatus.expired => 'status_expired',
  };

  DocStatusColor _statusColor(QuotationStatus status) => switch (status) {
    QuotationStatus.draft => DocStatusColor.slate,
    QuotationStatus.sent => DocStatusColor.info,
    QuotationStatus.accepted => DocStatusColor.success,
    QuotationStatus.declined => DocStatusColor.slate,
    QuotationStatus.expired => DocStatusColor.danger,
  };

  Future<void> _downloadPdf(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    void showError() => messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.danger600,
        content: Text(
          'pdf_generation_failed'.tr(),
          style: AppTextStyle.getMediumStyle(fontSize: 13.5, color: Colors.white),
        ),
      ),
    );

    try {
      final bytes = await buildDocumentPdf(
        DocumentPdfData(
          typeLabel: 'price_offer'.tr(),
          number: quotation.number,
          statusLabelKey: _statusLabelKey(quotation.status),
          statusColor: _statusColor(quotation.status),
          totalLabelKey: 'total',
          totalAmount: quotation.total,
          metaEntries: [
            ('issue_date', formatDate(context, quotation.issueDate)),
            ('valid_until', formatDate(context, quotation.expiryDate)),
          ],
          company: quotation.company,
          customer: quotation.customer,
          customerLabelKey: 'prepared_for',
          items: quotation.items,
          totals: quotation,
          notes: quotation.notes,
          terms: quotation.terms,
        ),
        isRtl: isRtl,
      );
      await Printing.sharePdf(bytes: bytes, filename: '${quotation.number}.pdf');
    } catch (_) {
      showError();
    }
  }
}
