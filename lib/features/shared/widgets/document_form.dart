import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/core/ui/widgets/custom_button.dart';
import 'package:invoice/core/ui/widgets/custom_text_form_field.dart';
import 'package:invoice/features/shared/models/document_models.dart';
import 'package:invoice/features/shared/models/mock_seller.dart';
import 'package:invoice/features/shared/utils/document_format.dart';
import 'package:invoice/features/shared/widgets/document_sections.dart';

/// Design-system styling for a form field inside a document form.
Widget documentFormField(
  BuildContext context, {
  Key? fieldKey,
  required TextEditingController controller,
  required String hint,
  TextInputType? keyboardType,
  int maxLines = 1,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
}) {
  return CustomTextFormField(
    key: fieldKey,
    controller: controller,
    hintText: hint,
    keyboardType: keyboardType,
    maxLines: maxLines,
    validator: validator,
    onChanged: onChanged,
    borderColor: AppColors.getBorder(context),
    focusedColor: AppColors.getAccent(context),
    fillColor: AppColors.getBackground(context),
    textStyle: AppTextStyle.getMediumStyle(
      fontSize: 14,
      color: AppColors.getPrimary(context),
    ),
    hintStyle: AppTextStyle.getRegularStyle(
      fontSize: 13,
      color: AppColors.getTextMuted(context),
    ),
  );
}

String? optionalPercentValidator(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  final n = double.tryParse(v);
  if (n == null || n < 0 || n > 100) return 'invalid_number'.tr();
  return null;
}

/// Customer section: quick-pick chips for known customers + editable fields.
class CustomerFormCard extends StatelessWidget {
  const CustomerFormCard({
    super.key,
    required this.nameCtrl,
    required this.addressCtrl,
    required this.cityCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.pickedIndex,
    required this.onPick,
  });

  final TextEditingController nameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final int? pickedIndex;
  final void Function(int index) onPick;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      titleKey: 'customer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: mockCustomers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final selected = pickedIndex == i;
                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    final c = mockCustomers[i];
                    nameCtrl.text = c.name;
                    addressCtrl.text = c.addressLine;
                    cityCtrl.text = c.city;
                    phoneCtrl.text = c.phone;
                    emailCtrl.text = c.email;
                    onPick(i);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.getPrimary(context)
                          : AppColors.getBackground(context),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? AppColors.getPrimary(context)
                            : AppColors.getBorder(context),
                      ),
                    ),
                    child: Text(
                      mockCustomers[i].name,
                      style: AppTextStyle.getSemiBoldStyle(
                        fontSize: 12,
                        color: selected
                            ? AppColors.getCard(context)
                            : AppColors.getTextMuted(context),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          documentFormField(
            context,
            controller: nameCtrl,
            hint: 'customer_name'.tr(),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'fill_field'.tr() : null,
          ),
          const SizedBox(height: 10),
          documentFormField(
            context,
            controller: addressCtrl,
            hint: 'address'.tr(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: documentFormField(
                  context,
                  controller: cityCtrl,
                  hint: 'city'.tr(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: documentFormField(
                  context,
                  controller: phoneCtrl,
                  hint: 'phone'.tr(),
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          documentFormField(
            context,
            controller: emailCtrl,
            hint: 'email'.tr(),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }
}

/// Date + discount % + tax % section, shared by both document forms.
class DocumentMetaFormCard extends StatelessWidget {
  const DocumentMetaFormCard({
    super.key,
    required this.titleKey,
    required this.dateLabelKey,
    required this.date,
    required this.onDatePicked,
    required this.discountCtrl,
    required this.taxCtrl,
    required this.onPercentsChanged,
  });

  final String titleKey;
  final String dateLabelKey;
  final DateTime date;
  final void Function(DateTime picked) onDatePicked;
  final TextEditingController discountCtrl;
  final TextEditingController taxCtrl;
  final VoidCallback onPercentsChanged;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      titleKey: titleKey,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 730)),
              );
              if (picked != null) onDatePicked(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.getBorder(context)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${dateLabelKey.tr()} · ${formatDate(context, date)}',
                      style: AppTextStyle.getMediumStyle(
                        fontSize: 14,
                        color: AppColors.getPrimary(context),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: AppColors.getTextMuted(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: documentFormField(
                  context,
                  controller: discountCtrl,
                  hint: 'discount_percent'.tr(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: optionalPercentValidator,
                  onChanged: (_) => onPercentsChanged(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: documentFormField(
                  context,
                  controller: taxCtrl,
                  hint: 'tax_percent'.tr(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: optionalPercentValidator,
                  onChanged: (_) => onPercentsChanged(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Items section: added items with remove buttons + "Add item" opening the
/// bottom-sheet form.
class ItemsFormCard extends StatelessWidget {
  const ItemsFormCard({
    super.key,
    required this.items,
    required this.onRemove,
    required this.onAdd,
  });

  final List<DocumentItem> items;
  final void Function(int index) onRemove;
  final void Function(DocumentItem item) onAdd;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.getTextMuted(context);
    return SectionCard(
      titleKey: 'items',
      trailing: items.isEmpty
          ? null
          : Text(
              'items_count'.tr(args: [items.length.toString()]),
              style: AppTextStyle.getRegularStyle(fontSize: 12, color: muted),
            ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(height: 20, color: AppColors.getBorder(context)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].name,
                        style: AppTextStyle.getMediumStyle(
                          fontSize: 14,
                          color: AppColors.getPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${items[i].quantity == items[i].quantity.roundToDouble() ? items[i].quantity.toInt() : items[i].quantity}'
                        '${items[i].unit == null ? '' : ' ${items[i].unit}'}'
                        ' × ${formatMoney(items[i].unitPrice)}'
                        '${items[i].discountPercent > 0 ? ' · −${items[i].discountPercent.toInt()}%' : ''}',
                        style: AppTextStyle.getRegularStyle(
                          fontSize: 12.5,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatMoney(items[i].netAmount),
                  style: AppTextStyle.getSemiBoldStyle(
                    fontSize: 13.5,
                    color: AppColors.getPrimary(context),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onRemove(i),
                  icon: Icon(Icons.close_rounded, size: 18, color: muted),
                ),
              ],
            ),
          ],
          if (items.isNotEmpty) const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.getCard(context),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (sheetContext) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: AddItemSheet(onAdd: onAdd),
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.getBorder(context)),
                color: AppColors.getBackground(context),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: AppColors.getPrimary(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'add_item'.tr(),
                    style: AppTextStyle.getSemiBoldStyle(
                      fontSize: 13.5,
                      color: AppColors.getPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinned bottom bar with the live total and the primary save action.
class DocumentSaveBar extends StatelessWidget {
  const DocumentSaveBar({
    super.key,
    required this.total,
    required this.buttonLabelKey,
    required this.onSave,
  });

  final double total;
  final String buttonLabelKey;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        border: Border(top: BorderSide(color: AppColors.getBorder(context))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'total'.tr(),
                      style: AppTextStyle.getRegularStyle(
                        fontSize: 11.5,
                        color: AppColors.getTextMuted(context),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        formatMoney(total),
                        style: AppTextStyle.getBoldStyle(
                          fontSize: 17,
                          color: AppColors.getPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  h: 48,
                  radius: 14,
                  color: AppColors.getPrimary(context),
                  rowChild: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        buttonLabelKey.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.getSemiBoldStyle(
                          fontSize: 14,
                          color: AppColors.getBackground(context),
                        ),
                      ),
                    ),
                  ),
                  onPressed: onSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom-sheet form for adding one item to a document.
class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key, required this.onAdd});

  final void Function(DocumentItem item) onAdd;

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _descCtrl,
      _qtyCtrl,
      _unitCtrl,
      _priceCtrl,
      _discountCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'fill_field'.tr() : null;

  String? _positiveNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'fill_field'.tr();
    final n = double.tryParse(v);
    if (n == null || n <= 0) return 'invalid_number'.tr();
    return null;
  }

  void _add() {
    if (!_formKey.currentState!.validate()) return;
    widget.onAdd(
      DocumentItem(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        quantity: double.parse(_qtyCtrl.text),
        unit: _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
        unitPrice: double.parse(_priceCtrl.text),
        discountPercent: double.tryParse(_discountCtrl.text) ?? 0,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'add_item'.tr(),
              style: AppTextStyle.getSemiBoldStyle(
                fontSize: 16,
                color: AppColors.getPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            documentFormField(
              context,
              fieldKey: const Key('item_name_field'),
              controller: _nameCtrl,
              hint: 'item_name'.tr(),
              validator: _required,
            ),
            const SizedBox(height: 10),
            documentFormField(
              context,
              controller: _descCtrl,
              hint: 'item_description'.tr(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: documentFormField(
                    context,
                    fieldKey: const Key('item_qty_field'),
                    controller: _qtyCtrl,
                    hint: 'quantity'.tr(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _positiveNumber,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: documentFormField(
                    context,
                    controller: _unitCtrl,
                    hint: 'unit'.tr(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: documentFormField(
                    context,
                    fieldKey: const Key('item_price_field'),
                    controller: _priceCtrl,
                    hint: 'unit_price'.tr(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _positiveNumber,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: documentFormField(
                    context,
                    controller: _discountCtrl,
                    hint: 'discount_percent'.tr(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: optionalPercentValidator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              h: 48,
              radius: 12,
              color: AppColors.getPrimary(context),
              text: 'add'.tr(),
              textStyle: AppTextStyle.getSemiBoldStyle(
                fontSize: 14,
                color: AppColors.getBackground(context),
              ),
              onPressed: _add,
            ),
          ],
        ),
      ),
    );
  }
}
