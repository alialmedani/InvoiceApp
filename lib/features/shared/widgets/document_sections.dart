import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/features/shared/models/document_models.dart';
import 'package:invoice/features/shared/utils/document_format.dart';

/// Flat white card used for every section of a document detail screen.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.titleKey,
    this.trailing,
    required this.child,
  });

  final String? titleKey;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titleKey != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    titleKey!.tr(),
                    style: AppTextStyle.getSemiBoldStyle(
                      fontSize: 13,
                      color: AppColors.getTextMuted(context),
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

Widget _hairline(BuildContext context) =>
    Container(height: 1, color: AppColors.getBorder(context));

class _MetaEntry {
  final String labelKey;
  final String value;
  const _MetaEntry(this.labelKey, this.value);
}

/// Top card of a detail screen: status, document number, headline total,
/// key dates, and an optional status banner (paid / overdue).
class DocumentHeaderCard extends StatelessWidget {
  const DocumentHeaderCard({
    super.key,
    required this.statusChip,
    required this.number,
    required this.totalLabelKey,
    required this.totalAmount,
    required this.metaEntries,
    this.banner,
  });

  final Widget statusChip;
  final String number;
  final String totalLabelKey;
  final double totalAmount;
  final List<(String, String)> metaEntries;
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.getTextMuted(context);
    final entries = [for (final (k, v) in metaEntries) _MetaEntry(k, v)];

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              statusChip,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  number,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.getRegularStyle(
                    fontSize: 12.5,
                    color: muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            totalLabelKey.tr(),
            style: AppTextStyle.getRegularStyle(fontSize: 12, color: muted),
          ),
          const SizedBox(height: 2),
          Text(
            formatMoney(totalAmount),
            style: AppTextStyle.getBoldStyle(
              fontSize: 28,
              color: AppColors.getPrimary(context),
            ),
          ),
          const SizedBox(height: 18),
          _hairline(context),
          const SizedBox(height: 14),
          Row(
            children: [
              for (int i = 0; i < entries.length; i++) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entries[i].labelKey.tr(),
                        style: AppTextStyle.getRegularStyle(
                          fontSize: 11.5,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        entries[i].value,
                        style: AppTextStyle.getSemiBoldStyle(
                          fontSize: 13,
                          color: AppColors.getPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (banner != null) ...[const SizedBox(height: 14), banner!],
        ],
      ),
    );
  }
}

/// Soft colored banner used inside the header card (paid on… / overdue by…).
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final fg = isDark ? AppColors.tint(color, 0.35) : color;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.getSemiBoldStyle(fontSize: 12.5, color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// From / Bill-to card with the two parties separated by a hairline.
class PartiesSection extends StatelessWidget {
  const PartiesSection({
    super.key,
    required this.company,
    required this.customer,
    this.customerLabelKey = 'bill_to',
  });

  final PartyInfo company;
  final PartyInfo customer;
  final String customerLabelKey;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PartyBlock(labelKey: 'from', party: company),
          const SizedBox(height: 16),
          _hairline(context),
          const SizedBox(height: 16),
          _PartyBlock(labelKey: customerLabelKey, party: customer),
        ],
      ),
    );
  }
}

class _PartyBlock extends StatelessWidget {
  const _PartyBlock({required this.labelKey, required this.party});

  final String labelKey;
  final PartyInfo party;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.getTextMuted(context);
    final mutedStyle = AppTextStyle.getRegularStyle(
      fontSize: 12.5,
      color: muted,
      height: 1.5,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelKey.tr(),
          style: AppTextStyle.getSemiBoldStyle(fontSize: 11.5, color: muted),
        ),
        const SizedBox(height: 6),
        Text(
          party.name,
          style: AppTextStyle.getSemiBoldStyle(
            fontSize: 14.5,
            color: AppColors.getPrimary(context),
          ),
        ),
        const SizedBox(height: 2),
        Text('${party.addressLine} · ${party.city}', style: mutedStyle),
        Text('${party.phone} · ${party.email}', style: mutedStyle),
        if (party.taxNumber != null)
          Text('${'tax_number'.tr()} ${party.taxNumber}', style: mutedStyle),
      ],
    );
  }
}

/// Items card: name + qty × unit price on the leading side, net line total on
/// the trailing side, hairlines between rows. Handles long lists gracefully.
class DocumentItemsSection extends StatelessWidget {
  const DocumentItemsSection({super.key, required this.items});

  final List<DocumentItem> items;

  String _qty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toString();

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.getTextMuted(context);
    return SectionCard(
      titleKey: 'items',
      trailing: Text(
        'items_count'.tr(args: [items.length.toString()]),
        style: AppTextStyle.getRegularStyle(fontSize: 12, color: muted),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 12),
              _hairline(context),
              const SizedBox(height: 12),
            ],
            _ItemTile(item: items[i], qtyText: _qty(items[i].quantity)),
          ],
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.qtyText});

  final DocumentItem item;
  final String qtyText;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.getTextMuted(context);
    final unitPart = item.unit == null ? '' : ' ${item.unit}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: AppTextStyle.getMediumStyle(
                  fontSize: 14,
                  color: AppColors.getPrimary(context),
                ),
              ),
              if (item.description != null) ...[
                const SizedBox(height: 1),
                Text(
                  item.description!,
                  style: AppTextStyle.getRegularStyle(
                    fontSize: 12,
                    color: muted,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '$qtyText$unitPart × ${formatMoney(item.unitPrice)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.getRegularStyle(
                        fontSize: 12.5,
                        color: muted,
                      ),
                    ),
                  ),
                  if (item.discountPercent > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '−${_percent(item.discountPercent)}%',
                      style: AppTextStyle.getSemiBoldStyle(
                        fontSize: 12,
                        color: AppColors.success600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatMoney(item.netAmount),
              style: AppTextStyle.getSemiBoldStyle(
                fontSize: 14,
                color: AppColors.getPrimary(context),
              ),
            ),
            if (item.discountPercent > 0)
              Text(
                formatMoney(item.grossAmount),
                style: AppTextStyle.getRegularStyle(
                  fontSize: 11.5,
                  color: muted,
                  textDecoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

String _percent(double p) =>
    p == p.roundToDouble() ? p.toInt().toString() : p.toString();

/// Subtotal → discount → tax → total breakdown.
class TotalsSection extends StatelessWidget {
  const TotalsSection({
    super.key,
    required this.totals,
    this.totalLabelKey = 'total',
  });

  final DocumentTotals totals;
  final String totalLabelKey;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.getTextMuted(context);
    final primary = AppColors.getPrimary(context);

    Widget row(String label, String value, {Color? valueColor}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyle.getRegularStyle(fontSize: 13.5, color: muted),
            ),
          ),
          Text(
            value,
            style: AppTextStyle.getSemiBoldStyle(
              fontSize: 13.5,
              color: valueColor ?? primary,
            ),
          ),
        ],
      ),
    );

    return SectionCard(
      child: Column(
        children: [
          row('subtotal'.tr(), formatMoney(totals.subtotal)),
          if (totals.discountTotal > 0)
            row(
              'discount'.tr(),
              '−${formatMoney(totals.discountTotal)}',
              valueColor: AppColors.success600,
            ),
          if (totals.taxPercent > 0)
            row(
              '${'tax'.tr()} (${_percent(totals.taxPercent)}%)',
              formatMoney(totals.taxAmount),
            ),
          const SizedBox(height: 8),
          _hairline(context),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  totalLabelKey.tr(),
                  style: AppTextStyle.getSemiBoldStyle(
                    fontSize: 15,
                    color: primary,
                  ),
                ),
              ),
              Text(
                formatMoney(totals.total),
                style: AppTextStyle.getBoldStyle(fontSize: 18, color: primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Notes / terms paragraph card.
class TextBlockSection extends StatelessWidget {
  const TextBlockSection({
    super.key,
    required this.titleKey,
    required this.body,
  });

  final String titleKey;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      titleKey: titleKey,
      child: Text(
        body,
        style: AppTextStyle.getRegularStyle(
          fontSize: 13,
          color: AppColors.getPrimary(context).withValues(alpha: 0.75),
          height: 1.65,
        ),
      ),
    );
  }
}

/// Bank details card for invoices.
class PaymentInfoSection extends StatelessWidget {
  const PaymentInfoSection({super.key, required this.paymentInfo});

  final PaymentInfo paymentInfo;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.getTextMuted(context);

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyle.getRegularStyle(fontSize: 12.5, color: muted),
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

    return SectionCard(
      titleKey: 'payment_information',
      child: Column(
        children: [
          row('bank'.tr(), paymentInfo.bankName),
          row('account_name'.tr(), paymentInfo.accountName),
          row('iban'.tr(), paymentInfo.iban),
        ],
      ),
    );
  }
}
