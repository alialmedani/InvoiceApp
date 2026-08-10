import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/utils/functions/currency_formatter_iraqi.dart';

/// "1,250,000 IQD" / "١٬٢٥٠٬٠٠٠ د.ع" — amount via the core formatter,
/// currency label localized.
String formatMoney(double amount) =>
    '${CurrencyFormatter.formatAmount(amount)} ${'currency_iqd'.tr()}';

/// Compact date like "12 Aug 2026", localized. Kurdish falls back to English
/// symbols (intl has no ku date data).
String formatDate(BuildContext context, DateTime date) {
  final lang = context.locale.languageCode == 'ku'
      ? 'en'
      : context.locale.languageCode;
  return DateFormat('d MMM yyyy', lang).format(date);
}
