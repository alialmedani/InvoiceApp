part of 'invoices_cubit.dart';

abstract class InvoicesState {}

class InvoicesInitial extends InvoicesState {}

class InvoicesLoading extends InvoicesState {}

class InvoicesLoaded extends InvoicesState {
  final List<InvoiceModel> invoices;
  InvoicesLoaded(this.invoices);
}
