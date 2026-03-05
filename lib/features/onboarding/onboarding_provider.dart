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
      title: 'Streamlined Patient Journeys',
      subtitle: 'Capture patient details, history, and vitals in minutes with a guided intake flow.',
      icon: Icons.assignment_turned_in,
    ),
    OnboardingStep(
      title: 'Smarter Daily Scheduling',
      subtitle: 'Visualize upcoming appointments and real-time queue updates across devices.',
      icon: Icons.schedule,
    ),
    OnboardingStep(
      title: 'Connected Care Insights',
      subtitle: 'Track chronic conditions, labs, and follow-ups with proactive alerts.',
      icon: Icons.insights,
    ),
  ];

  void updateStep(int step) {
    _currentStep = step;
    notifyListeners();
  }
}
