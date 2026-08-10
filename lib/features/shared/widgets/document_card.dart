import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';

/// One row in the documents list: number + customer on the leading side,
/// amount + status on the trailing side.
class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.number,
    required this.customerName,
    required this.dateLabel,
    required this.amountLabel,
    required this.statusChip,
    required this.onTap,
  });

  final String number;
  final String customerName;
  final String dateLabel;
  final String amountLabel;
  final Widget statusChip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.getCard(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.getBorder(context)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number,
                      style: AppTextStyle.getRegularStyle(
                        fontSize: 12,
                        color: AppColors.getTextMuted(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.getSemiBoldStyle(
                        fontSize: 15,
                        color: AppColors.getPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: AppTextStyle.getRegularStyle(
                        fontSize: 12,
                        color: AppColors.getTextMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountLabel,
                    style: AppTextStyle.getBoldStyle(
                      fontSize: 15,
                      color: AppColors.getPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  statusChip,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
