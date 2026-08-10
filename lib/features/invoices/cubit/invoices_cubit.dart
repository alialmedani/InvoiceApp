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
    emit(InvoicesLoaded(mockInvoices));
  }
}
