import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/core/ui/widgets/custom_button.dart';
import 'package:invoice/features/invoices/data/model/invoice_model.dart';
import 'package:invoice/features/shared/utils/document_format.dart';
import 'package:invoice/features/shared/widgets/detail_app_bar.dart';
import 'package:invoice/features/shared/widgets/document_sections.dart';
import 'package:invoice/features/shared/widgets/status_chip.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  const InvoiceDetailsScreen({super.key, required this.invoice});

  final InvoiceModel invoice;

  bool get _isPayable =>
      invoice.status == InvoiceStatus.pending ||
      invoice.status == InvoiceStatus.overdue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DetailAppBar(title: 'invoice'.tr()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    DocumentHeaderCard(
                      statusChip: DocumentStatusChip.invoice(invoice.status),
                      number: invoice.number,
                      totalLabelKey: _isPayable ? 'total_due' : 'total',
                      totalAmount: invoice.total,
                      metaEntries: [
                        ('issue_date', formatDate(context, invoice.issueDate)),
                        ('due_date', formatDate(context, invoice.dueDate)),
                      ],
                      banner: _banner(context),
                    ),
                    const SizedBox(height: 12),
                    PartiesSection(
                      company: invoice.company,
                      customer: invoice.customer,
                    ),
                    const SizedBox(height: 12),
                    DocumentItemsSection(items: invoice.items),
                    const SizedBox(height: 12),
                    TotalsSection(
                      totals: invoice,
                      totalLabelKey: _isPayable ? 'total_due' : 'total',
                    ),
                    if (_isPayable && invoice.paymentInfo != null) ...[
                      const SizedBox(height: 12),
                      PaymentInfoSection(paymentInfo: invoice.paymentInfo!),
                    ],
                    if (invoice.notes != null) ...[
                      const SizedBox(height: 12),
                      TextBlockSection(titleKey: 'notes', body: invoice.notes!),
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

  Widget? _banner(BuildContext context) {
    if (invoice.status == InvoiceStatus.paid && invoice.paidDate != null) {
      return StatusBanner(
        icon: Icons.check_circle_rounded,
        text: 'paid_on'.tr(args: [formatDate(context, invoice.paidDate!)]),
        color: AppColors.success600,
      );
    }
    if (invoice.status == InvoiceStatus.overdue) {
      return StatusBanner(
        icon: Icons.error_outline_rounded,
        text: 'overdue_by_days'.tr(args: [invoice.overdueDays.toString()]),
        color: AppColors.danger600,
      );
    }
    return null;
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
            text: 'download_invoice'.tr(),
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

  /// PDF generation seam. TODO: implement following the company's existing
  /// invoice/PDF architecture once it is provided — do not hand-roll one here.
  void _downloadPdf(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.getPrimary(context),
        content: Text(
          'pdf_soon'.tr(),
          style: AppTextStyle.getMediumStyle(
            fontSize: 13.5,
            color: AppColors.getBackground(context),
          ),
        ),
      ),
    );
  }
}
