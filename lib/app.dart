import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/training_page.dart';
import 'pages/history_page.dart';
import 'pages/insights_page.dart';
import 'pages/manage_page.dart';
import 'pages/settings_page.dart';

class RepLogApp extends StatefulWidget {
  const RepLogApp({super.key});

  @override
  State<RepLogApp> createState() => _RepLogAppState();
}

class _RepLogAppState extends State<RepLogApp> {
  final ValueNotifier<Locale> _localeNotifier =
      ValueNotifier(const Locale('zh'));

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'zh';
    _localeNotifier.value = Locale(lang);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: _localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'RepLog',
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh'),
            Locale('en'),
          ],
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.dark,
          ),
          home: _HomePage(localeNotifier: _localeNotifier),
        );
      },
    );
  }
}

class _HomePage extends StatefulWidget {
  final ValueNotifier<Locale> localeNotifier;

  const _HomePage({required this.localeNotifier});

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const TrainingPage(),
      const HistoryPage(),
      const InsightsPage(),
      const ManagePage(),
      SettingsPage(localeNotifier: widget.localeNotifier),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.fitness_center),
            label: l10n.training,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: l10n.history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights),
            label: l10n.insights,
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            label: l10n.manage,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
