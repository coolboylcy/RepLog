import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../pages/training_page.dart';
import '../pages/history_page.dart';
import '../pages/insights_page.dart';
import '../pages/manage_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TrainingPage(),
    HistoryPage(),
    InsightsPage(),
    ManagePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center),
            label: l10n.tabTrain,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: l10n.tabHistory,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.insights),
            label: l10n.tabInsights,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.tabManage,
          ),
        ],
      ),
    );
  }
}
