import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/core/utils/Navigation/navigation.dart';
import 'package:invoice/features/quotations/cubit/quotations_cubit.dart';
import 'package:invoice/features/quotations/data/model/quotation_model.dart';
import 'package:invoice/features/quotations/screen/quotation_details_screen.dart';
import 'package:invoice/features/shared/models/document_models.dart';
import 'package:invoice/features/shared/models/mock_seller.dart';
import 'package:invoice/features/shared/widgets/detail_app_bar.dart';
import 'package:invoice/features/shared/widgets/document_form.dart';
import 'package:invoice/features/shared/widgets/document_sections.dart';

class CreateQuotationScreen extends StatefulWidget {
  const CreateQuotationScreen({super.key});

  @override
  State<CreateQuotationScreen> createState() => _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends State<CreateQuotationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _termsCtrl = TextEditingController();

  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));
  final List<DocumentItem> _items = [];
  int? _pickedCustomer;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _addressCtrl,
      _cityCtrl,
      _phoneCtrl,
      _emailCtrl,
      _discountCtrl,
      _taxCtrl,
      _notesCtrl,
      _termsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  QuotationModel _buildQuotation(String number) => QuotationModel(
    id: 'quo-local-${DateTime.now().millisecondsSinceEpoch}',
    number: number,
    issueDate: DateTime.now(),
    expiryDate: _expiryDate,
    status: QuotationStatus.draft,
    company: sellerCompany,
    customer: PartyInfo(
      name: _nameCtrl.text.trim(),
      addressLine: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    ),
    items: List.of(_items),
    discountPercent: (double.tryParse(_discountCtrl.text) ?? 0).clamp(0, 100),
    taxPercent: (double.tryParse(_taxCtrl.text) ?? 0).clamp(0, 100),
    notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    terms: _termsCtrl.text.trim().isEmpty ? null : _termsCtrl.text.trim(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DetailAppBar(title: 'new_offer'.tr()),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      CustomerFormCard(
                        nameCtrl: _nameCtrl,
                        addressCtrl: _addressCtrl,
                        cityCtrl: _cityCtrl,
                        phoneCtrl: _phoneCtrl,
                        emailCtrl: _emailCtrl,
                        pickedIndex: _pickedCustomer,
                        onPick: (i) => setState(() => _pickedCustomer = i),
                      ),
                      const SizedBox(height: 12),
                      DocumentMetaFormCard(
                        titleKey: 'offer_details',
                        dateLabelKey: 'valid_until',
                        date: _expiryDate,
                        onDatePicked: (d) => setState(() => _expiryDate = d),
                        discountCtrl: _discountCtrl,
                        taxCtrl: _taxCtrl,
                        onPercentsChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      ItemsFormCard(
                        items: _items,
                        onRemove: (i) => setState(() => _items.removeAt(i)),
                        onAdd: (item) => setState(() => _items.add(item)),
                      ),
                      const SizedBox(height: 12),
                      SectionCard(
                        titleKey: 'notes',
                        child: documentFormField(
                          context,
                          controller: _notesCtrl,
                          hint: 'notes'.tr(),
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SectionCard(
                        titleKey: 'terms_conditions',
                        child: documentFormField(
                          context,
                          controller: _termsCtrl,
                          hint: 'terms_conditions'.tr(),
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DocumentSaveBar(
        total: _buildQuotation('preview').total,
        buttonLabelKey: 'save_offer',
        onSave: _save,
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      _showSnack('at_least_one_item'.tr());
      return;
    }
    final cubit = context.read<QuotationsCubit>();
    final quotation = _buildQuotation(cubit.nextNumber());
    cubit.addQuotation(quotation);
    _showSnack('offer_created'.tr());
    Navigation.pop();
    Navigation.push(QuotationDetailsScreen(quotation: quotation));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.getPrimary(context),
        content: Text(
          message,
          style: AppTextStyle.getMediumStyle(
            fontSize: 13.5,
            color: AppColors.getBackground(context),
          ),
        ),
      ),
    );
  }
}
