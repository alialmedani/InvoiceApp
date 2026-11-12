import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoice/features/invoices/data/mock/mock_invoices.dart';
import 'package:invoice/features/invoices/data/model/invoice_model.dart';

part 'invoices_state.dart';

class InvoicesCubit extends Cubit<InvoicesState> {
  InvoicesCubit() : super(InvoicesInitial());

  /// Static data source for now; swap the body for a UseCase/Repository call
  /// when the API layer is added. The short delay exercises the loading UI.
  Future<void> getInvoices() async {
    emit(InvoicesLoading());
    await Future.delayed(const Duration(milliseconds: 700));
    emit(InvoicesLoaded(List.of(mockInvoices)));
  }

  List<InvoiceModel> get _current => state is InvoicesLoaded
      ? (state as InvoicesLoaded).invoices
      : List.of(mockInvoices);

  /// Next sequence number, e.g. INV-2026-0239. Server-side once the API lands.
  String nextNumber() {
    var max = 0;
    for (final invoice in _current) {
      final match = RegExp(r'(\d+)$').firstMatch(invoice.number);
      final n = int.tryParse(match?.group(1) ?? '') ?? 0;
      if (n > max) max = n;
    }
    final year = DateTime.now().year;
    return 'INV-$year-${(max + 1).toString().padLeft(4, '0')}';
  }

  /// Local-only create; becomes a CreateInvoice UseCase with the API.
  void addInvoice(InvoiceModel invoice) {
    emit(InvoicesLoaded([invoice, ..._current]));
  }

  /// Local-only delete; becomes a DeleteInvoice UseCase with the API.
  void deleteInvoice(String id) {
    emit(InvoicesLoaded(_current.where((i) => i.id != id).toList()));
  }
}
