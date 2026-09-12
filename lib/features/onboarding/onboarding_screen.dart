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
            if (provider.currentStep > 0)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => controller.previousPage(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: isCompact ? 18 : 20,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MentiFit',
                  style: TextStyle(
                    fontSize: isCompact ? 18 : 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 10),
                _LogoChip(isLight: true, isCompact: isCompact),
              ],
            ),
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
        color: Colors.teal.withValues(alpha: 0.08),
        radius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MentiFit',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 14),
              const _LogoChip(),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your health,\nscheduled in a click',
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
                'Find a doctor, book a slot, and consult in person or online — all in one simple app.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: isShort ? 16 : 18,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
        color: Colors.teal.withValues(alpha: 0.1),
        radius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MentiFit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 10),
              const _LogoChip(isCompact: true),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Your health, scheduled in a click',
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
            'Find a doctor, book a slot, and consult in person or online.',
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
        horizontal: isCompact ? 12 : 14,
        vertical: isCompact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: isLight
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isLight
              ? AppColors.primary.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.25),
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield_outlined,
            size: isCompact ? 14 : 16,
            color: isLight ? AppColors.primary : Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            'Swasthya Vault',
            style: TextStyle(
              color: isLight ? AppColors.primary : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isCompact ? 11 : 12,
              letterSpacing: 0.4,
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
