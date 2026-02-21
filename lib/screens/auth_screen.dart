import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_button.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final provider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: AppColors.background),
        child: Row(
          children: [
            if (isDesktop)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(gradient: AppColors.gradientHero),
                  child: Padding(
                    padding: const EdgeInsets.all(64),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BrandChip(),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: AppDecorations.glass(
                            color: Colors.black.withOpacity(0.1),
                            radius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.isLogin
                                    ? 'Welcome back,\nDoctor'
                                    : 'Join Clinic\nCompanion',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Securely access appointments, records, and patient journeys from any device.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 18,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        _TrustRow(),
                        const Spacer(),
                        Text(
                          'HIPAA-ready workflows and regional compliance built-in',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 64 : 24,
                    vertical: 24,
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 460),
                    decoration: AppDecorations.card(),
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isDesktop) ...[
                          _BrandChip(isLight: true),
                          const SizedBox(height: 24),
                        ],
                        Text(
                          provider.isLogin ? 'Sign in' : 'Create your account',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.isLogin
                              ? 'Start where you left off in seconds.'
                              : 'Set up your clinic workspace in minutes.',
                          style: TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (!provider.isLogin) ...[
                          TextField(
                            onChanged: provider.updateName,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextField(
                          onChanged: provider.updateEmail,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          obscureText: provider.obscurePassword,
                          onChanged: provider.updatePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              onPressed: provider.togglePasswordVisibility,
                              icon: Icon(
                                provider.obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        if (!provider.isLogin) ...[
                          const SizedBox(height: 16),
                          TextField(
                            obscureText: provider.obscureConfirm,
                            onChanged: provider.updateConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm password',
                              suffixIcon: IconButton(
                                onPressed: provider.toggleConfirmVisibility,
                                icon: Icon(
                                  provider.obscureConfirm
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        if (provider.error != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.destructive.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.destructive.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.destructive,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    provider.error!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.destructive,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (provider.isLogin) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                              ),
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shield_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Two-factor authentication available for clinic teams.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            size: AppButtonSize.large,
                            label: provider.isLogin
                                ? 'Sign in'
                                : 'Create account',
                            icon: provider.isLogin
                                ? Icons.login_rounded
                                : Icons.check_circle_rounded,
                            onPressed: provider.isLoading
                                ? null
                                : () async {
                                    await provider.submit();
                                    if (context.mounted) {
                                      Navigator.of(
                                        context,
                                      ).pushReplacementNamed('/');
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (provider.isLoading)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              provider.isLogin
                                  ? 'Need an account?'
                                  : 'Already have an account?',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: provider.toggleMode,
                              child: Text(
                                provider.isLogin ? 'Create one' : 'Sign in',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(
                              context,
                            ).pushReplacementNamed('/onboarding'),
                            child: const Text(
                              'Back to onboarding',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
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

class _BrandChip extends StatelessWidget {
  const _BrandChip({this.isLight = false});

  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isLight ? AppColors.primary : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isLight ? Colors.transparent : Colors.white.withOpacity(0.2),
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medical_services_rounded, size: 18, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            'Swasthya Health Vault',
            style: const TextStyle(
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

class _TrustRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TrustBadge(label: 'ISO 27001', icon: Icons.verified_rounded),
        const SizedBox(width: 16),
        _TrustBadge(label: 'HL7 Ready', icon: Icons.health_and_safety_rounded),
        const SizedBox(width: 16),
        _TrustBadge(label: '99.9% Uptime', icon: Icons.cloud_done_rounded),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
