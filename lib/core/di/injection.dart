import 'package:get_it/get_it.dart';
import 'package:invoice/features/invoices/cubit/invoices_cubit.dart';
import 'package:invoice/features/quotations/cubit/quotations_cubit.dart';

final getIt = GetIt.instance;

Future<void> setUp() async {
  getIt.registerLazySingleton(() => InvoicesCubit());
  getIt.registerLazySingleton(() => QuotationsCubit());
}
