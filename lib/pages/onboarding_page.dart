import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/hive_database.dart';
import 'home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      icon: Icons.lightbulb_outline_rounded,
      title: 'Learn by Doing',
      description:
          'ProgressPal isn\'t a to-do list. It\'s your personal learning companion that turns goals into growth.',
      color: Color(0xFF1565C0),
    ),
    OnboardingItem(
      icon: Icons.edit_note_rounded,
      title: 'Reflect to Complete',
      description:
          'To finish a goal, write what you learned. This simple step reinforces memory and proves your progress.',
      color: Color(0xFF7B1FA2),
    ),
    OnboardingItem(
      icon: Icons.folder_special_rounded,
      title: 'Organize with Tracks',
      description:
          'Group related goals into Tracks like "Learn Python" or "Fitness Journey". Stay focused and organized.',
      color: Color(0xFF00897B),
    ),
    OnboardingItem(
      icon: Icons.local_fire_department_rounded,
      title: 'Build Streaks',
      description:
          'Complete at least one goal daily to maintain your streak. Watch your consistency grow over time.',
      color: Color(0xFFE65100),
    ),
    OnboardingItem(
      icon: Icons.auto_awesome_rounded,
      title: 'AI-Powered Goals',
      description:
          'Stuck? Let AI suggest your next learning goal. One free generation per day to keep you moving.',
      color: Color(0xFF5E35B1),
    ),
    OnboardingItem(
      icon: Icons.timer_rounded,
      title: 'Focus with Pomodoro',
      description:
          'Use the built-in timer for focused work sessions. Stay productive with timed intervals.',
      color: Color(0xFFC62828),
    ),
    OnboardingItem(
      icon: Icons.rocket_launch_rounded,
      title: 'Ready to Grow?',
      description:
          'Start your learning journey today. Create your first track and set a goal!',
      color: Color(0xFF1565C0),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final settingsBox = Hive.box(HiveDatabase.settingsBoxName);
    await settingsBox.put('onboardingComplete', true);

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

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
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageContent(
                    item: _pages[index],
                    isActive: _currentPage == index,
                  );
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index
                              ? _pages[_currentPage].color
                              : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage].color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        key: ValueKey(_currentPage == _pages.length - 1),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

class _OnboardingPageContent extends StatelessWidget {
  final OnboardingItem item;
  final bool isActive;

  const _OnboardingPageContent({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon container
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: isActive ? 1.0 : 0.8),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(item.icon, size: 70, color: item.color),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title with fade animation
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: isActive ? 1.0 : 0.0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 400),
              offset: isActive ? Offset.zero : const Offset(0, 0.2),
              curve: Curves.easeOut,
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description with delayed fade animation
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: isActive ? 1.0 : 0.0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 500),
              offset: isActive ? Offset.zero : const Offset(0, 0.3),
              curve: Curves.easeOut,
              child: Text(
                item.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
