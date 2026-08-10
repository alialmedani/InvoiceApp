import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:invoice/core/classes/cashe_helper.dart';
import 'package:invoice/core/classes/keys.dart';
import 'package:invoice/core/constant/app_theme/app_theme.dart';
import 'package:invoice/core/cubit/theme_cubit.dart';
import 'package:invoice/core/di/injection.dart';
import 'package:invoice/core/ui/screens/splash_screen.dart';
import 'package:invoice/features/invoices/cubit/invoices_cubit.dart';
import 'package:invoice/features/quotations/cubit/quotations_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CacheHelper.init();
  await setUp();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('ku')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<InvoicesCubit>()),
        BlocProvider(create: (_) => getIt<QuotationsCubit>()),
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
      ],
      child: ScreenUtilInit(
        minTextAdapt: true,
        useInheritedMediaQuery: true,
        splitScreenMode: false,
        child: Builder(
          builder: (context) {
            final themeMode = context.watch<ThemeCubit>().state;
            return MaterialApp(
              navigatorKey: Keys.navigatorKey,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                ...context.localizationDelegates,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
                Locale('ku'),
              ],
              locale: context.locale,
              localeResolutionCallback: (locale, supportedLocales) {
                // Kurdish is not supported by Material/Cupertino, use English for system widgets
                if (locale?.languageCode == 'ku') {
                  return const Locale('en');
                }
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale?.languageCode) {
                    return supportedLocale;
                  }
                }
                return const Locale('en');
              },
              theme: appThemeData[AppTheme.light],
              darkTheme: appThemeData[AppTheme.dark],
              themeMode: themeMode,
              title: 'Jasim Invoice',
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
