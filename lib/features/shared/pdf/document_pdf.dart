import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:invoice/features/shared/models/document_models.dart';
import 'package:invoice/features/shared/utils/document_format.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Palette mirrored from [AppColors]'s raw static values (no BuildContext
/// available at PDF-generation time) — same brand colors, PDF's own [PdfColor]
/// type.
class _Palette {
  static const primary = PdfColor.fromInt(0xFF2C3E50);
  static const muted = PdfColor.fromInt(0xFF94A3B8);
  static const border = PdfColor.fromInt(0xFFEDEFF3);
  static const slate = PdfColor.fromInt(0xFF64748B); // draft
  static const success = PdfColor.fromInt(0xFF20A45B); // paid / accepted
  static const warning = PdfColor.fromInt(0xFFBA6700); // pending
  static const danger = PdfColor.fromInt(0xFFB02727); // overdue / declined
  static const info = PdfColor.fromInt(0xFF0175CE); // sent
}

/// Everything needed to render one invoice or quotation as a PDF — the same
/// shape of data the on-screen detail sections (`document_sections.dart`)
/// already take, so the PDF and the in-app screen stay in sync by
/// construction rather than by two independently-maintained layouts.
class DocumentPdfData {
  const DocumentPdfData({
    required this.typeLabel,
    required this.number,
    required this.statusLabelKey,
    required this.statusColor,
    required this.totalLabelKey,
    required this.totalAmount,
    required this.metaEntries,
    required this.company,
    required this.customer,
    required this.customerLabelKey,
    required this.items,
    required this.totals,
    this.notes,
    this.terms,
    this.paymentInfo,
    this.bannerText,
    this.bannerColorKey,
  });

  /// 'invoice'.tr() / 'price_offer'.tr()
  final String typeLabel;
  final String number;

  /// e.g. 'status_paid' — resolved via .tr() inside the builder.
  final String statusLabelKey;
  final DocStatusColor statusColor;

  /// 'total' / 'total_due'
  final String totalLabelKey;
  final double totalAmount;

  /// (label key, already-formatted value), e.g. ('issue_date', '12 Aug 2026').
  final List<(String, String)> metaEntries;

  final PartyInfo company;
  final PartyInfo customer;

  /// 'bill_to' / 'prepared_for'
  final String customerLabelKey;

  final List<DocumentItem> items;
  final DocumentTotals totals;

  final String? notes;
  final String? terms;
  final PaymentInfo? paymentInfo;

  /// Already-formatted banner text (paid on… / overdue by…), invoices only.
  final String? bannerText;
  final DocStatusColor? bannerColorKey;
}

/// The small, closed set of status colors a document can carry — an enum
/// (rather than a raw color) so callers can't hand in an arbitrary Flutter
/// [Color] that has no PDF equivalent.
enum DocStatusColor { slate, success, warning, danger, info }

PdfColor _resolveStatusColor(DocStatusColor c) {
  switch (c) {
    case DocStatusColor.slate:
      return _Palette.slate;
    case DocStatusColor.success:
      return _Palette.success;
    case DocStatusColor.warning:
      return _Palette.warning;
    case DocStatusColor.danger:
      return _Palette.danger;
    case DocStatusColor.info:
      return _Palette.info;
  }
}

Future<pw.Font> _loadFont(String asset) async {
  final data = await rootBundle.load(asset);
  return pw.Font.ttf(data);
}

/// Builds a PDF for [data] and returns its bytes, ready to print/share/save
/// via the `printing` package. Uses the app's own Cairo font (Arabic +
/// Latin support) and mirrors the ambient text direction so Arabic/Kurdish
/// documents read right-to-left, same as the in-app screens.
Future<Uint8List> buildDocumentPdf(
  DocumentPdfData data, {
  required bool isRtl,
}) async {
  final regular = await _loadFont('assets/fonts/Cairo-Regular.ttf');
  final medium = await _loadFont('assets/fonts/Cairo-Medium.ttf');
  final semiBold = await _loadFont('assets/fonts/Cairo-SemiBold.ttf');
  final bold = await _loadFont('assets/fonts/Cairo-Bold.ttf');

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  final direction = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 36),
      textDirection: direction,
      header: (context) =>
          context.pageNumber == 1 ? pw.SizedBox() : pw.SizedBox(height: 12),
      footer: (context) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          '${context.pageNumber} / ${context.pagesCount}',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(font: regular, fontSize: 9, color: _Palette.muted),
        ),
      ),
      // A flat top-level list — not one big `Column` wrapped in an extra
      // `Directionality` — is what lets `MultiPage` distribute individual
      // sections (and split the items table) across pages on its own.
      // `MultiPage.textDirection` above already mirrors RTL/LTR to every
      // child, so no manual `Directionality` wrapper is needed here.
      build: (context) => [
        _header(data, medium: medium, bold: bold, semiBold: semiBold),
        pw.SizedBox(height: 18),
        _parties(data, medium: medium, semiBold: semiBold, regular: regular),
        pw.SizedBox(height: 14),
        ..._itemsSection(
          data,
          medium: medium,
          semiBold: semiBold,
          regular: regular,
          bold: bold,
        ),
        pw.SizedBox(height: 14),
        _totals(data, regular: regular, semiBold: semiBold, bold: bold),
        if (data.paymentInfo != null) ...[
          pw.SizedBox(height: 14),
          _paymentInfo(data.paymentInfo!, regular: regular, semiBold: semiBold),
        ],
        if (data.notes != null) ...[
          pw.SizedBox(height: 14),
          _textBlock('notes'.tr(), data.notes!, regular: regular, semiBold: semiBold),
        ],
        if (data.terms != null) ...[
          pw.SizedBox(height: 14),
          _textBlock(
            'terms_conditions'.tr(),
            data.terms!,
            regular: regular,
            semiBold: semiBold,
          ),
        ],
      ],
    ),
  );

  return doc.save();
}

// --------------------------------------------------------------- sections

pw.Widget _card({required pw.Widget child}) => pw.Container(
  width: double.infinity,
  padding: const pw.EdgeInsets.all(16),
  decoration: pw.BoxDecoration(
    color: PdfColors.white,
    border: pw.Border.all(color: _Palette.border),
    borderRadius: pw.BorderRadius.circular(10),
  ),
  child: child,
);

pw.Widget _hairline() => pw.Container(height: 0.75, color: _Palette.border);

/// Blends [color] toward white by [amount] (0..1) — a light tinted
/// background for status badges/banners, mirroring the app's
/// `baseColor.withValues(alpha: ...)` soft-pill look without relying on PDF
/// alpha compositing (badges sit directly on a white card).
PdfColor _tint(PdfColor color, double amount) {
  return PdfColor(
    color.red + (1 - color.red) * amount,
    color.green + (1 - color.green) * amount,
    color.blue + (1 - color.blue) * amount,
  );
}

pw.Widget _statusBadge(
  DocumentPdfData data, {
  required pw.Font semiBold,
}) {
  final color = _resolveStatusColor(data.statusColor);
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: pw.BoxDecoration(
      color: _tint(color, 0.85),
      borderRadius: pw.BorderRadius.circular(999),
    ),
    child: pw.Text(
      data.statusLabelKey.tr(),
      style: pw.TextStyle(font: semiBold, fontSize: 9.5, color: color),
    ),
  );
}

pw.Widget _header(
  DocumentPdfData data, {
  required pw.Font medium,
  required pw.Font bold,
  required pw.Font semiBold,
}) {
  return _card(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  data.typeLabel,
                  style: pw.TextStyle(font: bold, fontSize: 20, color: _Palette.primary),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  data.number,
                  style: pw.TextStyle(font: medium, fontSize: 11, color: _Palette.muted),
                ),
              ],
            ),
            _statusBadge(data, semiBold: semiBold),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Text(
          data.totalLabelKey.tr(),
          style: pw.TextStyle(font: medium, fontSize: 10, color: _Palette.muted),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          formatMoney(data.totalAmount),
          style: pw.TextStyle(font: bold, fontSize: 24, color: _Palette.primary),
        ),
        pw.SizedBox(height: 14),
        _hairline(),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            for (final (labelKey, value) in data.metaEntries)
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      labelKey.tr(),
                      style: pw.TextStyle(font: medium, fontSize: 9, color: _Palette.muted),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      value,
                      style: pw.TextStyle(
                        font: semiBold,
                        fontSize: 10.5,
                        color: _Palette.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (data.bannerText != null) ...[
          pw.SizedBox(height: 12),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: pw.BoxDecoration(
              color: _tint(_resolveStatusColor(data.bannerColorKey!), 0.85),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              data.bannerText!,
              style: pw.TextStyle(
                font: semiBold,
                fontSize: 9.5,
                color: _resolveStatusColor(data.bannerColorKey!),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

pw.Widget _partyBlock(
  String labelKey,
  PartyInfo party, {
  required pw.Font medium,
  required pw.Font semiBold,
  required pw.Font regular,
}) {
  final mutedStyle = pw.TextStyle(font: regular, fontSize: 9.5, color: _Palette.muted);
  return pw.Expanded(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          labelKey.tr(),
          style: pw.TextStyle(font: semiBold, fontSize: 9, color: _Palette.muted),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          party.name,
          style: pw.TextStyle(font: semiBold, fontSize: 11.5, color: _Palette.primary),
        ),
        pw.SizedBox(height: 2),
        pw.Text('${party.addressLine} · ${party.city}', style: mutedStyle),
        pw.Text('${party.phone} · ${party.email}', style: mutedStyle),
        if (party.taxNumber != null)
          pw.Text('${'tax_number'.tr()} ${party.taxNumber}', style: mutedStyle),
      ],
    ),
  );
}

pw.Widget _parties(
  DocumentPdfData data, {
  required pw.Font medium,
  required pw.Font semiBold,
  required pw.Font regular,
}) {
  return _card(
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _partyBlock('from', data.company, medium: medium, semiBold: semiBold, regular: regular),
        pw.SizedBox(width: 20),
        _partyBlock(
          data.customerLabelKey,
          data.customer,
          medium: medium,
          semiBold: semiBold,
          regular: regular,
        ),
      ],
    ),
  );
}

String _qtyText(double q) => q == q.roundToDouble() ? q.toInt().toString() : q.toString();

String _percentText(double p) => p == p.roundToDouble() ? p.toInt().toString() : p.toString();

/// Items section, as a *list* of top-level widgets rather than one
/// `_card()`-wrapped widget. A bordered/decorated [pw.Container] is an
/// atomic paint unit `MultiPage` cannot split — wrapping a long items table
/// in one would make a long invoice (the mock data has one specifically to
/// exercise this) throw `TooManyPagesException` trying to fit it whole. The
/// header stays a small, always-fits-on-one-page card; the actual
/// [pw.Table] gets its own border instead, so `MultiPage` is free to
/// paginate it row by row.
List<pw.Widget> _itemsSection(
  DocumentPdfData data, {
  required pw.Font medium,
  required pw.Font semiBold,
  required pw.Font regular,
  required pw.Font bold,
}) {
  final headStyle = pw.TextStyle(font: semiBold, fontSize: 9, color: _Palette.muted);
  final cellStyle = pw.TextStyle(font: regular, fontSize: 9.5, color: _Palette.primary);
  final mutedCell = pw.TextStyle(font: regular, fontSize: 9, color: _Palette.muted);

  pw.Widget headCell(String text, {pw.Alignment alignment = pw.Alignment.centerLeft}) =>
      pw.Container(
        alignment: alignment,
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: pw.Text(text, style: headStyle),
      );

  return [
    // Own small, always-fits-on-one-page card — kept separate from the
    // table below (see the class-level doc comment) rather than one
    // continuous card shape, since a uniform `Border` is required whenever
    // `borderRadius` is set (the `pdf` package asserts this), which rules
    // out a "rounded on top only" partial border stitched to the table.
    _card(
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'items'.tr(),
            style: pw.TextStyle(font: semiBold, fontSize: 10.5, color: _Palette.muted),
          ),
          pw.Text(
            'items_count'.tr(args: [data.items.length.toString()]),
            style: pw.TextStyle(font: regular, fontSize: 9, color: _Palette.muted),
          ),
        ],
      ),
    ),
    pw.SizedBox(height: 8),
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 2),
      child: pw.Table(
        border: pw.TableBorder.all(color: _Palette.border, width: 0.75),
        columnWidths: const {
          0: pw.FlexColumnWidth(4),
          1: pw.FlexColumnWidth(1.6),
          2: pw.FlexColumnWidth(1.6),
          3: pw.FlexColumnWidth(1.8),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _Palette.border)),
            ),
            children: [
              headCell('item_name'.tr()),
              headCell('quantity'.tr(), alignment: pw.Alignment.centerRight),
              headCell('unit_price'.tr(), alignment: pw.Alignment.centerRight),
              headCell('total'.tr(), alignment: pw.Alignment.centerRight),
            ],
          ),
          for (final item in data.items)
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item.name, style: pw.TextStyle(font: medium, fontSize: 10, color: _Palette.primary)),
                      if (item.description != null)
                        pw.Text(item.description!, style: mutedCell),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: pw.Text(
                    '${_qtyText(item.quantity)}${item.unit == null ? '' : ' ${item.unit}'}',
                    textAlign: pw.TextAlign.right,
                    style: cellStyle,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: pw.Text(
                    formatMoney(item.unitPrice),
                    textAlign: pw.TextAlign.right,
                    style: cellStyle,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        formatMoney(item.netAmount),
                        style: pw.TextStyle(font: semiBold, fontSize: 10, color: _Palette.primary),
                      ),
                      if (item.discountPercent > 0)
                        pw.Text(
                          '−${_percentText(item.discountPercent)}%',
                          style: pw.TextStyle(font: regular, fontSize: 8.5, color: _Palette.success),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  ];
}

pw.Widget _totalRow(
  String label,
  String value, {
  required pw.Font regular,
  required pw.Font semiBold,
  PdfColor? valueColor,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: regular, fontSize: 10, color: _Palette.muted)),
        pw.Text(
          value,
          style: pw.TextStyle(font: semiBold, fontSize: 10, color: valueColor ?? _Palette.primary),
        ),
      ],
    ),
  );
}

pw.Widget _totals(
  DocumentPdfData data, {
  required pw.Font regular,
  required pw.Font semiBold,
  required pw.Font bold,
}) {
  final totals = data.totals;
  return _card(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _totalRow('subtotal'.tr(), formatMoney(totals.subtotal), regular: regular, semiBold: semiBold),
        if (totals.discountTotal > 0)
          _totalRow(
            'discount'.tr(),
            '−${formatMoney(totals.discountTotal)}',
            regular: regular,
            semiBold: semiBold,
            valueColor: _Palette.success,
          ),
        if (totals.taxPercent > 0)
          _totalRow(
            '${'tax'.tr()} (${_percentText(totals.taxPercent)}%)',
            formatMoney(totals.taxAmount),
            regular: regular,
            semiBold: semiBold,
          ),
        pw.SizedBox(height: 6),
        _hairline(),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              data.totalLabelKey.tr(),
              style: pw.TextStyle(font: semiBold, fontSize: 12, color: _Palette.primary),
            ),
            pw.Text(
              formatMoney(data.totalAmount),
              style: pw.TextStyle(font: bold, fontSize: 14, color: _Palette.primary),
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _paymentInfo(
  PaymentInfo info, {
  required pw.Font regular,
  required pw.Font semiBold,
}) {
  pw.Widget row(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 90,
          child: pw.Text(label, style: pw.TextStyle(font: regular, fontSize: 9.5, color: _Palette.muted)),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(font: semiBold, fontSize: 9.5, color: _Palette.primary),
          ),
        ),
      ],
    ),
  );

  return _card(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          'payment_information'.tr(),
          style: pw.TextStyle(font: semiBold, fontSize: 10.5, color: _Palette.muted),
        ),
        pw.SizedBox(height: 10),
        row('bank'.tr(), info.bankName),
        row('account_name'.tr(), info.accountName),
        row('iban'.tr(), info.iban),
      ],
    ),
  );
}

pw.Widget _textBlock(
  String title,
  String body, {
  required pw.Font regular,
  required pw.Font semiBold,
}) {
  return _card(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(title, style: pw.TextStyle(font: semiBold, fontSize: 10.5, color: _Palette.muted)),
        pw.SizedBox(height: 8),
        pw.Text(
          body,
          style: pw.TextStyle(font: regular, fontSize: 9.5, color: _Palette.primary, lineSpacing: 2),
        ),
      ],
    ),
  );
}
