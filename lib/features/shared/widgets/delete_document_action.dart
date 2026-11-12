import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';

/// Circular delete button for [DetailAppBar]'s trailing slot. Tapping it
/// shows a confirmation dialog; [onConfirmed] runs only if the user
/// explicitly confirms — deleting a document is irreversible in-session, so
/// it is never a single-tap action.
class DeleteDocumentAction extends StatelessWidget {
  const DeleteDocumentAction({
    super.key,
    required this.titleKey,
    required this.message,
    required this.onConfirmed,
  });

  /// Dialog title translation key ('delete_invoice_title' / 'delete_offer_title').
  final String titleKey;

  /// Already-formatted dialog body (document number interpolated).
  final String message;

  final VoidCallback onConfirmed;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('delete_document_button'),
      color: AppColors.getCard(context),
      shape: CircleBorder(
        side: BorderSide(color: AppColors.getBorder(context)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _confirm(context),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.getDialogDanger(context),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.getDialogBarrier(context),
      builder: (dialogContext) => _DeleteConfirmDialog(
        titleKey: titleKey,
        message: message,
      ),
    );
    if (confirmed ?? false) onConfirmed();
  }
}

class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog({required this.titleKey, required this.message});

  final String titleKey;
  final String message;

  @override
  Widget build(BuildContext context) {
    final danger = AppColors.getDialogDanger(context);
    return Dialog(
      backgroundColor: AppColors.getDialogCard(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.getDialogBorder(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titleKey.tr(),
              style: AppTextStyle.getSemiBoldStyle(
                fontSize: 16,
                color: AppColors.getDialogTitleText(context),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: AppTextStyle.getRegularStyle(
                fontSize: 13.5,
                color: AppColors.getDialogBodyText(context),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    key: const Key('cancel_delete_button'),
                    label: 'cancel'.tr(),
                    background: Colors.transparent,
                    foreground: AppColors.getDialogMutedText(context),
                    border: AppColors.getDialogBorder(context),
                    onTap: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DialogButton(
                    key: const Key('confirm_delete_button'),
                    label: 'delete'.tr(),
                    background: danger,
                    foreground: Colors.white,
                    onTap: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.border,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color? border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: border == null ? null : Border.all(color: border!),
          ),
          child: Text(
            label,
            style: AppTextStyle.getSemiBoldStyle(
              fontSize: 13.5,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}
