import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/core/utils/Navigation/navigation.dart';
import 'package:invoice/features/invoices/cubit/invoices_cubit.dart';
import 'package:invoice/features/invoices/data/model/invoice_model.dart';
import 'package:invoice/features/invoices/screen/invoice_details_screen.dart';
import 'package:invoice/features/shared/models/document_models.dart';
import 'package:invoice/features/shared/models/mock_seller.dart';
import 'package:invoice/features/shared/widgets/detail_app_bar.dart';
import 'package:invoice/features/shared/widgets/document_form.dart';
import 'package:invoice/features/shared/widgets/document_sections.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Prefilled with the seller's standard bank details, editable per invoice.
  final _bankCtrl = TextEditingController(text: sellerPaymentInfo.bankName);
  final _accountCtrl = TextEditingController(
    text: sellerPaymentInfo.accountName,
  );
  final _ibanCtrl = TextEditingController(text: sellerPaymentInfo.iban);

  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));
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
      _bankCtrl,
      _accountCtrl,
      _ibanCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  PaymentInfo? get _paymentInfo {
    if (_bankCtrl.text.trim().isEmpty && _ibanCtrl.text.trim().isEmpty) {
      return null;
    }
    return PaymentInfo(
      bankName: _bankCtrl.text.trim(),
      accountName: _accountCtrl.text.trim(),
      iban: _ibanCtrl.text.trim(),
    );
  }

  InvoiceModel _buildInvoice(String number) => InvoiceModel(
    id: 'inv-local-${DateTime.now().millisecondsSinceEpoch}',
    number: number,
    issueDate: DateTime.now(),
    dueDate: _dueDate,
    status: InvoiceStatus.draft,
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
    paymentInfo: _paymentInfo,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DetailAppBar(title: 'new_invoice'.tr()),
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
                        titleKey: 'invoice_details',
                        dateLabelKey: 'due_date',
                        date: _dueDate,
                        onDatePicked: (d) => setState(() => _dueDate = d),
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
                        titleKey: 'payment_information',
                        child: Column(
                          children: [
                            documentFormField(
                              context,
                              controller: _bankCtrl,
                              hint: 'bank'.tr(),
                            ),
                            const SizedBox(height: 10),
                            documentFormField(
                              context,
                              controller: _accountCtrl,
                              hint: 'account_name'.tr(),
                            ),
                            const SizedBox(height: 10),
                            documentFormField(
                              context,
                              controller: _ibanCtrl,
                              hint: 'iban'.tr(),
                            ),
                          ],
                        ),
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DocumentSaveBar(
        total: _buildInvoice('preview').total,
        buttonLabelKey: 'save_invoice',
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
    final cubit = context.read<InvoicesCubit>();
    final invoice = _buildInvoice(cubit.nextNumber());
    cubit.addInvoice(invoice);
    _showSnack('invoice_created'.tr());
    Navigation.pop();
    Navigation.push(InvoiceDetailsScreen(invoice: invoice));
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
