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
    emit(QuotationsLoaded(List.of(mockQuotations)));
  }

  List<QuotationModel> get _current => state is QuotationsLoaded
      ? (state as QuotationsLoaded).quotations
      : List.of(mockQuotations);

  /// Next sequence number, e.g. QUO-2026-0090. Server-side once the API lands.
  String nextNumber() {
    var max = 0;
    for (final q in _current) {
      final match = RegExp(r'(\d+)$').firstMatch(q.number);
      final n = int.tryParse(match?.group(1) ?? '') ?? 0;
      if (n > max) max = n;
    }
    final year = DateTime.now().year;
    return 'QUO-$year-${(max + 1).toString().padLeft(4, '0')}';
  }

  /// Local-only create; becomes a CreateQuotation UseCase with the API.
  void addQuotation(QuotationModel quotation) {
    emit(QuotationsLoaded([quotation, ..._current]));
  }

  /// Local-only delete; becomes a DeleteQuotation UseCase with the API.
  void deleteQuotation(String id) {
    emit(QuotationsLoaded(_current.where((q) => q.id != id).toList()));
  }
}
