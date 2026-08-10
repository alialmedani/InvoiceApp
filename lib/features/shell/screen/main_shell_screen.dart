import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/features/account/screen/account_screen.dart';
import 'package:invoice/features/create/screen/create_hub_screen.dart';
import 'package:invoice/features/home/screen/home_dashboard_screen.dart';
import 'package:invoice/features/invoices/cubit/invoices_cubit.dart';
import 'package:invoice/features/invoices/screen/invoices_list_screen.dart';
import 'package:invoice/features/quotations/cubit/quotations_cubit.dart';
import 'package:invoice/features/quotations/screen/quotations_list_screen.dart';
import 'package:invoice/features/shell/widgets/floating_bottom_nav.dart';

/// The app's one real [Scaffold] after splash. Hosts 5 tabs (Home, Invoices,
/// Create, Quotations, Account) in an [IndexedStack] plus the floating
/// bottom nav in a [Stack]. Document creation/detail screens are still
/// pushed full-screen over this shell via the global [Navigation] helper.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Fetched once, centrally — every tab body is a pure BlocBuilder
    // consumer, no per-tab duplicate fetches.
    context.read<InvoicesCubit>().getInvoices();
    context.read<QuotationsCubit>().getQuotations();
  }

  void _goToTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final bodies = <Widget>[
      HomeDashboardScreen(onNavigate: _goToTab),
      const InvoicesListScreen(),
      const CreateHubScreen(),
      const QuotationsListScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Stack(
        children: [
          IndexedStack(index: _index, children: bodies),
          Positioned(
            left: 20,
            right: 20,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: FloatingBottomNav(currentIndex: _index, onTap: _goToTab),
          ),
        ],
      ),
    );
  }
}
