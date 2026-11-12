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
import 'package:invoice/features/invoices/cubit/invoices_cubit.dart';
import 'package:invoice/features/invoices/data/model/invoice_model.dart';
import 'package:invoice/features/shared/pdf/document_pdf.dart';
import 'package:invoice/features/shared/widgets/delete_document_action.dart';
import 'package:invoice/features/shared/utils/document_format.dart';
import 'package:invoice/features/shared/widgets/detail_app_bar.dart';
import 'package:invoice/features/shared/widgets/document_sections.dart';
import 'package:invoice/features/shared/widgets/status_chip.dart';
import 'package:printing/printing.dart';

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
            DetailAppBar(
              title: 'invoice'.tr(),
              trailing: DeleteDocumentAction(
                titleKey: 'delete_invoice_title',
                message: 'delete_confirm_message'.tr(args: [invoice.number]),
                onConfirmed: () => _delete(context),
              ),
            ),
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
    context.read<InvoicesCubit>().deleteInvoice(invoice.id);
    Navigation.pop();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: snackColor,
        content: Text('invoice_deleted'.tr(), style: snackStyle),
      ),
    );
  }

  String _statusLabelKey(InvoiceStatus status) => switch (status) {
    InvoiceStatus.draft => 'status_draft',
    InvoiceStatus.pending => 'status_pending',
    InvoiceStatus.paid => 'status_paid',
    InvoiceStatus.overdue => 'status_overdue',
    InvoiceStatus.cancelled => 'status_cancelled',
  };

  DocStatusColor _statusColor(InvoiceStatus status) => switch (status) {
    InvoiceStatus.draft => DocStatusColor.slate,
    InvoiceStatus.pending => DocStatusColor.warning,
    InvoiceStatus.paid => DocStatusColor.success,
    InvoiceStatus.overdue => DocStatusColor.danger,
    InvoiceStatus.cancelled => DocStatusColor.slate,
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
          typeLabel: 'invoice'.tr(),
          number: invoice.number,
          statusLabelKey: _statusLabelKey(invoice.status),
          statusColor: _statusColor(invoice.status),
          totalLabelKey: _isPayable ? 'total_due' : 'total',
          totalAmount: invoice.total,
          metaEntries: [
            ('issue_date', formatDate(context, invoice.issueDate)),
            ('due_date', formatDate(context, invoice.dueDate)),
          ],
          company: invoice.company,
          customer: invoice.customer,
          customerLabelKey: 'bill_to',
          items: invoice.items,
          totals: invoice,
          notes: invoice.notes,
          paymentInfo: _isPayable ? invoice.paymentInfo : null,
          bannerText: invoice.status == InvoiceStatus.paid && invoice.paidDate != null
              ? 'paid_on'.tr(args: [formatDate(context, invoice.paidDate!)])
              : invoice.status == InvoiceStatus.overdue
              ? 'overdue_by_days'.tr(args: [invoice.overdueDays.toString()])
              : null,
          bannerColorKey: invoice.status == InvoiceStatus.paid
              ? DocStatusColor.success
              : invoice.status == InvoiceStatus.overdue
              ? DocStatusColor.danger
              : null,
        ),
        isRtl: isRtl,
      );
      await Printing.sharePdf(bytes: bytes, filename: '${invoice.number}.pdf');
    } catch (_) {
      showError();
    }
  }
}
