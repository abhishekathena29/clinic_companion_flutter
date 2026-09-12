import 'package:flutter/material.dart';

class OnboardingStep {
  const OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class OnboardingProvider extends ChangeNotifier {
  int _currentStep = 0;

  int get currentStep => _currentStep;

  final List<OnboardingStep> steps = const [
    OnboardingStep(
      title: 'Find the right doctor',
      subtitle: 'Search specialists near you and compare ratings in seconds.',
      icon: Icons.search_rounded,
    ),
    OnboardingStep(
      title: 'Book in one tap',
      subtitle: 'Pick a slot that works for you and confirm instantly.',
      icon: Icons.event_available_rounded,
    ),
    OnboardingStep(
      title: 'Consult your way',
      subtitle: 'Meet in person or join a video consultation from anywhere.',
      icon: Icons.video_call_rounded,
    ),
  ];

  void updateStep(int step) {
    _currentStep = step;
    notifyListeners();
  }
}
