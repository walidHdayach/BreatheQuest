import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../utils/prefs.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.timer_outlined,
      title: 'Sessions rapides',
      subtitle: '1 à 3 minutes pour te recentrer selon ton besoin : Calm, Focus ou Sleep.',
    ),
    _OnboardingPageData(
      icon: Icons.radar,
      title: 'Suis le rythme',
      subtitle: 'Un cercle animé te guide : inspire quand il grandit, expire quand il rétrécit.',
    ),
    _OnboardingPageData(
      icon: Icons.trending_up,
      title: 'Suivi de progrès',
      subtitle: 'Série, badges et historique pour rester motivé.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              AppConstants.tagline,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageCard(
                    data: _pages[index],
                    pageIndex: index,
                    currentPage: _currentPage,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppTheme.primary
                        : AppTheme.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await setOnboardingSeen();
                    if (context.mounted) context.go('/login');
                  },
                  child: const Text('Commencer'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String subtitle;
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingPageCard extends StatelessWidget {
  final _OnboardingPageData data;
  final int pageIndex;
  final int currentPage;

  const _OnboardingPageCard({
    required this.data,
    required this.pageIndex,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = pageIndex == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isActive ? 1 : 0.6,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: isActive ? 1 : 0.95,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(data.icon, color: AppTheme.primary, size: 56),
                  const SizedBox(height: 20),
                  Text(
                    data.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
