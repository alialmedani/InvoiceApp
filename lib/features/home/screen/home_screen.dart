import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/core/utils/Navigation/navigation.dart';
import 'package:invoice/features/invoices/cubit/invoices_cubit.dart';
import 'package:invoice/features/invoices/data/model/invoice_model.dart';
import 'package:invoice/features/invoices/screen/invoice_details_screen.dart';
import 'package:invoice/features/quotations/cubit/quotations_cubit.dart';
import 'package:invoice/features/quotations/data/model/quotation_model.dart';
import 'package:invoice/features/quotations/screen/quotation_details_screen.dart';
import 'package:invoice/features/shared/utils/document_format.dart';
import 'package:invoice/features/shared/widgets/document_card.dart';
import 'package:invoice/features/shared/widgets/empty_state.dart';
import 'package:invoice/features/shared/widgets/status_chip.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _segment = 0; // 0 = invoices, 1 = price offers
  InvoiceStatus? _invoiceFilter;
  QuotationStatus? _quotationFilter;

  @override
  void initState() {
    super.initState();
    context.read<InvoicesCubit>().getInvoices();
    context.read<QuotationsCubit>().getQuotations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _header(context),
              const SizedBox(height: 20),
              _segmentedControl(context),
              const SizedBox(height: 14),
              _filterChips(context),
              const SizedBox(height: 14),
              Expanded(
                child: _segment == 0
                    ? _invoicesList(context)
                    : _quotationsList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- header

  Widget _header(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
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
                'documents'.tr(),
                style: AppTextStyle.getBoldStyle(
                  fontSize: 22,
                  color: AppColors.getPrimary(context),
                ),
              ),
            ],
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => context.setLocale(
            isArabic ? const Locale('en') : const Locale('ar'),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.getCard(context),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.getBorder(context)),
            ),
            child: Text(
              isArabic ? 'English' : 'عربي',
              style: AppTextStyle.getSemiBoldStyle(
                fontSize: 12.5,
                color: AppColors.getPrimary(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------- segmented control

  Widget _segmentedControl(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.getBorder(context)),
      ),
      child: Row(
        children: [
          _segmentButton(context, 0, 'invoices'.tr()),
          _segmentButton(context, 1, 'price_offers'.tr()),
        ],
      ),
    );
  }

  Widget _segmentButton(BuildContext context, int index, String label) {
    final selected = _segment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _segment = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.getPrimary(context)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyle.getSemiBoldStyle(
              fontSize: 13.5,
              color: selected
                  ? AppColors.getCard(context)
                  : AppColors.getTextMuted(context),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- filters

  Widget _filterChips(BuildContext context) {
    final chips = _segment == 0
        ? <(String, InvoiceStatus?)>[
            ('all', null),
            for (final s in InvoiceStatus.values) ('status_${s.name}', s),
          ].map((e) {
            final selected = _invoiceFilter == e.$2;
            return _chip(
              context,
              e.$1.tr(),
              selected,
              () => setState(() => _invoiceFilter = e.$2),
            );
          }).toList()
        : <(String, QuotationStatus?)>[
            ('all', null),
            for (final s in QuotationStatus.values) ('status_${s.name}', s),
          ].map((e) {
            final selected = _quotationFilter == e.$2;
            return _chip(
              context,
              e.$1.tr(),
              selected,
              () => setState(() => _quotationFilter = e.$2),
            );
          }).toList();

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.getPrimary(context)
              : AppColors.getCard(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.getPrimary(context)
                : AppColors.getBorder(context),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.getSemiBoldStyle(
            fontSize: 12.5,
            color: selected
                ? AppColors.getCard(context)
                : AppColors.getTextMuted(context),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------- lists

  Widget _invoicesList(BuildContext context) {
    return BlocBuilder<InvoicesCubit, InvoicesState>(
      builder: (context, state) {
        if (state is! InvoicesLoaded) return _skeletonList(context);
        final invoices = _invoiceFilter == null
            ? state.invoices
            : state.invoices.where((i) => i.status == _invoiceFilter).toList();
        if (invoices.isEmpty) return const DocumentsEmptyState();
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: invoices.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final invoice = invoices[i];
            return DocumentCard(
              number: invoice.number,
              customerName: invoice.customer.name,
              dateLabel: formatDate(context, invoice.issueDate),
              amountLabel: formatMoney(invoice.total),
              statusChip: DocumentStatusChip.invoice(invoice.status),
              onTap: () =>
                  Navigation.push(InvoiceDetailsScreen(invoice: invoice)),
            );
          },
        );
      },
    );
  }

  Widget _quotationsList(BuildContext context) {
    return BlocBuilder<QuotationsCubit, QuotationsState>(
      builder: (context, state) {
        if (state is! QuotationsLoaded) return _skeletonList(context);
        final quotations = _quotationFilter == null
            ? state.quotations
            : state.quotations
                  .where((q) => q.status == _quotationFilter)
                  .toList();
        if (quotations.isEmpty) return const DocumentsEmptyState();
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: quotations.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final quotation = quotations[i];
            return DocumentCard(
              number: quotation.number,
              customerName: quotation.customer.name,
              dateLabel: formatDate(context, quotation.issueDate),
              amountLabel: formatMoney(quotation.total),
              statusChip: DocumentStatusChip.quotation(quotation.status),
              onTap: () =>
                  Navigation.push(QuotationDetailsScreen(quotation: quotation)),
            );
          },
        );
      },
    );
  }

  Widget _skeletonList(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, _) => DocumentCard(
          number: 'INV-2026-0000',
          customerName: 'Placeholder Customer Name',
          dateLabel: '1 Jan 2026',
          amountLabel: '0,000,000 IQD',
          statusChip: const SizedBox(width: 64, height: 22),
          onTap: () {},
        ),
      ),
    );
  }
}
