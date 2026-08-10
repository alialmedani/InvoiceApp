import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/core/utils/Navigation/navigation.dart';
import 'package:invoice/features/invoices/cubit/invoices_cubit.dart';
import 'package:invoice/features/invoices/data/model/invoice_model.dart';
import 'package:invoice/features/invoices/screen/create_invoice_screen.dart';
import 'package:invoice/features/invoices/screen/invoice_details_screen.dart';
import 'package:invoice/features/quotations/cubit/quotations_cubit.dart';
import 'package:invoice/features/quotations/data/model/quotation_model.dart';
import 'package:invoice/features/quotations/screen/create_quotation_screen.dart';
import 'package:invoice/features/quotations/screen/quotation_details_screen.dart';
import 'package:invoice/features/shared/utils/document_format.dart';
import 'package:invoice/features/shared/widgets/document_card.dart';
import 'package:invoice/features/shared/widgets/status_chip.dart';
import 'package:invoice/features/shell/data/nav_destination.dart';

/// Tab 0 of `MainShellScreen`. Greeting header, a financial summary computed
/// inline from the already-loaded Invoices/Quotations cubit state, quick
/// actions and two short "recent" lists.
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key, required this.onNavigate});

  /// Flips the shell's active tab (used by the "View Invoices"/"View
  /// Quotations" quick actions and the recent-section "View all" links).
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.getBackground(context),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            kFloatingNavClearance,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: 20),
              BlocBuilder<InvoicesCubit, InvoicesState>(
                builder: (context, invoicesState) {
                  return BlocBuilder<QuotationsCubit, QuotationsState>(
                    builder: (context, quotationsState) {
                      final invoices = invoicesState is InvoicesLoaded
                          ? invoicesState.invoices
                          : const <InvoiceModel>[];
                      final quotations = quotationsState is QuotationsLoaded
                          ? quotationsState.quotations
                          : const <QuotationModel>[];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _summary(context, invoices, quotations),
                          const SizedBox(height: 22),
                          _quickActions(context),
                          const SizedBox(height: 26),
                          _recentInvoices(context, invoices),
                          const SizedBox(height: 26),
                          _recentQuotations(context, quotations),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- header

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.getCard(context),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.getBorder(context)),
          ),
          child: SvgPicture.asset(
            'assets/icons/logo.svg',
            colorFilter: AppColors.logoColorFilter(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'app_name'.tr(),
                style: AppTextStyle.getRegularStyle(
                  fontSize: 12.5,
                  color: AppColors.getTextMuted(context),
                ),
              ),
              Text(
                'welcome_back'.tr(),
                style: AppTextStyle.getBoldStyle(
                  fontSize: 22,
                  color: AppColors.getPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------- summary cards

  Widget _summary(
    BuildContext context,
    List<InvoiceModel> invoices,
    List<QuotationModel> quotations,
  ) {
    final outstanding = invoices
        .where(
          (i) =>
              i.status == InvoiceStatus.pending ||
              i.status == InvoiceStatus.overdue,
        )
        .fold<double>(0, (sum, i) => sum + i.total);
    final paid = invoices
        .where((i) => i.status == InvoiceStatus.paid)
        .fold<double>(0, (sum, i) => sum + i.total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'financial_summary'.tr(),
          style: AppTextStyle.getSemiBoldStyle(
            fontSize: 13,
            color: AppColors.getTextMuted(context),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard(
                context,
                'total_outstanding'.tr(),
                formatMoney(outstanding),
                Icons.hourglass_top_rounded,
                AppColors.warning600,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                context,
                'total_paid'.tr(),
                formatMoney(paid),
                Icons.check_circle_rounded,
                AppColors.success600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard(
                context,
                'total_invoices'.tr(),
                invoices.length.toString(),
                Icons.receipt_long_rounded,
                AppColors.info600,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                context,
                'total_quotations'.tr(),
                quotations.length.toString(),
                Icons.description_rounded,
                AppColors.getAccent(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.getBoldStyle(
              fontSize: 16,
              color: AppColors.getPrimary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.getRegularStyle(
              fontSize: 11.5,
              color: AppColors.getTextMuted(context),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------- quick actions

  Widget _quickActions(BuildContext context) {
    final actions = [
      (
        'create_invoice'.tr(),
        Icons.receipt_long_rounded,
        () => Navigation.push(const CreateInvoiceScreen()),
      ),
      (
        'create_quotation'.tr(),
        Icons.description_rounded,
        () => Navigation.push(const CreateQuotationScreen()),
      ),
      ('view_invoices'.tr(), Icons.list_alt_rounded, () => onNavigate(1)),
      (
        'view_quotations'.tr(),
        Icons.fact_check_rounded,
        () => onNavigate(3),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'quick_actions'.tr(),
          style: AppTextStyle.getSemiBoldStyle(
            fontSize: 13,
            color: AppColors.getTextMuted(context),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _quickActionTile(context, actions[0])),
            const SizedBox(width: 10),
            Expanded(child: _quickActionTile(context, actions[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _quickActionTile(context, actions[2])),
            const SizedBox(width: 10),
            Expanded(child: _quickActionTile(context, actions[3])),
          ],
        ),
      ],
    );
  }

  Widget _quickActionTile(
    BuildContext context,
    (String, IconData, VoidCallback) action,
  ) {
    return Material(
      color: AppColors.getCard(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: action.$3,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.getBorder(context)),
          ),
          child: Row(
            children: [
              Icon(action.$2, size: 18, color: AppColors.getPrimary(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  action.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.getSemiBoldStyle(
                    fontSize: 12.5,
                    color: AppColors.getPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- recents

  Widget _recentInvoices(BuildContext context, List<InvoiceModel> invoices) {
    final recent = invoices.take(3).toList();
    return _recentSection(
      context,
      titleKey: 'recent_invoices',
      onViewAll: () => onNavigate(1),
      isEmpty: recent.isEmpty,
      children: [
        for (final invoice in recent)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DocumentCard(
              number: invoice.number,
              customerName: invoice.customer.name,
              dateLabel: formatDate(context, invoice.issueDate),
              amountLabel: formatMoney(invoice.total),
              statusChip: DocumentStatusChip.invoice(invoice.status),
              onTap: () =>
                  Navigation.push(InvoiceDetailsScreen(invoice: invoice)),
            ),
          ),
      ],
    );
  }

  Widget _recentQuotations(
    BuildContext context,
    List<QuotationModel> quotations,
  ) {
    final recent = quotations.take(3).toList();
    return _recentSection(
      context,
      titleKey: 'recent_quotations',
      onViewAll: () => onNavigate(3),
      isEmpty: recent.isEmpty,
      children: [
        for (final quotation in recent)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DocumentCard(
              number: quotation.number,
              customerName: quotation.customer.name,
              dateLabel: formatDate(context, quotation.issueDate),
              amountLabel: formatMoney(quotation.total),
              statusChip: DocumentStatusChip.quotation(quotation.status),
              onTap: () => Navigation.push(
                QuotationDetailsScreen(quotation: quotation),
              ),
            ),
          ),
      ],
    );
  }

  Widget _recentSection(
    BuildContext context, {
    required String titleKey,
    required VoidCallback onViewAll,
    required bool isEmpty,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titleKey.tr(),
                style: AppTextStyle.getSemiBoldStyle(
                  fontSize: 15,
                  color: AppColors.getPrimary(context),
                ),
              ),
            ),
            InkWell(
              onTap: onViewAll,
              child: Text(
                'view_all'.tr(),
                style: AppTextStyle.getSemiBoldStyle(
                  fontSize: 12.5,
                  color: AppColors.getAccent(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (isEmpty)
          Text(
            'no_documents_message'.tr(),
            style: AppTextStyle.getRegularStyle(
              fontSize: 12.5,
              color: AppColors.getTextMuted(context),
            ),
          )
        else
          ...children,
      ],
    );
  }
}
