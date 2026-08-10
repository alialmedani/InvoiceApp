import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoice/features/quotations/data/mock/mock_quotations.dart';
import 'package:invoice/features/quotations/data/model/quotation_model.dart';

part 'quotations_state.dart';

class QuotationsCubit extends Cubit<QuotationsState> {
  QuotationsCubit() : super(QuotationsInitial());

  /// Static data source for now; swap the body for a UseCase/Repository call
  /// when the API layer is added. The short delay exercises the loading UI.
  Future<void> getQuotations() async {
    emit(QuotationsLoading());
    await Future.delayed(const Duration(milliseconds: 700));
    emit(QuotationsLoaded(mockQuotations));
  }
}
