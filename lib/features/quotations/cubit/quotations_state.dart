part of 'quotations_cubit.dart';

abstract class QuotationsState {}

class QuotationsInitial extends QuotationsState {}

class QuotationsLoading extends QuotationsState {}

class QuotationsLoaded extends QuotationsState {
  final List<QuotationModel> quotations;
  QuotationsLoaded(this.quotations);
}
