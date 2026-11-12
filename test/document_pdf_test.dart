import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice/features/invoices/data/mock/mock_invoices.dart';
import 'package:invoice/features/invoices/data/model/invoice_model.dart';
import 'package:invoice/features/quotations/data/mock/mock_quotations.dart';
import 'package:invoice/features/quotations/data/model/quotation_model.dart';
import 'package:invoice/features/shared/pdf/document_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proves PDF export actually produces a valid document — not just that the
/// generator code compiles. Runs every mock invoice and quotation (covering
/// the multi-page/long-item-list case, notes/terms, payment info, discounts)
/// through `buildDocumentPdf`, in both LTR and RTL, and checks the output is
/// non-trivial bytes starting with the standard "%PDF" file signature.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  DocStatusColor invoiceStatusColor(InvoiceStatus status) => switch (status) {
    InvoiceStatus.draft => DocStatusColor.slate,
    InvoiceStatus.pending => DocStatusColor.warning,
    InvoiceStatus.paid => DocStatusColor.success,
    InvoiceStatus.overdue => DocStatusColor.danger,
    InvoiceStatus.cancelled => DocStatusColor.slate,
  };

  DocStatusColor quotationStatusColor(QuotationStatus status) => switch (status) {
    QuotationStatus.draft => DocStatusColor.slate,
    QuotationStatus.sent => DocStatusColor.info,
    QuotationStatus.accepted => DocStatusColor.success,
    QuotationStatus.declined => DocStatusColor.slate,
    QuotationStatus.expired => DocStatusColor.danger,
  };

  void expectValidPdf(List<int> bytes) {
    expect(bytes.length, greaterThan(500), reason: 'PDF output looks too small to be real');
    final signature = String.fromCharCodes(bytes.take(4));
    expect(signature, '%PDF', reason: 'output does not start with the PDF file signature');
  }

  testWidgets('every mock invoice produces a valid PDF, LTR and RTL', (
    tester,
  ) async {
    // easy_localization's .tr() works process-wide once initialized here;
    // no widget tree needs to be pumped for this test.
    for (final invoice in mockInvoices) {
      for (final isRtl in [false, true]) {
        final bytes = await buildDocumentPdf(
          DocumentPdfData(
            typeLabel: 'invoice'.tr(),
            number: invoice.number,
            statusLabelKey: 'status_${invoice.status.name}',
            statusColor: invoiceStatusColor(invoice.status),
            totalLabelKey: 'total_due',
            totalAmount: invoice.total,
            metaEntries: [
              ('issue_date', invoice.issueDate.toIso8601String()),
              ('due_date', invoice.dueDate.toIso8601String()),
            ],
            company: invoice.company,
            customer: invoice.customer,
            customerLabelKey: 'bill_to',
            items: invoice.items,
            totals: invoice,
            notes: invoice.notes,
            paymentInfo: invoice.paymentInfo,
            bannerText: invoice.status == InvoiceStatus.paid
                ? 'paid'
                : invoice.status == InvoiceStatus.overdue
                ? 'overdue'
                : null,
            bannerColorKey: invoice.status == InvoiceStatus.paid
                ? DocStatusColor.success
                : invoice.status == InvoiceStatus.overdue
                ? DocStatusColor.danger
                : null,
          ),
          isRtl: isRtl,
        );
        expectValidPdf(bytes);
      }
    }
  });

  testWidgets('every mock quotation produces a valid PDF, LTR and RTL', (
    tester,
  ) async {
    for (final quotation in mockQuotations) {
      for (final isRtl in [false, true]) {
        final bytes = await buildDocumentPdf(
          DocumentPdfData(
            typeLabel: 'price_offer'.tr(),
            number: quotation.number,
            statusLabelKey: 'status_${quotation.status.name}',
            statusColor: quotationStatusColor(quotation.status),
            totalLabelKey: 'total',
            totalAmount: quotation.total,
            metaEntries: [
              ('issue_date', quotation.issueDate.toIso8601String()),
              ('valid_until', quotation.expiryDate.toIso8601String()),
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
        expectValidPdf(bytes);
      }
    }
  });
}
