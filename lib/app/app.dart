import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'service_locator.dart';
import 'main_shell.dart';
import '../pages/splash_page.dart';

class RepLogApp extends StatelessWidget {
  const RepLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = ServiceLocator.of(context).localeService;

    return ValueListenableBuilder<Locale>(
      valueListenable: localeService.localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'RepLog',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashPage(),
        );
      },
    );
  }
}
