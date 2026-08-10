import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/core/utils/Navigation/navigation.dart';
import 'package:invoice/features/quotations/cubit/quotations_cubit.dart';
import 'package:invoice/features/quotations/data/model/quotation_model.dart';
import 'package:invoice/features/quotations/screen/quotation_details_screen.dart';
import 'package:invoice/features/shared/utils/document_format.dart';
import 'package:invoice/features/shared/widgets/document_card.dart';
import 'package:invoice/features/shared/widgets/empty_state.dart';
import 'package:invoice/features/shared/widgets/status_chip.dart';
import 'package:invoice/features/shell/data/nav_destination.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Tab 3 of `MainShellScreen`: the full quotations list with status tabs.
/// Cribbed from the old `home_screen.dart`'s segment/filter/list pattern.
class QuotationsListScreen extends StatefulWidget {
  const QuotationsListScreen({super.key});

  @override
  State<QuotationsListScreen> createState() => _QuotationsListScreenState();
}

class _QuotationsListScreenState extends State<QuotationsListScreen> {
  // Exactly 4 tabs: All + 3 explicit statuses. declined/expired are only
  // reachable via All (still distinguished there by their status chip color).
  static const _tabStatuses = <QuotationStatus?>[
    null,
    QuotationStatus.draft,
    QuotationStatus.sent,
    QuotationStatus.accepted,
  ];
  static const _tabLabelKeys = [
    'all',
    'status_draft',
    'status_sent',
    'status_accepted',
  ];

  QuotationStatus? _filter;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.getBackground(context),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'quotations'.tr(),
                style: AppTextStyle.getBoldStyle(
                  fontSize: 22,
                  color: AppColors.getPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              _filterChips(context),
              const SizedBox(height: 14),
              Expanded(child: _list(context)),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- filters

  Widget _filterChips(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabStatuses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _filter == _tabStatuses[i];
          return _chip(
            context,
            _tabLabelKeys[i].tr(),
            selected,
            () => setState(() => _filter = _tabStatuses[i]),
          );
        },
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

  Widget _list(BuildContext context) {
    return BlocBuilder<QuotationsCubit, QuotationsState>(
      builder: (context, state) {
        if (state is! QuotationsLoaded) return _skeletonList(context);
        final quotations = _filter == null
            ? state.quotations
            : state.quotations.where((q) => q.status == _filter).toList();
        if (quotations.isEmpty) return const DocumentsEmptyState();
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: kFloatingNavClearance),
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
              onTap: () => Navigation.push(
                QuotationDetailsScreen(quotation: quotation),
              ),
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
          number: 'QUO-2026-0000',
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
