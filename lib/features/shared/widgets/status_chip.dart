import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/features/invoices/data/model/invoice_model.dart';
import 'package:invoice/features/quotations/data/model/quotation_model.dart';

/// Soft pill with a status dot. One visual language for both document types.
class DocumentStatusChip extends StatelessWidget {
  const DocumentStatusChip._(this.labelKey, this.baseColor, {super.key});

  factory DocumentStatusChip.invoice(InvoiceStatus status, {Key? key}) {
    switch (status) {
      case InvoiceStatus.draft:
        return DocumentStatusChip._('status_draft', _slate, key: key);
      case InvoiceStatus.pending:
        return DocumentStatusChip._(
          'status_pending',
          AppColors.warning600,
          key: key,
        );
      case InvoiceStatus.paid:
        return DocumentStatusChip._(
          'status_paid',
          AppColors.success600,
          key: key,
        );
      case InvoiceStatus.overdue:
        return DocumentStatusChip._(
          'status_overdue',
          AppColors.danger600,
          key: key,
        );
      case InvoiceStatus.cancelled:
        return DocumentStatusChip._(
          'status_cancelled',
          AppColors.neutral600,
          key: key,
        );
    }
  }

  factory DocumentStatusChip.quotation(QuotationStatus status, {Key? key}) {
    switch (status) {
      case QuotationStatus.draft:
        return DocumentStatusChip._('status_draft', _slate, key: key);
      case QuotationStatus.sent:
        return DocumentStatusChip._('status_sent', AppColors.info600, key: key);
      case QuotationStatus.accepted:
        return DocumentStatusChip._(
          'status_accepted',
          AppColors.success600,
          key: key,
        );
      case QuotationStatus.declined:
        return DocumentStatusChip._(
          'status_declined',
          AppColors.neutral600,
          key: key,
        );
      case QuotationStatus.expired:
        return DocumentStatusChip._(
          'status_expired',
          AppColors.danger600,
          key: key,
        );
    }
  }

  static const _slate = Color(0xFF64748B);

  final String labelKey;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final fg = isDark ? AppColors.tint(baseColor, 0.35) : baseColor;
    final bg = baseColor.withValues(alpha: isDark ? 0.20 : 0.10);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            labelKey.tr(),
            style: AppTextStyle.getSemiBoldStyle(fontSize: 11.5, color: fg),
          ),
        ],
      ),
    );
  }
}
