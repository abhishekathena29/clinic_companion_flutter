import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../widgets/app_button.dart';
import 'onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isDesktop(double width) => width >= 960;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.gradientPrimary),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = _isDesktop(constraints.maxWidth);
              final isShort = constraints.maxHeight < 760;
              final horizontalPadding = isDesktop ? 40.0 : 20.0;
              final verticalPadding = isDesktop ? 28.0 : 16.0;
              final shellWidth = math.min(constraints.maxWidth, 1180.0);
              final shellHeight = math.min(
                constraints.maxHeight - (verticalPadding * 2),
                isDesktop ? 760.0 : 820.0,
              );

              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: isDesktop
                      ? SizedBox(
                          width: shellWidth,
                          height: shellHeight,
                          child: Row(
                            children: [
                              Expanded(child: _DesktopIntro(isShort: isShort)),
                              const SizedBox(width: 28),
                              SizedBox(
                                width: 470,
                                child: _OnboardingCard(
                                  controller: _controller,
                                  provider: provider,
                                  isCompact: false,
                                  fillHeight: true,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight:
                                    constraints.maxHeight -
                                    (verticalPadding * 2),
                                maxWidth: math.min(shellWidth, 560),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _MobileIntro(isShort: isShort),
                                  const SizedBox(height: 16),
                                  _OnboardingCard(
                                    controller: _controller,
                                    provider: provider,
                                    isCompact: true,
                                    fillHeight: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.controller,
    required this.provider,
    required this.isCompact,
    required this.fillHeight,
  });

  final PageController controller;
  final OnboardingProvider provider;
  final bool isCompact;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final contentPadding = isCompact ? 22.0 : 36.0;
    final pageViewportHeight = isCompact ? 350.0 : null;

    final content = Column(
      mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LogoChip(isLight: true, isCompact: isCompact),
            const Spacer(),
            Text(
              '${provider.currentStep + 1}/${provider.steps.length}',
              style: TextStyle(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w700,
                fontSize: isCompact ? 13 : 14,
              ),
            ),
          ],
        ),
        SizedBox(height: isCompact ? 20 : 28),
        if (fillHeight)
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: provider.steps.length,
              onPageChanged: provider.updateStep,
              itemBuilder: (context, index) {
                return _StepCard(
                  step: provider.steps[index],
                  isCompact: isCompact,
                );
              },
            ),
          )
        else
          SizedBox(
            height: pageViewportHeight,
            child: PageView.builder(
              controller: controller,
              itemCount: provider.steps.length,
              onPageChanged: provider.updateStep,
              itemBuilder: (context, index) {
                return _StepCard(
                  step: provider.steps[index],
                  isCompact: isCompact,
                );
              },
            ),
          ),
        SizedBox(height: isCompact ? 18 : 24),
        _PageIndicators(
          currentStep: provider.currentStep,
          totalSteps: provider.steps.length,
        ),
        SizedBox(height: isCompact ? 18 : 28),
        _ActionButtons(
          controller: controller,
          provider: provider,
          isCompact: isCompact,
        ),
        SizedBox(height: isCompact ? 8 : 12),
        Center(child: _SignInButton(isCompact: isCompact)),
      ],
    );

    return Container(
      decoration: AppDecorations.card(
        radius: BorderRadius.circular(isCompact ? 28 : 32),
      ),
      padding: EdgeInsets.all(contentPadding),
      child: content,
    );
  }
}

class _DesktopIntro extends StatelessWidget {
  const _DesktopIntro({required this.isShort});

  final bool isShort;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isShort ? 32 : 40),
      decoration: AppDecorations.glass(
        color: Colors.blue.withValues(alpha: 0.08),
        radius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _LogoChip(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clear, fast\nclinic onboarding',
                style: TextStyle(
                  fontSize: isShort ? 48 : 58,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.05,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Set up patient intake, scheduling, and follow-ups in a simple guided flow that works cleanly across devices.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: isShort ? 16 : 18,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const _InsightStrip(),
        ],
      ),
    );
  }
}

class _MobileIntro extends StatelessWidget {
  const _MobileIntro({required this.isShort});

  final bool isShort;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isShort ? 20 : 24),
      decoration: AppDecorations.glass(
        color: Colors.blue.withValues(alpha: 0.1),
        radius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Text(
            'Welcome to Clinic Companion',
            style: TextStyle(
              color: Colors.white,
              fontSize: isShort ? 28 : 32,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A simple setup flow for appointments, patient records, and follow-ups.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicators extends StatelessWidget {
  const _PageIndicators({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 10,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.controller,
    required this.provider,
    required this.isCompact,
  });

  final PageController controller;
  final OnboardingProvider provider;
  final bool isCompact;

  void _advance(BuildContext context) {
    if (provider.currentStep == provider.steps.length - 1) {
      Navigator.of(context).pushReplacementNamed('/auth');
      return;
    }

    controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextLabel = provider.currentStep == provider.steps.length - 1
        ? 'Get Started'
        : 'Next';
    final size = isCompact ? AppButtonSize.medium : AppButtonSize.large;

    if (isCompact) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: AppButton(
              size: size,
              label: nextLabel,
              icon: Icons.arrow_forward_rounded,
              onPressed: () => _advance(context),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              size: size,
              label: 'Skip',
              icon: Icons.close_rounded,
              variant: AppButtonVariant.ghost,
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/auth'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: AppButton(
            size: size,
            label: 'Skip',
            icon: Icons.close_rounded,
            variant: AppButtonVariant.ghost,
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/auth'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AppButton(
            size: size,
            label: nextLabel,
            icon: Icons.arrow_forward_rounded,
            onPressed: () => _advance(context),
          ),
        ),
      ],
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pushReplacementNamed('/auth'),
      child: Text(
        'Already have an account? Sign in',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isCompact ? 14 : 15,
        ),
      ),
    );
  }
}

class _LogoChip extends StatelessWidget {
  const _LogoChip({this.isLight = false, this.isCompact = false});

  final bool isLight;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 14 : 16,
        vertical: isCompact ? 9 : 10,
      ),
      decoration: BoxDecoration(
        color: isLight
            ? AppColors.primary
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isLight
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medical_services_rounded, size: 18, color: Colors.white),
          SizedBox(width: 10),
          Text(
            'Swasthya Health Vault',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightStrip extends StatelessWidget {
  const _InsightStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.glass(
        color: Colors.blue.withValues(alpha: 0.12),
        radius: BorderRadius.circular(24),
      ),
      child: Row(
        children: const [
          _InsightItem(value: '3 min', label: 'Average setup time'),
          SizedBox(width: 18),
          _InsightItem(value: '24/7', label: 'Cross-device access'),
          SizedBox(width: 18),
          _InsightItem(value: '38%', label: 'Faster check-in'),
        ],
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  const _InsightItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.isCompact});

  final OnboardingStep step;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final titleSize = isCompact ? 26.0 : 34.0;
    final subtitleSize = isCompact ? 15.0 : 16.0;
    final iconBox = isCompact ? 68.0 : 84.0;
    final innerPadding = isCompact ? 16.0 : 22.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Icon(
              step.icon,
              color: AppColors.primary,
              size: isCompact ? 34 : 42,
            ),
          ),
          SizedBox(height: isCompact ? 20 : 28),
          Text(
            step.title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -0.6,
            ),
          ),
          SizedBox(height: isCompact ? 12 : 14),
          Text(
            step.subtitle,
            style: TextStyle(
              color: AppColors.mutedForeground,
              fontSize: subtitleSize,
              height: 1.5,
            ),
          ),
          SizedBox(height: isCompact ? 22 : 28),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(innerPadding),
            decoration: BoxDecoration(
              color: AppColors.muted.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isCompact ? 40 : 44,
                  height: isCompact ? 40 : 44,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                    size: isCompact ? 20 : 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Built for quick registration, cleaner scheduling, and follow-up steps that stay understandable on smaller screens.',
                    style: TextStyle(
                      fontSize: isCompact ? 13 : 14,
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isCompact) const SizedBox(height: 12),
        ],
      ),
    );
  }
}
