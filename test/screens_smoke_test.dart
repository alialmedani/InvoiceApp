import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice/core/classes/keys.dart';
import 'package:invoice/core/utils/Navigation/navigation.dart';
import 'package:invoice/features/home/screen/home_screen.dart';
import 'package:invoice/features/invoices/cubit/invoices_cubit.dart';
import 'package:invoice/features/invoices/data/mock/mock_invoices.dart';
import 'package:invoice/features/invoices/screen/create_invoice_screen.dart';
import 'package:invoice/features/invoices/screen/invoice_details_screen.dart';
import 'package:invoice/features/quotations/cubit/quotations_cubit.dart';
import 'package:invoice/features/quotations/data/mock/mock_quotations.dart';
import 'package:invoice/features/quotations/screen/create_quotation_screen.dart';
import 'package:invoice/features/quotations/screen/quotation_details_screen.dart';
import 'package:invoice/features/shared/models/mock_seller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Drives the whole app through every screen with every mock document at a
/// phone-sized surface, so build exceptions and RenderFlex overflows fail the
/// suite. Kept as a single test because easy_localization can only be
/// instantiated once per test process.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('all screens render all mock documents without exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: Builder(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => InvoicesCubit()),
              BlocProvider(create: (_) => QuotationsCubit()),
            ],
            child: MaterialApp(
              navigatorKey: Keys.navigatorKey,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: const HomeScreen(),
            ),
          ),
        ),
      ),
    );

    // Let translations load and the mock fetch (700 ms) complete.
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text(mockInvoices.first.number).evaluate().isNotEmpty) break;
    }
    expect(find.text(mockInvoices.first.number), findsOneWidget);

    for (final invoice in mockInvoices) {
      Navigation.push(InvoiceDetailsScreen(invoice: invoice));
      await tester.pumpAndSettle();
      expect(find.byType(InvoiceDetailsScreen), findsOneWidget);
      Navigation.pop();
      await tester.pumpAndSettle();
    }

    for (final quotation in mockQuotations) {
      Navigation.push(QuotationDetailsScreen(quotation: quotation));
      await tester.pumpAndSettle();
      expect(find.byType(QuotationDetailsScreen), findsOneWidget);
      Navigation.pop();
      await tester.pumpAndSettle();
    }

    // Create-offer flow: offers tab → FAB → quick-pick customer → add item
    // → save → lands on the new offer's details screen.
    await tester.tap(find.text('Price Offers'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(CreateQuotationScreen), findsOneWidget);

    await tester.tap(find.text(mockCustomers.first.name));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Add item'));
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('item_name_field')),
      'Test consulting service',
    );
    await tester.enterText(find.byKey(const Key('item_qty_field')), '2');
    await tester.enterText(
      find.byKey(const Key('item_price_field')),
      '150000',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save offer'));
    await tester.pumpAndSettle();
    expect(find.byType(QuotationDetailsScreen), findsOneWidget);
    expect(find.text('Test consulting service'), findsOneWidget);

    // Create-invoice flow: back home → invoices tab → FAB → quick-pick
    // customer → add item → save → lands on the new invoice's details.
    Navigation.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invoices'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(CreateInvoiceScreen), findsOneWidget);

    await tester.tap(find.text(mockCustomers.first.name));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Add item'));
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('item_name_field')),
      'Test hardware delivery',
    );
    await tester.enterText(find.byKey(const Key('item_qty_field')), '3');
    await tester.enterText(
      find.byKey(const Key('item_price_field')),
      '250000',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save invoice'));
    await tester.pumpAndSettle();
    expect(find.byType(InvoiceDetailsScreen), findsOneWidget);
    expect(find.text('Test hardware delivery'), findsOneWidget);
  });
}
