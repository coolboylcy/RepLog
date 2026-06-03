import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app/main_shell.dart';
import '../theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) => _navigate());
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final tutorialDone = prefs.getBool('tutorial_done') ?? false;

    if (!mounted) return;
    if (!tutorialDone) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TutorialPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo 占位（实际使用图标资源替换）
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'RepLog',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '每组都算数',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Make every set count.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 首次启动教程 ───────────────────────────────────────

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final _controller = PageController();
  int _page = 0;

  static const _steps = [
    _TutorialStep(
      icon: Icons.play_circle_fill,
      color: AppColors.primary,
      titleKey: 'tutorialWelcome',
      bodyKey: 'tutorialStep1',
    ),
    _TutorialStep(
      icon: Icons.fitness_center,
      color: AppColors.accent,
      titleKey: 'tutorialWelcome',
      bodyKey: 'tutorialStep2',
    ),
    _TutorialStep(
      icon: Icons.insights,
      color: AppColors.success,
      titleKey: 'tutorialWelcome',
      bodyKey: 'tutorialStep3',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  void _next() {
    if (_page < _steps.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLast = _page == _steps.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(l10n.tutorialSkip,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ),

            // 页面内容
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: _steps.map((step) {
                  return _TutorialStepView(
                    step: step,
                    l10n: l10n,
                    pageIndex: _steps.indexOf(step),
                  );
                }).toList(),
              ),
            ),

            // 指示器
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 按钮
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    isLast ? l10n.tutorialGetStarted : l10n.tutorialNext,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialStep {
  final IconData icon;
  final Color color;
  final String titleKey;
  final String bodyKey;

  const _TutorialStep({
    required this.icon,
    required this.color,
    required this.titleKey,
    required this.bodyKey,
  });
}

class _TutorialStepView extends StatelessWidget {
  final _TutorialStep step;
  final AppLocalizations l10n;
  final int pageIndex;

  const _TutorialStepView({
    required this.step,
    required this.l10n,
    required this.pageIndex,
  });

  String _getTitle() => l10n.tutorialWelcome;

  String _getBody() {
    switch (pageIndex) {
      case 0:
        return l10n.tutorialStep1;
      case 1:
        return l10n.tutorialStep2;
      case 2:
        return l10n.tutorialStep3;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 48, color: step.color),
          ),
          const SizedBox(height: 32),
          Text(
            _getTitle(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _getBody(),
            style: const TextStyle(
                fontSize: 16, color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
